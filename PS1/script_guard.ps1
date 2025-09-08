$root = Split-Path $PSScriptRoot -Parent
$files = Get-ChildItem "$root/PS1" -Filter '*.ps1' -Recurse
foreach ($f in $files) {
    if ($f.Name -eq 'script_guard.ps1') { continue }
    if (Select-String -Path $f.FullName -Pattern 'TODO:' -SimpleMatch) {
        Write-Error "$($f.Name) contains TODO"
        exit 1
    }
}
Write-Host 'script_guard passed'
