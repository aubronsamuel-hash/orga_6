# Roadmap 21-30 - Facturation, mobile, IA planning, docs, paie FR

Contrainte generale: ASCII only, Windows-first (PowerShell 7+), aucun mock. CI: backend, frontend, e2e-smoke, a11y si concerne, scans securite.

---

### Etape 21 - Facturation et Abonnements (Stripe) multi-tenant
Objectif:
- Activer la monetisation: abonnements par organisation, plan Basic/Pro/Enterprise, essais, factures PDF Stripe.

Livrables:
- Backend: endpoints /billing/webhooks, /billing/portal; modele subscription(plan, status, current_period_end).
- Frontend: page Billing (etat, bouton Manage via portail Stripe), bandeau plan dans Settings.
- Docs: pricing.md (FR) et mentions legales basiques.

Scripts:
- PS1/stripe_dev.ps1: creation produits/prix de test via CLI Stripe; set webhooks secret en .env.

Tests:
- Webhook signature verifiee; changement de plan met a jour RBAC limites; portail accessible.

CI Gates:
- SAST; integration tests webhook (mock signature) verts.

Acceptation:
- Passage d'un plan a un autre visible; organisation limitee selon plan.

Notes:
- Pas de stockage de cartes chez nous; portail Stripe gere cela.

---

### Etape 22 - RGPD et Vie Privee v1
Objectif:
- Conformite de base: export donnees user, suppression compte, retention configurable, registre des traitements.

Livrables:
- Backend: /gdpr/export (JSON zip), /gdpr/delete (asynchrone avec grace period), anonymisation audit_log.
- Docs: politique de confidentialite (FR), DPA template.
- UI: page Profil -> bouton Export/Deletion avec confirmation.

Scripts:
- PS1/gdpr_export.ps1: recupere export local; PS1/gdpr_purge.ps1: tache d'anonymisation planifiee.

Tests:
- Export contient toutes les entites liees; delete remplace PII par tokens anonymes; retention appliquee.

CI Gates:
- tests backend RGPD >= 85% coverage module privacy.

Acceptation:
- Export/deletion fonctionnent sur user demo; logs audit conformes.

Notes:
- Traiter demandes sous 30 jours; horodatage UTC.

---

### Etape 23 - PWA v1 (installable, offline lecture)
Objectif:
- Utilisation mobile: PWA installable, icones, offline read-only pour planning.

Livrables:
- Frontend: manifest.json, service worker (workbox), cache routes Planning read-only.
- UI: add to home screen prompt; skeleton loading offline.

Scripts:
- PS1/pwa_build.ps1: build + genere icones multi-tailles.

Tests:
- Lighthouse PWA score >= 90; offline affiche derniere semaine en cache.

CI Gates:
- a11y + lighthouse-ci budget minimal.

Acceptation:
- PWA installable sur Chrome et Android; planning consultable sans reseau.

Notes:
- Ecriture offline (sync) en v2.

---

### Etape 24 - Auto-plan v1 (heuristiques)
Objectif:
- Proposer une affectation automatique simple selon dispo/skills/heures max.

Livrables:
- Backend: module autoplanner heuristique (glouton + contraintes basiques) expose POST /autoplan/week.
- UI: bouton "Proposer planning" avec diff a valider avant application.

Scripts:
- PS1/autoplan_week.ps1: lance un calcul sur seed et ecrit diff JSON.

Tests:
- Respect des indispos; pas de doublons; heures max respectees.

CI Gates:
- coverage module autoplan >= 85%; k6 smoke sur endpoint (latence p95 <= 300ms pour 100 employes).

Acceptation:
- Manager obtient une proposition coherente et peut l'appliquer.

Notes:
- IA/ML plus tard; ici regles deterministes.

---

### Etape 25 - Competences et Matching
Objectif:
- Associer des skills aux users et aux missions; matching dans autoplan.

Livrables:
- Backend: tables skill, user_skill(level), mission_skill(required_level).
- UI: editor de competences sur fiche employe et mission.

