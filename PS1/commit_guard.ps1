$commit = git log -1 --pretty=%s
if ($commit -match '(?i)wip') {
    Write-Error 'Commit message contains wip'
    exit 1
}
if ($commit -notmatch '^(feat|fix|docs|style|refactor|perf|test|chore|ci|build|revert|release):') {
    Write-Error 'Commit message not Conventional'
    exit 1
}
Write-Host 'commit_guard passed'
