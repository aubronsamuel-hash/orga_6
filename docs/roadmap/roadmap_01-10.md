# Roadmap Orga – Vue d'ensemble

Ce dossier decrit la trajectoire de livraison fonctionnelle, sans mock, avec criteres d'acceptation, scripts Windows-first (PowerShell 7+) et verifications CI. Chaque etape est concue comme un delta minimal mais **exploitable immediatement** par l'utilisateur.

## Fichiers
- `docs/roadmap/index.md` (ce fichier)
- `docs/roadmap/roadmap_01-10.md`

## Validation generale
- Scripts PowerShell dans `PS1/`
- Docker Compose (api, web, db, mailhog)
- CI GitHub Actions: jobs `backend`, `frontend`, `a11y`, `e2e-smoke`, `checks`
- Guards: `docs_guard`, `roadmap_guard`, `any_guard`, `commit_guard`, `env_guard`

## Liens
- Suivre les 10 premieres etapes ici: voir `roadmap_01-10.md`.

---

# Roadmap 01-10 – Sommaire
1. Backend boot: FastAPI, settings, Alembic, health, Compose
2. Modele de donnees: User, Mission, Assignment (Planning)
3. Auth & Sessions: JWT (Bearer) + password hashing
4. Frontend scaffold + Page Login complete
5. Planning v1: liste employes (avatar) + affichage shifts semaine + creation basique
6. Disponibilites v1: API + UI
7. Detection de conflits v1
8. Notifications e-mail dev via MailHog, prod via SMTP
9. Import/Export CSV Employes v1
10. Journalisation (Audit Log v1)

---

### Etape 01 - Backend boot
Objectif:
- API FastAPI minimale avec `/health` et base de donnees Postgres via Alembic.

Livrables:
- FastAPI + settings via dataclass
- Docker Compose (db, api)
- Scripts PowerShell `dev_up`, `dev_down`, `backend_tests`, `smoke`
- Migration Alembic `0001_init`
- Test `tests/test_health.py`

Scripts:
- PS> .\PS1\dev_up.ps1
- PS> .\PS1\backend_tests.ps1
- PS> .\PS1\smoke.ps1
- PS> .\PS1\dev_down.ps1

Tests:
- `pytest` dans le conteneur api

CI Gates:
- Job `backend`

Acceptation:
- `GET /health` retourne `{ "status": "ok" }`

Notes:
- Focalise sur compatibilite Windows et CI Linux.
