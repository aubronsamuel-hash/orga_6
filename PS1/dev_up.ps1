$ErrorActionPreference = "Stop"

# 0) Ensure .env exists from .env.example
if (-not (Test-Path ".env")) {
  if (-not (Test-Path ".env.example")) { throw ".env.example missing" }
  $content = Get-Content -Raw ".env.example"
  if (-not ($content -match "\S")) { throw ".env.example empty" }
  $content | Set-Content -NoNewline ".env"
  Write-Host "Created .env from .env.example"
}

# 1) Build and start services
Write-Host "Starting stack (db, api)..."
docker compose up -d --build

# 2) Wait for api health
$max = 40
for ($i=0; $i -lt $max; $i++) {
  try {
    $r = Invoke-WebRequest -Uri "http://localhost:8000/health" -UseBasicParsing -TimeoutSec 2
    if ($r.StatusCode -eq 200) { Write-Host "API healthy"; break }
  } catch {}
  Start-Sleep -Seconds 2
}
