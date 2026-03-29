---
name: git-conventions
description: Conventions git du projet. Branches, commits et Pull Requests. Utiliser lors de la creation de branches, commits ou PRs pour respecter les formats standard.
model: haiku
user-invocable: false
---

## Branches

### Format

```
type/numero-titre-court
```

### Mapping des prefixes

| Prefixe | Usage |
|---------|-------|
| `feat/` | Nouvelle fonctionnalite |
| `fix/` | Correction de bug |
| `refactor/` | Refactoring |
| `perf/` | Optimisation performance |
| `docs/` | Documentation |
| `chore/` | Maintenance / config |

### Regles

- Le titre court est en **kebab-case**, en **anglais**, **max 5 mots**
- Le numero correspond au numero de l'issue associee

---

## Commits

### Format

```
emoji type(scope): description en francais
```

### Table des types

| Emoji | Type | Usage |
|-------|------|-------|
| ✨ | feat | Nouvelle fonctionnalite |
| 🐛 | fix | Correction de bug |
| ♻️ | refactor | Refactoring |
| ⚡ | perf | Optimisation performance |
| 📝 | docs | Documentation |
| 🔧 | chore | Maintenance / config |

### Scope

Le scope correspond au module metier / DDD (`auth`, `billing`, `user`...).

- **Obligatoire** pour `feat`, `fix`, `refactor`, `perf`
- **Optionnel** pour `docs` et `chore`

### Body

Optionnel, uniquement si le changement n'est pas evident depuis le titre. Sous forme de liste a puces.

### Regles

- **Pas de signature** : ne jamais ajouter de trailer `Co-Authored-By` ou autre signature automatique dans les messages de commit

---

## Pull Requests

### Titre

Format : `[Type] Titre de l'issue (#numero)`

### Body et commentaire d'iteration

Pour rediger le body ou un commentaire d'iteration, utilise Read pour charger `reference.md` et suivre les templates.

### Regles de formatage MCP GitHub

Ne jamais utiliser `\n` litteraux dans le parametre `body` des appels MCP GitHub (`create_pull_request`, `update_pull_request`, `add_issue_comment`). Utiliser de vrais sauts de ligne dans le texte, sinon les `\n` s'affichent en dur dans le markdown.
