Param(
  [switch]$Headed
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Move to frontend folder
$root = Split-Path -Parent $PSCommandPath
$repo = Split-Path $root
$frontend = Join-Path $repo "frontend"
Set-Location $frontend

Write-Host "[frontend_tests] npm ci" -ForegroundColor Cyan
npm ci

Write-Host "[frontend_tests] typecheck" -ForegroundColor Cyan
npm run typecheck

Write-Host "[frontend_tests] lint" -ForegroundColor Cyan
npm run lint

Write-Host "[frontend_tests] unit tests" -ForegroundColor Cyan
npm run test

Write-Host "[frontend_tests] build" -ForegroundColor Cyan
npm run build

Write-Host "[frontend_tests] e2e install browsers" -ForegroundColor Cyan
npm run e2e:install

Write-Host "[frontend_tests] preview server" -ForegroundColor Cyan
$preview = Start-Process -FilePath "npm" -ArgumentList "run","preview" -NoNewWindow -PassThru
Start-Sleep -Seconds 2

try {
  Write-Host "[frontend_tests] e2e" -ForegroundColor Cyan
  if ($Headed) {
    npx playwright test --headed
  } else {
    npx playwright test --reporter=line
  }
}
finally {
  Write-Host "[frontend_tests] stop preview" -ForegroundColor Yellow
  if ($preview -and -not $preview.HasExited) { $preview.Kill() }
}

Write-Host "[frontend_tests] OK" -ForegroundColor Green
