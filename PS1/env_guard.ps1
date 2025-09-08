$root = Split-Path $PSScriptRoot -Parent
$path = "$root/.env.example"
if (-not (Test-Path $path)) {
    Write-Error '.env.example missing'
    exit 1
}
$content = Get-Content $path | Where-Object { $_ -match '\S' }
if ($content.Count -eq 0) {
    Write-Error '.env.example empty'
    exit 1
}
Write-Host 'env_guard passed'
