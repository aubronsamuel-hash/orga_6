#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"

Write-Host "Running backend tests (host venv)..."

# ensure venv
if (-not (Test-Path ".venv")) { python -m venv .venv }
$venv = Join-Path (Get-Location) ".venv"
$activate = Join-Path $venv "Scripts/Activate.ps1"
. $activate
python -m pip install -U pip

# install dev deps
if (Test-Path "backend/requirements-dev.txt") {
  pip install -r backend/requirements-dev.txt
} else {
  pip install pytest httpx
}

# default to sqlite for local tests
if (-not $env:DATABASE_URL) { $env:DATABASE_URL = "sqlite:///./test.db" }

Set-Location backend
python -m pytest -q
if ($LASTEXITCODE -ne 0) { throw "pytest failed with exit code $LASTEXITCODE" }

Write-Host "Tests OK" -ForegroundColor Green

