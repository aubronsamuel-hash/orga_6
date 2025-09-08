[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Write-Error 'git not found in PATH.'
}

$subject = (git log -1 --pretty=%s)
if (-not $subject) {
  Write-Error 'Could not read last commit message.'
}

if ($subject -match '^(Merge( pull request)? )') {
  Write-Host 'commit_guard note: merge commit detected; skipping Conventional Commits check.'
  exit 0
}

$pattern = '^(build|chore|ci|docs|feat|fix|perf|refactor|revert|style|test)(\(.+\))?:\s.+'
if ($subject -notmatch $pattern) {
  Write-Error ('Commit message not Conventional Commits: ' + $subject)
}
if ($subject -match '(?i)\bwip\b') {
  Write-Error 'Commit message contains forbidden token: wip'
}

Write-Host 'commit_guard OK'