Scripts:
- PS1/seed_skills.ps1: ajoute 10 skills (lumiere, son, HF, plateau...).

Tests:
- Matching refuse user sous le niveau requis; tri par fit score.

CI Gates:
- backend tests verts; coverage sur matching.

Acceptation:
- Autoplan tient compte des skills; UI montre raisons d'eligibilite.

Notes:
- Normaliser niveaux 1..5.

---

### Etape 26 - Documents RH: Ordre de mission, Feuille de service, Attestations
Objectif:
- Generer PDF RH courants (ordre de mission, feuille de service journee, attestation de presence).

Livrables:
- Backend: templates PDF (WeasyPrint ou equivalent), endpoints /docs/mission/{id}.pdf.
- UI: telechargement depuis mission.

Scripts:
- PS1/gen_docs.ps1: genere PDFs sur seed dans out/docs/.

Tests:
- Champs obligatoires; horodatage; signature image optionnelle.

CI Gates:
- pdf generation smoke (taille > 0, contenu texte cle present).

Acceptation:
- PDF lisibles et presentables aux equipes.

Notes:
- AEM/URSSAF spec en etape 27.

---

### Etape 27 - Paie FR v2: exports AEM/URSSAF (CSV)
Objectif:
- Produire exports CSV pour traitements administratifs FR (a verifier par comptable/production).

Livrables:
- Backend: exporter paie_mensuelle_v2.csv avec colonnes exigees (ids, heures, cachets, brut estime, taux). Schema documente.
- UI: page Export Paie avec selection periode/orga.

Scripts:
- PS1/export_paie_v2.ps1: ecrit out/paie_YYYYMM_v2.csv.

Tests:
- Totaux mensuels corrects; arrondis conformes aux regles definies.

CI Gates:
- tests payroll >= 85%; golden file compare.

Acceptation:
- Fichier teste par prod/compta; validate manuelle OK.

Notes:
- Ne remplace pas conseil comptable; champs adaptes au format interne prod.

---

### Etape 28 - Calendrier/Email v2 (rotations, ICS tokens, notifications fines)
Objectif:
- Ameliorer sync et notifs.

Livrables:
- ICS tokens rotatables; filtres equipe; rappel email J-1 et H-2.
- UI: centre de notifications avec marquage lu/non-lu.

Scripts:
- PS1/rotate_ics.ps1: regenere tokens; PS1/test_reminders.ps1: envoi lot de rappels.

Tests:
- ICS token revoke; email envoyes une fois par event.

CI Gates:
- job schedule simulate (cron) en CI.

Acceptation:
- Un user revoque son ICS; plus d'acces.

Notes:
- Considerer fuseaux lors des rappels.

---

### Etape 29 - Ressources materiel (booking)
Objectif:
- Reserver perches, consoles, HF, camions, etc.

Livrables:
- Backend: entites resource, booking (time-bound); conflits materiel.
- UI: vue ressources (timeline) + superposition planning equipes.

Scripts:
- PS1/seed_resources.ps1: ajoute ressources Bobino (ex: perches P19,P24...).

Tests:
- Conflits booking detectes; indispo materiel bloque mission.

CI Gates:
- e2e smoke: creation booking + detection conflit.

Acceptation:
- Planning visible par ressource; decisions logistiques facilitees.

Notes:
- Capacite et quantites parametrees.

---

### Etape 30 - Multi-site et logistique (load-in/load-out)
Objectif:
- Gerer plannings multi-salles et fenetres logistiques (chargement, montage, demontage), temps de trajet.

Livrables:
- Backend: entites venue, slot_logistique; calcul temps trajet (heuristique) entre sites.
- UI: filtre par site; affichage slots logistiques; alertes chevauchement transport.

Scripts:
- PS1/seed_venues.ps1: ajoute 2 sites; PS1/plan_logistique.ps1: genere slots.

Tests:
- Chevauchement trajet/shift interdit; slots respectes.

CI Gates:
- tests logistique verts.

Acceptation:
- Un planning cross-site coherent avec trajets proposes.

Notes:
- Integration mapping externe possible plus tard.
