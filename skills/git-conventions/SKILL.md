---
name: git-conventions
description: Conventions git du projet. Branches, commits et Pull Requests. Utiliser lors de la creation de branches, commits ou PRs pour respecter les formats standard.
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

Le corps du commit est le **journal technique** du projet : le CHANGELOG reste court et non technique et pointe vers les commits — c'est donc ici que vit le detail.

- **Obligatoire** des que le changement n'est pas trivial : plusieurs fichiers, decision d'implementation, comportement modifie, contrainte non evidente
- Optionnel uniquement pour les changements evidents depuis le titre (typo, bump de version, formatage)
- Sous forme de liste a puces
- Documente ce que le diff ne montre pas : le **pourquoi**, l'approche choisie, les alternatives ecartees, les impacts sur les autres modules, les contraintes de validation ou de migration
- Un commit pousse est immuable — se relire avant de committer, une erreur dans le corps ne se corrige pas apres coup

### Regles

- **Pas de signature** : ne jamais ajouter de trailer `Co-Authored-By` ou autre signature automatique dans les messages de commit

---

## Pull Requests

### Titre

Format : `[Type] Titre de l'issue (#numero)`

### Body et commentaire d'iteration

Pour rediger le body ou un commentaire d'iteration, utilise Read pour charger `reference.md` et suivre les templates.

### Auto-close des issues (obligatoire)

Le body de chaque PR doit contenir `Closes #XX` pour chaque issue liee. Cela ferme automatiquement les issues au merge. Si plusieurs issues sont concernees : `Closes #12, Closes #15`. Ne jamais omettre cette ligne.

### Regles de formatage MCP GitHub

Ne jamais utiliser `\n` litteraux dans le parametre `body` des appels MCP GitHub (`create_pull_request`, `update_pull_request`, `add_issue_comment`). Utiliser de vrais sauts de ligne dans le texte, sinon les `\n` s'affichent en dur dans le markdown.
