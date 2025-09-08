<PowerShell script content from assistant message above># PS1/generate_agents_from_roadmap.ps1
param(
    [switch]$Force,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

# Roots
$repoRoot     = Split-Path -Parent $PSScriptRoot
$agentsDir    = Join-Path $repoRoot "agents"
$templateFile = Join-Path $repoRoot "AGENT.template.md"
$scratchFile  = Join-Path $repoRoot "agent_md_from_scratch.md"

$roadmapFiles = @(
    Join-Path $repoRoot "roadmap_01_10.md",
    Join-Path $repoRoot "roadmap_11_20.md",
    Join-Path $repoRoot "roadmap_21-30.md",
    Join-Path $repoRoot "roadmap_31-40.md"
)

if (-not (Test-Path $agentsDir)) { New-Item -ItemType Directory -Path $agentsDir | Out-Null }

# Load templates
if (-not (Test-Path $templateFile)) { throw "Missing template: $templateFile" }
$template = Get-Content $templateFile -Raw

$scratchTemplate = $null
if (Test-Path $scratchFile) { $scratchTemplate = Get-Content $scratchFile -Raw }

function Sanitize-FileName([string]$text) {
    $invalid = [IO.Path]::GetInvalidFileNameChars() -join ''
    $regex   = "[{0}]" -f [Regex]::Escape($invalid)
    return (($text -replace $regex, "_") -replace "\s+", "_").Trim("_")
}

function Parse-Roadmap([string]$file) {
    if (-not (Test-Path $file)) { return @() }
    $content = Get-Content $file
    $steps = @()
    foreach ($line in $content) {
        if ($line -match '^### Etape\s+(\d+)\s+-\s+(.+)$') {
            $steps += [PSCustomObject]@{
                StepId = [int]$matches[1]
                Title  = $matches[2].Trim()
                Source = Split-Path $file -Leaf
            }
        }
    }
    return $steps
}

# Collect steps from all roadmap files
$steps = @()
foreach ($f in $roadmapFiles) { $steps += Parse-Roadmap $f }

# --- STEP 00: scaffold (nested folder agents/STEP_00_scaffold/AGENT.md) ---
$step0Dir  = Join-Path $agentsDir "STEP_00_scaffold"
$step0File = Join-Path $step0Dir "AGENT.md"

if (-not (Test-Path $step0Dir)) { New-Item -ItemType Directory -Path $step0Dir | Out-Null }

$needWriteStep0 = $Force -or -not (Test-Path $step0File)
if ($needWriteStep0) {
    $content0 = if ($scratchTemplate) { $scratchTemplate } else {
        "# STEP_00_scaffold`n# Generated from AGENT.template.md (fallback)`n`n$template"
    }

    if ($DryRun) {
        Write-Host "Would generate: STEP_00_scaffold/AGENT.md"
    } else {
        $content0 | Set-Content -Path $step0File -Encoding UTF8
        Write-Host "Generated: STEP_00_scaffold/AGENT.md"
    }
} else {
    Write-Host "Skip existing STEP_00_scaffold/AGENT.md"
}

# --- Steps 01–40 (flat files) ---
foreach ($step in $steps | Sort-Object StepId) {
    $fname   = "STEP_{0}_{1}_AGENT.md" -f $step.StepId.ToString("00"), (Sanitize-FileName $step.Title)
    $outFile = Join-Path $agentsDir $fname

    if (-not $Force -and (Test-Path $outFile)) {
        Write-Host "Skip existing $fname"
        continue
    }

    $content = "# From roadmap: $($step.Source)`n# Full title: $($step.Title)`n`n$template"

    if ($DryRun) {
        Write-Host "Would generate: $fname"
    } else {
        $content | Set-Content -Path $outFile -Encoding UTF8
        Write-Host "Generated: $fname"
    }
}

Write-Host "Done."
