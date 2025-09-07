# AGENT SPEC

VERSION: 0.1.0
CURRENT_TASK: agents/STEP_00_scaffold/AGENT.md

CONTEXT_DOCS:
- docs/roadmap/index.md
- docs/roadmap/roadmap_01-10.md
- README.md

LANGUAGE_STYLE:
- Prompts, code, commits, PRs: English
- User docs, README: French
- ASCII only. Deterministic outputs.

CONSTRAINTS:
- No secrets in repo. Use .env.example only.
- Windows-first (PowerShell 7+), but CI parity on Linux.
- No TODOs left in committed code.
- Respect acceptance criteria per step (Definition of Done).
- Small, reversible, testable deltas.

INPUTS_EXPECTED:
- Active roadmap file(s) referenced in CONTEXT_DOCS
- .env.example (no secrets)
- CI workflows under .github/workflows

OUTPUTS_REQUIRED:
- Code + tests + docs that compile and run
- Roadmap updated if scope changes
- CHANGELOG entry in this file on every edit of rules or current task

TOOLS_ALLOWED:
- Backend: FastAPI, SQLAlchemy, Alembic, psycopg
- Frontend: React, TypeScript, Vite, Tailwind, shadcn/ui, Playwright
- Infra: Docker, Docker Compose, Caddy (optional), GitHub Actions
- Scripts: PowerShell 7+, Bash (in CI)

DEFINITION_OF_DONE (DoD):
- Lint/type/tests pass locally and in CI
- Docs updated (README FR + roadmap) for any user-facing change
- No breaking change to previous steps unless a migration + rollback are provided
- Guards pass (docs_guard, roadmap_guard, any_guard, commit_guard, env_guard)

VALIDATION_SEQUENCE:
1) Local scripts: dev_up, lint, type, tests (backend, frontend)
2) CI required jobs green: backend, frontend, a11y, e2e-smoke
3) Security: pip-audit and npm audit with no high severity
4) Observability: health endpoint OK and basic metrics route reachable
5) Manual review checklist completed

