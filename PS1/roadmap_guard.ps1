$root = Split-Path $PSScriptRoot -Parent
$index = Get-Content "$root/docs/roadmap/index.md"
$refs = $index | Where-Object { $_ -match '^-\s+roadmap_\d+-\d+\.md' } | ForEach-Object { ($_ -replace '^-\s+','').Trim() }
foreach ($r in $refs) {
    if (-not (Test-Path "$root/docs/roadmap/$r")) {
        Write-Error "Missing $r"
        exit 1
    }
}
Write-Host "roadmap_guard passed"
