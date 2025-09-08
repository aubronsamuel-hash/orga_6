#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
Write-Host "Starting db and api with migrations at boot..."
docker compose up -d --build db api

$apiId = (docker compose ps -q api)
for ($i=0; $i -lt 120; $i++) {
  $state = docker inspect --format='{{json .State.Health.Status}}' $apiId 2>$null
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
