$guards = @(
    'docs_guard.ps1',
    'roadmap_guard.ps1',
    'commit_guard.ps1',
    'env_guard.ps1',
    'changelog_guard.ps1',
    'script_guard.ps1'
)
foreach ($g in $guards) {
    Write-Host "running $g"
    $LASTEXITCODE = 0
    & "$PSScriptRoot/$g"
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}
Write-Host "Guards passed"
