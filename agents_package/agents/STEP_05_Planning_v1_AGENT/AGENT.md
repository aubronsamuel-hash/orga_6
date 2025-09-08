# From roadmap: auto
# Full title: 05 - Planning v1: liste employes (avatar) + affichage shifts semaine + creation basique

# AGENT SPEC

VERSION: 0.2.0  
CURRENT_TASK: agents/STEP_00_scaffold/AGENT.md  
OWNER: Lead Engineer (responsable CI/CD et roadmap)  

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
- Windows-first (PowerShell 7+), CI parity Linux.
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

---

# DEFINITION_OF_DONE (DoD)

- Lint/type/tests pass locally and in CI  
- Local Gates: all PS1 scripts execute without error (dev_up, backend_tests, frontend_tests, smoke)  
- Docs updated (README FR + roadmap) for any user-facing change  
- No breaking change to previous steps unless migration+rollback provided  
- Guards pass (docs_guard, roadmap_guard, any_guard, commit_guard, env_guard, changelog_guard, script_guard, schema_guard)  

---

# VALIDATION_SEQUENCE

1. Local scripts: dev_up, lint, type, tests, smoke (Windows-first)  
2. CI required jobs: backend, frontend, a11y, e2e-smoke  
3. Security: pip-audit & npm audit (no HIGH severity)  
4. Observability: health endpoint + /metrics stub reachable  
5. Manual review checklist completed  

---

# REVIEW_CHECKLIST

- Conventional Commits respected  
- Coverage: backend >= 85%, frontend >= 80%  
- No unapproved TS `any` (must have // ok-any: rationale)  
- .env.example coherent, README updated if vars changed  
- Roadmap sections in sync with delivered scope  
- Rollback plan documented in PR  

---

# GUARD POLICIES

## docs_guard
- Fail if AGENT.md changes without VERSION bump + CHANGELOG entry  
- Fail if README FR mentions features not present in code  

## roadmap_guard
- Fail if a STEP_ID referenced in AGENT.md is missing in docs/roadmap  
- Fail if index.md references a roadmap file missing in repo  

## any_guard (TypeScript)
- Fail on `any` unless line has // ok-any: rationale  

## commit_guard
- Fail if commit message not Conventional Commits or contains "wip"  

## env_guard
- Fail if new env var used in code but missing in .env.example + README  

## changelog_guard
- Fail if CHANGELOG not enriched after AGENT.md changes  

## script_guard
- Fail if any PS1 script contains "TODO:"  

## schema_guard
- Fail if DB schema drift detected (Alembic migration not applied)  

---

# STEP TEMPLATE

## STEP_ID: STEP_XX_title
GOAL:
- Value delivered to user

SCOPE:
- Explicit tasks included  
- Out of scope listed  

ACCEPTANCE_CRITERIA:
- Bullet list of verifiable checks (functional, tests, docs, guards)  

DELIVERABLES:
- Code:  
- Tests:  
- Docs:  
- Scripts:  

GUARDS:
- docs_guard, roadmap_guard, any_guard, commit_guard, env_guard, changelog_guard, script_guard, schema_guard  

LOCAL_COMMANDS (Windows-first):
- PS> .\PS1\dev_up.ps1  
- PS> .\PS1\backend_tests.ps1  
- PS> .\PS1\frontend_tests.ps1  
- PS> .\PS1\smoke.ps1  

CI_JOBS_REQUIRED:
- backend, frontend, a11y, e2e-smoke  

MIGRATIONS:
- DB:  
- Data:  
- Config:  

ROLLBACK:
- Steps to revert with minimal risk  

NOTES:
- Windows-first compatibility required  
- CI expected duration <5 min per job  

---

# PR DESCRIPTION TEMPLATE

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
- Local: PS scripts run OK (dev_up, tests, smoke)  
- CI: backend, frontend, a11y, e2e-smoke green  
- Guards: docs_guard, roadmap_guard, any_guard, commit_guard, env_guard, changelog_guard, script_guard, schema_guard pass  

## Impacts Infra/DevOps
- Compose, CI, scripts changes documented  

## Rollback Plan
- ...  

## Agent Updates
- VERSION bump  
- CURRENT_TASK updated  
- CHANGELOG updated  

---

# CHANGELOG
- 0.2.0 (2025-09-08): strengthen guards, stricter validation, PR template enriched, OWNER added  
- 0.1.0 (init): initial agent scaffold and step template
