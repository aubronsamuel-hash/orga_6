# From roadmap: roadmap_01-10.md
# Full title: Frontend scaffold + Page Login complete

# AGENT SPEC

VERSION: 0.2.1
CURRENT_TASK: agents/STEP_04_Frontend_scaffold___Page_Login_complete_AGENT.md
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
- Frontend: React, TypeScript, Vite, Tailwind, local shadcn-style components, Playwright, Vitest
- Infra: Docker, Docker Compose, GitHub Actions
- Scripts: PowerShell 7+, Bash (in CI)

---

# DEFINITION_OF_DONE (DoD)

- Frontend builds with `npm run build` and serves `index.html` OK
- Page Login accessible at `/login`, validates email+password, calls `${VITE_API_URL}/auth/login`
- On success, token stored in `localStorage` then redirect to `/` (placeholder)
- Lint/type/tests pass locally and in CI
- Local Gates: `frontend_tests.ps1` executes without error
- Docs updated (README FR) if vars changed
- Guards pass (docs_guard, roadmap_guard, any_guard, commit_guard, env_guard, changelog_guard, script_guard)

---

# VALIDATION_SEQUENCE

1. Local scripts: `PS1/frontend_tests.ps1`
2. CI required jobs: frontend, a11y (basic), e2e-smoke
3. Security: npm audit (no HIGH severity)
4. Observability: n/a (frontend only)
5. Manual review checklist completed

---

# REVIEW_CHECKLIST
- Conventional Commits respected
- Coverage: frontend >= 80% (unit tests cover Login form logic)
- No unapproved TS `any`
- `.env.example` exposes `VITE_API_URL`
- Rollback plan documented in PR

---

# STEP TEMPLATE FILLED

## STEP_ID: STEP_04_Frontend_scaffold_Login
GOAL:
- Deliver a ready-to-run frontend skeleton with a production-grade Login page.

SCOPE:
- Vite + React + TS scaffold
- Tailwind configured
- Local shadcn-style UI primitives (Button, Input, Label, Card)
- Routing with `/login`
- Login form with basic validation and API call
- Unit + e2e tests, PS1 script

OUT_OF_SCOPE:
- Full authenticated app shell, RBAC, refresh tokens, password reset

ACCEPTANCE_CRITERIA:
- `npm run typecheck`, `npm run lint`, `npm run test`, `npm run build` succeed
- e2e test passes against dev server
- `.env.example` contains `VITE_API_URL=http://localhost:8000`
- Form shows validation errors and disables button while submitting

DELIVERABLES:
- Code: frontend scaffold, Login page, UI components
- Tests: Vitest unit, Playwright e2e
- Docs: README snippet for frontend
- Scripts: `PS1/frontend_tests.ps1`

GUARDS:
- docs_guard, roadmap_guard, any_guard, commit_guard, env_guard, changelog_guard, script_guard

LOCAL_COMMANDS (Windows-first):
- PS> .\PS1\frontend_tests.ps1

CI_JOBS_REQUIRED:
- frontend, a11y, e2e-smoke

MIGRATIONS:
- DB: none
- Data: none
- Config: `.env.example` new var VITE_API_URL

ROLLBACK:
- Revert frontend folder changes, keep backend unaffected

NOTES:
- Windows-first compatibility required
- CI expected duration < 5 min per job

---

# PR DESCRIPTION TEMPLATE

## Step
STEP_ID: STEP_04_Frontend_scaffold_Login

## Goal
- Ship a working Login page atop a clean frontend scaffold.

## Acceptance Criteria
- Build OK, tests pass, e2e login flow covered.

## Deliverables
- Code: Vite scaffold, Login page, UI components
- Tests: Vitest unit, Playwright e2e
- Docs: README update
- Scripts: PS1/frontend_tests.ps1

## Validation
- Local: PS script OK
- CI: frontend, a11y, e2e-smoke green
- Guards: all pass

## Impacts Infra/DevOps
- Adds `.env.example` for frontend var `VITE_API_URL`

## Rollback Plan
- Revert PR; app returns to pre-STEP_04 state

## Agent Updates
- VERSION bump -> 0.2.1
- CURRENT_TASK updated
- CHANGELOG updated

---

# CHANGELOG
- 0.2.1 (2025-09-08): add STEP 04 scaffold and login; tests and PS1 script
- 0.2.0: prior
- 0.1.0: init
