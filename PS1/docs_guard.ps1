$root = Split-Path $PSScriptRoot -Parent
$files = Get-ChildItem "$root/agents" -Recurse -Filter "AGENT.md"
foreach ($f in $files) {
    $content = Get-Content $f.FullName
    if (-not ($content -match 'VERSION:')) {
        Write-Error "$($f.FullName) missing VERSION"
        exit 1
    }
}
Write-Host "docs_guard passed"
