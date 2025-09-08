$ErrorActionPreference = "Stop"
$response = Invoke-WebRequest -Uri "http://localhost:8000/health" -UseBasicParsing
if ($response.StatusCode -ne 200) { throw "Health check failed" }
Write-Host $response.Content

# Try a login request
$Email = $env["SMOKE_EMAIL"]
$Password = $env["SMOKE_PASSWORD"]
if (-not $Email -or -not $Password) {
  Write-Host "SMOKE_EMAIL/SMOKE_PASSWORD not set, skipping auth smoke"
  exit 0
}

try {
  $resp = Invoke-RestMethod -Method Post -Uri "http://localhost:8000/auth/login" -ContentType "application/json" -Body (@{ email=$Email; password=$Password } | ConvertTo-Json)
  if ($resp.access_token) { Write-Host "auth login OK"; exit 0 } else { Write-Error "no token"; exit 1 }
} catch {
  Write-Error $_
  exit 1
}
