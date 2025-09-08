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
