# Roadmap 41-50 - UI/UX design system et validation utilisateur

Contrainte generale: ASCII only, Windows-first (PowerShell 7+), aucun mock. CI inclut tests UI visuels, accessibilite et audits UX.  

---

### Etape 41 - Design System v1 (shadcn/ui, palette, typographie)
Objectif:
- Fournir un systeme visuel coherent pour toutes les pages.  

Livrables:
- Palette couleurs, typographie, spacing documentes.  
- Implementation shadcn/ui custom (boutons, inputs, modales, toasts).  
- Docs: guide style (FR) dans `docs/design_system.md`.  

Scripts:
- PS1/design_tokens.ps1: genere JSON tokens design.  

Tests:
- Snapshot visuel des composants de base.  

CI Gates:
- Chromatic build doit passer; aucun diff non approuve.  

Acceptation:
- Un composant bouton est identique entre Planning et Login.  

Notes:
- Baseline pour toutes evolutions UI.  

---

### Etape 42 - Storybook + Chromatic
Objectif:
- Centraliser et valider visuellement les composants UI.  

Livrables:
- Storybook configure (React + Vite).  
- Chromatic integre a CI (review visuelle).  
- Stories pour boutons, forms, modales, planning cell.  

Scripts:
- PS1/storybook_build.ps1: build local et snapshot.  

Tests:
- Stories couvrent >80% composants front.  

CI Gates:
- Job `storybook` obligatoire; Chromatic review blocking.  

Acceptation:
- Reviewer valide capture visuelle avant merge.  

Notes:
- Favoriser revue async par non-dev.  

---

### Etape 43 - Flows Utilisateur (parcours critiques)
Objectif:
- Designer et tester les parcours utilisateurs principaux.  

Livrables:
- Flows figma exportes en PNG (docs/ux_flows/).  
- Tests e2e Playwright couvrant: Login, Creation mission, Planning edition.  
- Docs: parcours utilisateur FR.  

Scripts:
- PS1/ux_flows_sync.ps1: recupere PNG depuis Figma API.  

Tests:
- e2e verts; capture screenshots reference.  

CI Gates:
- e2e-smoke + screenshot compare.  

Acceptation:
- Un user suit le flow Login->Planning->Export sans blocage.  

Notes:
- Ne couvre pas encore edge cases.  

---

### Etape 44 - Tests UI automatises (visuels et interactions)
Objectif:
- Fiabiliser l'UI via tests systematiques.  

Livrables:
- Playwright tests avec screenshots reference.  
- Axe-core integration sur Storybook pour a11y.  
- Rapport visuel CI exporte en artefacts.  

Scripts:
- PS1/ui_tests.ps1: lance Playwright visuel + axe.  

Tests:
- Diff <0.1% pixel sur snapshots UI.  

CI Gates:
- axe-core violations AA < 5; screenshot diff blocking.  

Acceptation:
- CI bloque un changement de couleur involontaire.  

Notes:
- Screenshots stockes avec retention 30j.  

---

### Etape 45 - UX Audits et Feedback boucle
Objectif:
- Collecter et agir sur feedback utilisateur reel.  

Livrables:
- Script sondage dans app (Hotjar-like light, opt-in).  
- Docs: rapport UX mensuel.  
- Tableau Kanban `UX backlog` dans repo (GitHub Projects).  

Scripts:
- PS1/ux_report.ps1: compile feedback en CSV/Markdown.  

Tests:
- Rapport genere avec feedback seed.  

CI Gates:
- lint doc feedback; presence rapport mensuel.  

Acceptation:
- Une iteration de design est basee sur feedback reel.  

Notes:
- Focus sur simplicity-first; pas de feature creep.  
