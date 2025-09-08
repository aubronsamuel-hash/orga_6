$ErrorActionPreference = "Stop"
$response = Invoke-WebRequest -Uri "http://localhost:8000/health" -UseBasicParsing
if ($response.StatusCode -ne 200) { throw "Health check failed" }
Write-Host $response.Content
