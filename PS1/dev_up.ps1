$root = Split-Path $PSScriptRoot -Parent
Write-Host "== dev_up =="
if (-not (Test-Path "$root/docker-compose.yml")) {
    Write-Warning "docker-compose.yml missing"
} else {
    Write-Host "docker-compose.yml present"
}
if (-not (Test-Path "$root/.env.example")) {
    Write-Error ".env.example missing"
    exit 1
}
Write-Host "Environment OK"
