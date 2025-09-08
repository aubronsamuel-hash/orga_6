# Roadmap 11-20 (definitif)

Contrainte generale: ASCII only, Windows-first (PowerShell 7+), aucun mock. Chaque etape livre de la valeur immediatement utilisable, avec scripts et CI.

---

## Etape 11 - Organisations, Equipes, RBAC v1
Objectif: Multi-organisation (tenants) et controle d'acces par roles.

Livrables:
- Backend: tables `organisation`, `team`, `user_org_role` (roles: ADMIN, MANAGER, TECH), `user_team`.
- Scoping: toutes les requetes CRUD (Users, Missions, Shifts, Availability) filtrees par `org_id`.
- Middleware: extraction `org_id` via header `X-Org-Id` ou du profil user; interdiction d'acceder a une autre org.
- Frontend: switch d'organisation si l'utilisateur appartient a plusieurs.

Tests:
- Acces deny si org differente; MANAGER peut CRUD shifts, TECH lecture seulement.

Acceptation:
- Un ADMIN cree une org, ajoute un user MANAGER et TECH; le MANAGER gere le planning de son org, le TECH ne peut pas editer.

---

## Etape 12 - Medias (avatars) et fichiers
Objectif: Gestion des avatars employes et pieces jointes simples.

Livrables:
- Dev: service MinIO (S3-compatible) dans Compose; bucket `media`.
- Backend: endpoint `POST /media/upload` (auth), redimensionnement avatar (carre, 256px), stockage S3; URL signee pour telechargement.
- Frontend: upload avatar depuis la fiche employe; affichage avatar dans Planning.

Tests:
- Upload PNG/JPG <= 2MB; verification redimensionnement; URL signee expiree refusee.

Acceptation:
- Un user upload son avatar; la grille Planning affiche les avatars stockes.

---

## Etape 13 - Calendriers ICS (export/import)
Objectif: Synchronisation basique avec calendriers externes.

Livrables:
- Export: endpoint public avec token par user `GET /calendar/{token}.ics` (read-only); options: calendrier global org, par equipe, par user.
- Import: `POST /calendar/import` pour charger un fichier .ics et creer des shifts (role/mission par defaut parametres).
- Timezone: normalisation UTC en DB; generation ICS avec TZ Europe/Paris.

Tests:
- Export ICS importe dans Google Calendar/Apple sans erreurs; import .ics cree des shifts a la bonne heure.

Acceptation:
- Un manager exporte le planning hebdo en ICS et l'ajoute a son Google Calendar; les evenements sont corrects.

---

## Etape 14 - Webhooks & Integrations (Slack/Telegram)
Objectif: Reagir aux evenements et notifier les equipes.

Livrables:
- Backend: table `webhook_endpoint` (url, secret, events[]), signature HMAC-SHA256, retries exponentiels.
- Evenements: shift.created/updated/deleted, availability.created/updated/deleted.
- Integrations: bot Telegram simple (env `TELEGRAM_BOT_TOKEN`) ou webhook Slack.
- Frontend: UI de configuration des webhooks par org.

Tests:
- Signature verifiee cote recepteur de test; retry sur 500; idempotence via `event_id`.

Acceptation:
- A la creation d'un shift, un message Slack/Telegram est recu avec les details.

---

## Etape 15 - Temps & Paie basics (intermittents)
Objectif: Premiers calculs temps/cachets et exports administratifs.

Livrables:
- Backend: entites `timesheet` (user_id, mission_id, start_at, end_at, type: REPETITION/SPECTACLE/MONTAGE/DEMONTAGE, rate_rules), calcul duree payee, arrondis (5 min), heures de nuit.
- Exports: CSV `paie_mensuelle.csv` par org et mois (colonnes utiles AEM/URSSAF, sans donner conseils fiscaux).
- Frontend: page "Temps & Paie" recap mensuel par user, export bouton.

Tests:
- Durees calculees correctement (cas bords: chevauchement minuit, changement heure ete/hiver Europe/Paris).

Acceptation:
- Pour un mois donne, export CSV coherent avec les shifts/timesheets saisis.

---

## Etape 16 - Planning v2 (recurrence, templates)
Objectif: Acceleration de la planification.

Livrables:
- Backend: `shift_template` (role, duree, libelle), duplication semaine -> semaine, recurrence simple (hebdomadaire n occurrences).
- Frontend: UI copier/coller semaine, appliquer template a une equipe.

Tests:
- Recurrence cree n occurrences correctes sans conflits; duplication respecte org/team.

Acceptation:
- Un manager duplique la semaine N vers N+1 et gagne du temps; modifications possibles post-duplication.

---

## Etape 17 - Observabilite (Prometheus/Grafana/Loki)
Objectif: Visibilite sante, perf, logs.

Livrables:
- Compose: services prometheus, grafana, loki, promtail.
- Backend: /metrics Prometheus (FastAPI instrumentation), logs JSON structurees (correlation id), traces OpenTelemetry (optionnel dev).
- Dashboards Grafana pre-configures (latence API p50/p95, erreurs, rq/s).

Tests:
- Scrape Prometheus OK; tableau de bord montre health et latence post-charge legere.

Acceptation:
- Page Grafana accessible en dev; metriques et logs remontent en temps reel.

---

## Etape 18 - Securite baseline
Objectif: Renforcer la posture securite.

Livrables:
- Backend: headers securite (CSP basique, HSTS en prod via Caddy), rate limiting par IP, verification taille requete, validation stricte schemas.
- CI: trivy scan images Docker; dependabot ou equivalent; SAST basique (bandit pour Python, eslint-plugin-security pour TS).
- Secrets: guide d'exploitation (README) et variables .env.example structurees, rotation du JWT_SECRET.

Tests:
- Endpoints refusent payloads surdimensionnes; rate limiting fonctionne.

Acceptation:
- Scans CI verts (sans HIGH/CRITICAL); headers visibles en prod/staging.

---

## Etape 19 - Backups & Migrations ops
Objectif: Securiser la donnees et les changements schema.

Livrables:
- PS: `PS1/backup_db.ps1` (pg_dump -> `backups/` datestampe), `PS1/restore_db.ps1` (pg_restore), retention simple (7 derniers dumps).
- Alembic: check pre-migration (lock table), offline/online scripts; rollback documente.
- CI: dry-run migration sur dump exemple.

Tests:
- Backup/restore round-trip local OK; migration qui echoue restore l'etat precedent.

Acceptation:
- Un backup journalier est genere en dev; un restore controlle remet la DB en etat.

---

## Etape 20 - Staging avec Caddy TLS
Objectif: Environnement preprod proche prod.

Livrables:
- `deploy/staging/compose.yaml`, Caddyfile TLS (Let's Encrypt), domaines env, healthchecks.
- CI: job manuel `deploy-staging` qui pousse les images et deploie; zap-baseline (OWASP ZAP) sur staging.
- Runbook `docs/runbooks/staging.md` (start/stop, logs, rollbacks).

Tests:
- Health API et frontend accessibles en HTTPS; ZAP-baseline sans alertes hautes.

Acceptation:
- URL publique staging operationnelle; parcours login -> planning OK.

