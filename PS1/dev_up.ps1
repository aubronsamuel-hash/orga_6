#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
Write-Host "Starting db and api with migrations at boot..."
docker compose up -d --build db api

# Try to get the API container id by label first; fallback to compose service
$apiId = (docker ps --filter "label=com.docker.compose.service=api" -q | Select-Object -First 1)
if (-not $apiId) { $apiId = (docker compose ps -q api) }
if (-not $apiId) {
  Write-Host "API container not found. Listing compose services:" -ForegroundColor Yellow
  docker compose ps
  Write-Error "Cannot find API container id. Check service name 'api' in docker-compose.yml"
}

for ($i=0; $i -lt 120; $i++) {
  $state = (docker inspect --format='{{json .State.Health.Status}}' $apiId 2>$null)
  if (-not $state) { $state = '"starting"' }
  Write-Host "health=$state"
  if ($state -eq '"healthy"') { break }
  Start-Sleep -Seconds 2
}
if ($state -ne '"healthy"') {
  Write-Host "API container not healthy in time" -ForegroundColor Red
  docker compose logs --no-color | Out-File -FilePath ci_docker_logs.txt -Encoding ascii
  exit 1
}
Write-Host "API healthy."
