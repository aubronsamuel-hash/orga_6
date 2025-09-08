# orga_6

## STEP 00 - Scaffold
Ce depot fournit l'ossature initiale pour les prochaines etapes.

### Scripts
```
PS> .\PS1\dev_up.ps1
PS> .\PS1\guards.ps1
PS> .\PS1\smoke.ps1
```

### CI
Le workflow GitHub Actions `checks` verifie les guards et l'absence de derive de l'arbre du depot.

## STEP 01 - Backend boot
Prerequis: Docker Desktop, PowerShell 7+.

1. Copier .env.example vers .env (dev_up.ps1 le fait automatiquement au besoin)
2. Lancer la stack:
   PS> .\PS1\dev_up.ps1
3. Tester l API:
   PS> .\PS1\smoke.ps1
4. Arreter:
   PS> .\PS1\dev_down.ps1

## STEP 02 - Modele de donnees
Cette etape ajoute les tables `users`, `missions` et `assignments` avec leurs endpoints CRUD.

### Tables
- `users`: email, full_name, created_at
- `missions`: title, location, created_at
- `assignments`: user_id, mission_id, role, start_at, end_at

### Utilisation API
```
PS> .\PS1\backend_tests.ps1
PS> .\PS1\seed.ps1
PS> .\PS1\smoke.ps1
```

Exemples rapides:
- POST /users `{ "email": "u@ex.com", "full_name": "User" }`
- GET /missions
- POST /assignments `{ "user_id": 1, "mission_id": 1, "role": "Tech", "start_at": "2025-09-08T10:00:00Z", "end_at": "2025-09-08T18:00:00Z" }`

### Utilisation locale rapide

Option A (conserver les données de développement) :
  - `setx POSTGRES_VERSION 15`
  - `docker compose up -d db api`

Option B (repartir de zéro, supprime les données dev) :
  - `docker compose down -v`
  - `docker volume prune` (optionnel)
  - `docker compose up -d --build db api`

Puis :
  - `pwsh -File PS1/dev_up.ps1`
  - `pwsh -File PS1/seed.ps1`
  - `pwsh -File PS1/backend_tests.ps1`
  - `pwsh -File PS1/smoke.ps1`

## Local dev bootstrap (Windows)

- Bootstrap host env:
```
pwsh -File PS1/dev_bootstrap.ps1
pwsh -File PS1/backend_tests.ps1
```

- Optional dev container (pytest inside image):
```
docker compose -f docker-compose.yml -f docker-compose.dev.yml --profile dev up -d --build db api-dev

# run tests inside container if needed

$id = docker ps --filter "label=com.docker.compose.service=api-dev" -q | head -n1
docker exec -it $id bash -lc "cd /app/backend && pytest -q"
```