REVIEW_CHECKLIST:
- Conventional Commits respected
- Coverage threshold met (backend >= 80%, frontend >= 70% by default)
- No unapproved TypeScript any (must be marked with // ok-any: rationale)
- .env.example coherent and README updated if vars changed
- Roadmap sections in sync with delivered scope

CHANGELOG:
- 0.1.0 (init): initial agent scaffold and step template

---

# STEP TEMPLATE

## STEP_ID: STEP_XX_title
GOAL:
- What value is delivered to the user.

SCOPE:
- Bounded tasks included in this step.
- Explicitly list what is out of scope.

ACCEPTANCE_CRITERIA:
- Bullet list of verifiable checks (functional, tests, docs, guards).

DELIVERABLES:
- Code:
- Tests:
- Docs:
- Scripts:

GUARDS:
- docs_guard: pass
- roadmap_guard: pass
- any_guard: pass
- commit_guard: pass
- env_guard: pass

LOCAL_COMMANDS (Windows-first):
- PS> .\PS1\dev_up.ps1
- PS> .\PS1\backend_tests.ps1
- PS> .\PS1\frontend_tests.ps1

CI_JOBS_REQUIRED:
- backend, frontend, a11y, e2e-smoke

MIGRATIONS (if needed):
- DB:
- Data:
- Config:

ROLLBACK:
- Clear steps to revert this step with minimal risk.

NOTES:
- Design constraints, risks, follow-ups.

---

# STEP_00_scaffold

GOAL:
- Establish minimal, verifiable skeleton for agent-driven delivery.

SCOPE (included):
- Add this AGENT.md and wire the rules.
- Ensure roadmap index and first file exist.
- Provide PS scripts placeholders for local workflows.

OUT OF SCOPE:
- Feature code beyond healthcheck placeholders.

ACCEPTANCE_CRITERIA:
- AGENT.md present, valid ASCII, version set to 0.1.0.
- docs/roadmap/index.md exists and references the next 10-step file.
- PS1 folder exists with stub scripts (dev_up.ps1, backend_tests.ps1, frontend_tests.ps1).
- CI placeholder workflows exist (backend.yml, frontend.yml, checks.yml) and run successfully with no-op.
- Guards exist and fail if contract is broken (see Guard Policies).

DELIVERABLES:
- Code: stubs and skeletons only
- Tests: smoke (no-op) confirming pipelines execute
- Docs: this AGENT.md, roadmap index pointer, README FR section "Roadmap et Automatisation"
- Scripts: PS1 stubs listed below

LOCAL_COMMANDS (Windows-first):
- PS> .\PS1\dev_up.ps1
- PS> .\PS1\backend_tests.ps1
- PS> .\PS1\frontend_tests.ps1

CI_JOBS_REQUIRED:
- backend (no-op lint/test), frontend (no-op lint/test), checks (guards)

MIGRATIONS:
- None

ROLLBACK:
- Delete AGENT.md and CI stubs; remove PS1 stubs; keep repo clean.

NOTES:
- Keep this step minimal and green before moving on.

---

# PR DESCRIPTION TEMPLATE (paste into PR body)

## Step
STEP_ID: STEP_0N_short_title

## Goal
- ...

## Acceptance Criteria
- ...

## Deliverables
- Code:
- Tests:
- Docs:
- Scripts:

## Migrations
- DB:
- Config:
- Data:

## Validation
- Local: PS scripts run OK
- CI: backend, frontend, a11y, e2e-smoke green
- Guards: docs_guard, roadmap_guard, any_guard, commit_guard, env_guard pass

## Agent Updates
- AGENT.md VERSION: bump to X.Y.Z
- CURRENT_TASK: updated to agents/STEP_0N_.../AGENT.md
- CHANGELOG: +1 line

---

# Guard Policies (to be enforced by CI)

## docs_guard
- Fails if AGENT.md changes without VERSION bump and CHANGELOG addition.
- Fails if README FR mentions features not present in code (basic regex scan allowed).

## roadmap_guard
- Fails if a STEP_ID referenced in AGENT.md is missing from docs/roadmap.
- Fails if CURRENT_TASK path does not exist.

## any_guard (TypeScript)
- Fails on any "any" unless the line contains "// ok-any:" followed by a brief rationale.

## commit_guard
- Fails if commits do not follow Conventional Commits or contain "wip" in subject.

## env_guard
- Fails if a new env var is used in code but missing in .env.example and README.

---

# PowerShell Stubs (place under PS1/)

## PS1/dev_up.ps1
```
param([switch]$Rebuild)
if ($Rebuild) { docker compose build --no-cache }
docker compose up -d
Write-Host "Dev stack is up"
```

## PS1/backend_tests.ps1
```
Write-Host "Running backend lint/type/tests"
# TODO: replace with real commands in STEP_01
exit 0
```

## PS1/frontend_tests.ps1
```
Write-Host "Running frontend lint/type/tests"
# TODO: replace with real commands in STEP_02
exit 0
```

## PS1/agent_bump.ps1
```
param(
  [Parameter(Mandatory=$true)][string]$StepId,
  [Parameter(Mandatory=$true)][string]$NewVersion
)
$path = Join-Path $PSScriptRoot "..\agents\AGENT.md"
$agent = Get-Content -Raw -Path $path
$agent = $agent -replace "(?m)^VERSION:\s*.*$","VERSION: $NewVersion"
$agent = $agent -replace "(?m)^CURRENT_TASK:\s*.*$","CURRENT_TASK: agents/$StepId/AGENT.md"
$ts = Get-Date -Format "yyyy-MM-dd"
if ($agent -notmatch "(?ms)^CHANGELOG:") { $agent += "`r`nCHANGELOG:`r`n- $NewVersion ($ts): bump to $StepId`r`n" }
else { $agent = $agent -replace "(?ms)^CHANGELOG:\s*(.*?)$","CHANGELOG:`r`n$1`r`n- $NewVersion ($ts): bump to $StepId" }
Set-Content -Path $path -Value $agent -NoNewline
Write-Host "Updated AGENT.md to $NewVersion, CURRENT_TASK=$StepId"
```

---

# Next Step Proposal
- After STEP_00 is merged, set CURRENT_TASK to agents/STEP_01_backend_boot/AGENT.md and bump VERSION to 0.1.1.
- Implement backend health endpoint, DB connection, and Alembic init with passing tests.

