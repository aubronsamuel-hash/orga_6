$root = Split-Path $PSScriptRoot -Parent
Write-Host "== smoke =="
if (-not (Test-Path "$root/docs/REPO_TREE.md")) {
    Write-Error "docs/REPO_TREE.md missing"
    exit 1
}
Write-Host "Smoke OK"
