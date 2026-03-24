---
name: branch-convention
description: Convention de nommage des branches Git du projet. Utiliser lors de la création de branches pour respecter le format type/numero-titre-court.
user-invocable: false
---

## Format

```
type/numero-titre-court
```

## Mapping des préfixes

| Préfixe | Usage |
|---------|-------|
| `feat/` | Nouvelle fonctionnalité |
| `fix/` | Correction de bug |
| `refactor/` | Refactoring |
| `perf/` | Optimisation performance |
| `docs/` | Documentation |
| `chore/` | Maintenance / config |

## Règles

- Le titre court est en **kebab-case**, en **anglais**, **max 5 mots**
- Le numéro correspond au numéro de l'issue GitHub associée

## Exemples

| Issue | Branche |
|-------|---------|
| #42 `[Feature] Ajout authentification OAuth` | `feat/42-add-oauth-authentication` |
| #17 `[Bug] Crash au login avec email +` | `fix/17-login-crash-email-plus` |
| #8 `[Docs] Documentation API publique` | `docs/8-public-api-documentation` |
| #5 `[Chore] Ajout commandes Claude Code` | `chore/5-add-claude-code-commands` |
