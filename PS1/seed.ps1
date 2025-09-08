#!/usr/bin/env pwsh
# Seed minimal: 2 users, 1 mission, 1 assignment
$ErrorActionPreference = "Stop"

$BaseUrl = $env:SEED_BASEURL
if (-not $BaseUrl) { $BaseUrl = "http://localhost:8000" }

Write-Host "Seeding against $BaseUrl"

function PostJson {
  param([string]$Path,[hashtable]$Body)
  $uri = "$BaseUrl$Path"
  $json = ($Body | ConvertTo-Json -Depth 5)
  Invoke-RestMethod -Method Post -Uri $uri -Body $json -ContentType "application/json"
}

$u1 = PostJson -Path "/users" -Body @{ email="sam@example.com"; full_name="Samuel Aubron" }
$u2 = PostJson -Path "/users" -Body @{ email="mathis@example.com"; full_name="Mathis Barclais" }

$m1 = PostJson -Path "/missions" -Body @{ title="Bobino - Montage Dimanche"; location="Paris" }

$start = (Get-Date).Date.AddHours(10).ToString("s") + "Z"
$end   = (Get-Date).Date.AddHours(18).ToString("s") + "Z"
$a1 = PostJson -Path "/assignments" -Body @{ user_id=$u1.id; mission_id=$m1.id; role="Regisseur"; start_at=$start; end_at=$end }

Write-Host "Seed done:"
Write-Host "User1 id=$($u1.id) email=$($u1.email)"
Write-Host "User2 id=$($u2.id) email=$($u2.email)"
Write-Host "Mission id=$($m1.id) title=$($m1.title)"
Write-Host "Assignment id=$($a1.id)"
