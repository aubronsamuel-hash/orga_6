<PowerShell agents_guard.ps1 content from assistant message above># agents_guard.ps1
# Guard CI pour valider la cohérence agents/roadmaps + conformité au template
# Usage:
#   pwsh -File PS1/agents_guard.ps1
#   pwsh -File PS1/agents_guard.ps1 -Strict
#   pwsh -File PS1/agents_guard.ps1 -Fix

[CmdletBinding()]
param(
  [switch]$Strict,
  [switch]$Fix
)

$ErrorActionPreference = 'Stop'
$failed = $false

function Fail($msg) {
  Write-Host "[FAIL] $msg" -ForegroundColor Red
  $global:failed = $true
}

function Warn($msg) {
  Write-Host "[WARN] $msg" -ForegroundColor Yellow
}

function Info($msg) {
  Write-Host "[INFO] $msg" -ForegroundColor Cyan
}

Write-Host "== Agents Guard =="

# Resolve repo root from this script location
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$repo = Resolve-Path (Join-Path $root '..')

# Paths
$templatePath = Join-Path $repo 'AGENT.template.md'
$indexPath    = Join-Path $repo 'index.md'
$agentsDir    = Join-Path $repo 'agents'

if (-not (Test-Path $templatePath)) { Fail "Missing template: AGENT.template.md"; }
if (-not (Test-Path $indexPath))    { Fail "Missing index: index.md"; }
if (-not (Test-Path $agentsDir))    { Fail "Missing directory: agents/"; }

# Optional auto-fix hook (delegates to generator if present)
if ($Fix) {
  $gen = Join-Path $repo 'generate_agents_from_roadmap.ps1'
  if (Test-Path $gen) {
    Info "Running generator with -Force to restore missing agents..."
    try {
      & pwsh -NoProfile -File $gen -Force
    } catch {
      Warn "Generator execution failed: $($_.Exception.Message)"
    }
  } else {
    Warn "Generator script not found (generate_agents_from_roadmap.ps1)."
  }
}

# Load files
try {
  $templateRaw = Get-Content $templatePath -Raw
  $indexRaw    = Get-Content $indexPath -Raw
} catch {
  Fail "Unable to read template or index: $($_.Exception.Message)"
}

# 1) Check roadmap references listed in index.md exist in repo
$roadmapRefs = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
$rxRoadmap = [regex]'roadmap_\d{2}-\d{2}\.md'
foreach ($m in $rxRoadmap.Matches($indexRaw)) { [void]$roadmapRefs.Add($m.Value) }

if ($roadmapRefs.Count -eq 0) {
  Warn "No roadmap files referenced in index.md (pattern: roadmap_XX-YY.md)."
}

$roadmapFiles = @()
foreach ($ref in $roadmapRefs) {
  $path = Join-Path $repo $ref
  if (-not (Test-Path $path)) {
    Fail "Missing roadmap file referenced by index.md: $ref"
  } else {
    $roadmapFiles += Get-Item $path
  }
}

# 2) Extract steps from each roadmap file
$steps = New-Object System.Collections.Generic.List[hashtable]
$rxEtape = [regex]'(?m)^###\s+Etape\s+(\d+)\s*-\s*(.+)$'
foreach ($rf in $roadmapFiles) {
  $txt = Get-Content $rf.FullName -Raw
  foreach ($m in $rxEtape.Matches($txt)) {
    $id = [int]$m.Groups[1].Value
    $title = $m.Groups[2].Value.Trim()
    $safe = ($title -replace '[^A-Za-z0-9_]+','_').Trim('_')
    $fileName = ('STEP_{0:D2}_{1}_AGENT.md' -f $id, $safe)
    $steps.Add(@{ Id=$id; Title=$title; Safe=$safe; File=$fileName })
  }
}

if ($steps.Count -eq 0) {
  Warn "No steps parsed from the referenced roadmaps. Check headings '### Etape N - Title'."
}

