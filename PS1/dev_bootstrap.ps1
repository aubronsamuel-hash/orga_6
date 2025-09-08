#!/usr/bin/env pwsh
# Dev bootstrap: create .venv, install runtime+dev deps, run alembic, quick smoke.
# Usage:
#   pwsh -File PS1/dev_bootstrap.ps1 [-DatabaseUrl <URL>] [-Recreate]
# Examples:
#   pwsh -File PS1/dev_bootstrap.ps1
#   pwsh -File PS1/dev_bootstrap.ps1 -DatabaseUrl "postgresql+psycopg://postgres:postgres@localhost:5432/orga"
#   pwsh -File PS1/dev_bootstrap.ps1 -Recreate

param(
  [string]$DatabaseUrl,
  [switch]$Recreate
)

$ErrorActionPreference = "Stop"

# 1) venv
if (-not (Test-Path ".venv")) { python -m venv .venv }
. .\.venv\Scripts\Activate.ps1
python -m pip install -U pip

# 2) deps
if (Test-Path "backend/requirements-dev.txt") {
  pip install -r backend/requirements-dev.txt
} else {
  pip install fastapi==0.112.2 uvicorn[standard]==0.30.6 SQLAlchemy==2.0.35 `
              pydantic==2.8.2 pydantic-settings==2.4.0 psycopg-binary==3.2.1 `
              alembic==1.13.2 python-multipart==0.0.9 pytest httpx
}

# 3) DB URL (default to sqlite file)
if (-not $DatabaseUrl) {
  if ($env:DATABASE_URL) { $DatabaseUrl = $env:DATABASE_URL } else { $DatabaseUrl = "sqlite:///./dev_bootstrap.db" }
}
$env:DATABASE_URL = $DatabaseUrl

# 4) Optional recreate sqlite file
if ($Recreate -and $DatabaseUrl -like "sqlite*dev_bootstrap.db*") {
  if (Test-Path "dev_bootstrap.db") { Remove-Item -Force dev_bootstrap.db }
}

# 5) Alembic migrate
Set-Location backend
alembic -c alembic.ini upgrade head

# 6) Quick smoke (FastAPI app import + create a test client health)
@"
from fastapi.testclient import TestClient
from app.main import app
c = TestClient(app)
r = c.get("/health")
assert r.status_code == 200 and r.json().get("status") == "ok"
print("smoke: /health OK")
"@ | python -

Write-Host "Dev bootstrap OK" -ForegroundColor Green

# 7) Suggest next commands
Write-Host "Next: pwsh -File PS1/backend_tests.ps1" -ForegroundColor Cyan

