# Roadmap 31-40 - Observabilite v2, securite, performance, deploiements, analytics

Contrainte generale: ASCII only, Windows-first, aucun mock. CI durcie avec budgets perf et a11y.

---

### Etape 31 - Observabilite v2 (Alerting, SLO, status page)
Objectif:
- Passer de l'observation a l'alerte et a la fiabilite contractuelle.

Livrables:
- Grafana Alerting (latence p95 API, erreurs 5xx, queues).
- SLO: 99.5% apdex endpoint /health et /login.
- Status page public (staging) avec etat des composants.

Scripts:
- PS1/obs_alerts.ps1: provisionne alertes; PS1/status_sync.ps1: publie JSON status.

Tests:
- Simule panne -> alerte creee; SLO calcule.

CI Gates:
- job k6 SLO check; seuils refuses si depasses.

Acceptation:
- Alertes recues; page status refleche etats.

Notes:
- Pager simple via email pour dev.

---

### Etape 32 - Securite v2 (SSO, 2FA, Policies)
Objectif:
- Renforcer authz et posture securite.

Livrables:
- SSO SAML/OIDC (ex: AzureAD) optionnel; 2FA TOTP pour comptes locaux.
- Policies RBAC declaratives (fichiers YAML) chargees au boot.

Scripts:
- PS1/enable_2fa.ps1: active 2FA pour un user; PS1/rbac_lint.ps1: valide YAML policies.

Tests:
- Flux 2FA; SSO login; policies bloquent/autor.

CI Gates:
- rbac lint; DAST baseline (ZAP) sur staging preprod.

Acceptation:
- Compte local 2FA fonctionne; SSO pour org demo OK.

Notes:
- Recovery codes stockes en hash.

---

### Etape 33 - Performances et Cache (Redis) + budgets CI
Objectif:
- Ameliorer reponses listes (employees, shifts), budgets perf verifies en CI.

Livrables:
- Redis cache pour requetes lourdes; invalidation sur CRUD.
- k6 scripts sur endpoints critiques; budgets (p95 < 250ms, RPS cible).

Scripts:
- PS1/k6_run.ps1: lance tests charge; PS1/cache_clear.ps1.

Tests:
- Gains mesurables; tests unitaires invalidation OK.

CI Gates:
- k6 must-pass; budgets en YAML.

Acceptation:
- Dash perf montre ameliorations stables.

Notes:
- TTL adaptees; metrics cache hit/miss exposees.

---

### Etape 34 - Deploiements Blue/Green et Canary
Objectif:
- Deployer sans interruption et avec rollback rapide.

Livrables:
- Compose/prod: deux stacks (blue, green); Caddy route vers actif.
- Canary: pourcentage traffic (via Caddy routes) sur version N+1.

Scripts:
- PS1/deploy_bluegreen.ps1: switche actifs; rollback en 1 commande.

Tests:
- Health sur green avant switch; echec -> rollback auto.

CI Gates:
- deploy-prod (manual) + post-checks health.

Acceptation:
- Switch sans downtime; rollback verifie.

Notes:
- Tokens JWT valides cross-deploy.

---

### Etape 35 - Migrations et Feature Flags
Objectif:
- Maitriser changements schema et sorties progressives.

Livrables:
- Process migrations forward/back; test dry-run sur dump.
- Feature flags (fichiers ou service) pour masquer features.

Scripts:
- PS1/ff_set.ps1: active/desactive flags; PS1/migrate_dryrun.ps1.

Tests:
- Migrations idempotentes; flags iso comportement.

CI Gates:
- dry-run obligatoire avant merge; tests A/B.

Acceptation:
- Une feature deployee derriere flag; activation en staging OK.

Notes:
- Flags par org et par user si besoin.

---

### Etape 36 - Extensions et Webhooks v2 (App Center)
Objectif:
- Ouvrir la plateforme.

Livrables:
- Catalogue d'extensions (metadonnees, scopes, events); signatures webhooks v2; replays.
- UI: page App Center (dev/demo apps).

Scripts:
- PS1/app_register.ps1: declare extension; PS1/webhook_replay.ps1.

Tests:
- Scopes appliques; replays dedup.

CI Gates:
- security review minimal sur extensions (static checks).

Acceptation:
- Une extension demo recoit events et affiche un resume.

Notes:
- Limiter privileges par defaut.

---

### Etape 37 - i18n/l10n v1 (FR/EN)
Objectif:
- Rendre l'UI bilingue.

Livrables:
- Frontend: i18n messages JSON; switch langue; formats date/heure localises.
- Backend: messages d'erreur parametrables FR/EN.

Scripts:
- PS1/i18n_extract.ps1: extrait cles manquantes; PS1/i18n_check.ps1.

Tests:
- 100% cles traduites; fallback EN correct.

CI Gates:
- i18n check must-pass; a11y re-run.

Acceptation:
- User bascule FR/EN; dates affichees selon locale.

Notes:
- Eviter texte en dur.

---

### Etape 38 - Accessibilite AA sur pages coeur
Objectif:
- Conformite WCAG AA pour Login, Planning, Mission.

Livrables:
- Corrections ARIA, contrastes, focus; shortcuts clavier basiques.
- axe-core CI threshold (< 3 violations tolerees non bloquantes documentees).

Scripts:
- PS1/a11y_scan.ps1: lance axe-ci; sort rapport HTML.

Tests:
- Tests e2e clavier: navigation sans souris.

CI Gates:
- a11y threshold enforce.

Acceptation:
- Rapports a11y verts; ergonomie clavier OK.

Notes:
- Documenter exceptions.

---

### Etape 39 - Analytics & KPIs v1
Objectif:
- Tableaux de bord: taux d'occupation, heures sup, cout projet.

Livrables:
- Backend: vues materialisees ou ETL leger; API /analytics/*.
- Frontend: dashboard avec filtres (periode, equipe, site).

Scripts:
- PS1/etl_run.ps1: rafraichit vues; PS1/analytics_export.ps1.

Tests:
- Calculs testes (golden values); perf acceptable.

CI Gates:
- queries budgets (max time) sous seuil.

Acceptation:
- Manager lit KPIs et exporte CSV.

Notes:
- Eviter PII dans analytics.

---

### Etape 40 - Backup/DR v2 et Chaos tests
Objectif:
- Etre pret pour incidents.

Livrables:
- Runbook DR (RPO/RTO); exercices de restauration trimestriels.
- Toxiproxy pour simuler latence/pannes DB; tests resiliences.

Scripts:
- PS1/drill_restore.ps1: simule panne et restaure dump recent; PS1/toxiproxy_scenarios.ps1.

Tests:
- Drill reussi sous temps cible; app degradee mais fonctionnelle.

CI Gates:
- scenario toxiproxy smoke must-pass.

Acceptation:
- Equipe execute un drill documente et reussit sous objectif.

Notes:
- Journaliser temps de reprise.