# 3) Check that for each roadmap step, there is a corresponding AGENT.md
foreach ($s in $steps) {
  $agentPath = Join-Path $agentsDir $s.File
  if (-not (Test-Path $agentPath)) {
    Fail "Missing agent file for Etape $($s.Id): $($s.File)"
  }
}

# 4) Special-case STEP_00 scaffold folder existence
$step00 = Join-Path $agentsDir 'STEP_00_scaffold\AGENT.md'
if (-not (Test-Path $step00)) {
  Fail "Missing agent scaffold: agents/STEP_00_scaffold/AGENT.md"
}

# 5) Basic structure check for each agent file (must include the STEP template anchors)
$requiredAnchors = @(
  '## STEP_ID',
  'GOAL:',
  'SCOPE:',
  'ACCEPTANCE_CRITERIA:',
  'DELIVERABLES:',
  'GUARDS:',
  'LOCAL_COMMANDS',
  'CI_JOBS_REQUIRED:',
  'MIGRATIONS:',
  'ROLLBACK:',
  'NOTES:'
)

# Guards required in GUARDS section (strict set, order not enforced)
$requiredGuards = @(
  'docs_guard','roadmap_guard','any_guard','commit_guard',
  'env_guard','changelog_guard','script_guard','schema_guard'
)

# ASCII validator
function IsAscii([string]$s) {
  foreach ($ch in $s.ToCharArray()) {
    if ([int][char]$ch -gt 127) { return $false }
  }
  return $true
}

# Extract GUARDS subsection text
function ExtractGuards([string]$content) {
  $rx = [regex]'(?s)GUARDS:\s*(.+?)(?:\r?\n\r?\n|$)'
  $m = $rx.Match($content)
  if ($m.Success) { return $m.Groups[1].Value } else { return '' }
}

# 6) Strict mode: derive section order from template and compare
$tmplOrder = @()
if ($Strict) {
  # Build expected order list from template anchors and labels
  foreach ($a in $requiredAnchors) { $tmplOrder += $a }
}

# Iterate all agents in repo
$agentFiles = Get-ChildItem $agentsDir -File -Filter "*_AGENT.md" -Recurse
foreach ($af in $agentFiles) {
  $content = Get-Content $af.FullName -Raw

  # ASCII only
  if (-not (IsAscii $content)) {
    Fail "Non-ASCII character detected in: $($af.FullName)"
  }

  # Presence of anchors
  foreach ($a in $requiredAnchors) {
    if ($content -notmatch [regex]::Escape($a)) {
      Fail "Missing anchor '$a' in: $($af.Name)"
    }
  }

  # GUARDS completeness
  $guardsRaw = ExtractGuards $content
  foreach ($g in $requiredGuards) {
    if ($guardsRaw -notmatch [regex]::Escape($g)) {
      Fail "GUARDS section missing '$g' in: $($af.Name)"
    }
  }

  # Strict: section order check relative to template expected order
  if ($Strict) {
    # Find first index of each anchor
    $orderIndices = @()
    foreach ($a in $tmplOrder) {
      $idx = $content.IndexOf($a, [System.StringComparison]::Ordinal)
      $orderIndices += @{ Anchor=$a; Index=$idx }
    }
    # Validate monotonic non-decreasing order of present anchors
    $last = -1
    foreach ($o in $orderIndices) {
      if ($o.Index -ge 0) {
        if ($o.Index -lt $last) {
          Fail "Anchor order mismatch around '$($o.Anchor)' in: $($af.Name) (enable -Fix to regen)."
          break
        }
        $last = $o.Index
      }
    }
  }
}

# 7) Optional cross-check: template sanity (must include baseline anchors)
foreach ($a in $requiredAnchors) {
  if ($templateRaw -notmatch [regex]::Escape($a)) {
    Fail "Template missing expected anchor: $a"
  }
}

# Summary
if ($failed) {
  Write-Host "Agents guard FAILED." -ForegroundColor Red
  exit 1
} else {
  Write-Host "Agents guard passed." -ForegroundColor Green
  exit 0
}
