$root = Split-Path $PSScriptRoot -Parent
$items = Get-ChildItem $root -Recurse -Force |
    Where-Object { $_.FullName -notmatch '\.git' } |
    ForEach-Object { $_.FullName.Substring($root.Length + 1).Replace('\\','/') } |
    Sort-Object
$lines = @('# Repository Tree','') + $items
$path = "$root/docs/REPO_TREE.md"
$lines | Set-Content $path
Write-Host "repo_tree generated"
