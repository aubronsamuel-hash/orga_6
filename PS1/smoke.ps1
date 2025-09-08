#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"

$Base = $env:SMOKE_BASE
if (-not $Base) { $Base = "http://localhost:8000" }

# Health
$r = Invoke-RestMethod -Uri "$Base/health" -Method Get
$r | ConvertTo-Json -Compress | Write-Output

# Optional quick create if env present
$Email = $env:SMOKE_EMAIL
$Name  = $env:SMOKE_NAME
if ($Email -and $Name) {
  $body = @{ email = $Email; full_name = $Name } | ConvertTo-Json
  Invoke-RestMethod -Uri "$Base/users" -Method Post -ContentType 'application/json' -Body $body | Out-Null
}
