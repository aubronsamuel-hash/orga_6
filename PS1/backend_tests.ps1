#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"

# ensure venv
if (-not (Test-Path ".venv")) { python -m venv .venv }
. .\.venv\Scripts\Activate.ps1
python -m pip install -U pip
if (Test-Path "backend/requirements-dev.txt") {
  pip install -r backend/requirements-dev.txt
} else {
  pip install pytest httpx
}

# Use sqlite by default for local tests
if (-not $env:DATABASE_URL) { $env:DATABASE_URL = "sqlite:///./test.db" }

Set-Location backend
python -m pytest -q

Write-Host "Tests OK" -ForegroundColor Green

