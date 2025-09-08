$ErrorActionPreference = "Stop"
Write-Host "Running backend tests inside container..."
docker compose exec -T api pytest -q
