$root = Split-Path $PSScriptRoot -Parent
$path = "$root/agent_md_from_scratch.md"
if (-not (Test-Path $path)) {
    Write-Error 'agent_md_from_scratch.md missing'
    exit 1
}
$content = Get-Content $path
if (-not ($content -match '# CHANGELOG')) {
    Write-Error 'CHANGELOG missing'
    exit 1
}
Write-Host 'changelog_guard passed'
