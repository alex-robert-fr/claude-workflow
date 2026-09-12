# Create Issue — Reference

## Règles de decoupage

### Creer plusieurs issues séparées si :

- Des **domaines fonctionnels distincts** (ex : auth + dashboard + API = 3 domaines → 3 issues si les taches sont independantes)
- Un **mix de natures differentes** : un bug ET une feature dans la meme description → toujours separer
- Des **couches techniques independantes** qui peuvent être developpees et mergees séparément (ex : backend + frontend si non couples)
- Une **charge estimee > 2 jours** sur un seul sujet → decouper en sous-taches coherentes
- Des **dependances claires** entre sous-taches (A doit être fait avant B) → issues séparées avec mention de la dependance dans la description

### Garder une seule issue si :

- C'est un bug isole avec cause et correction claires
- C'est une petite feature qui tient en un seul PR cohérent
- Les éléments decrits sont fortement couples et ne peuvent pas être livres séparément

## Template body

```markdown
## Contexte
Pourquoi cette issue existe. Ce qui a declenche le besoin.

## Description
Ce qu'il faut faire, precisement. Pas de vague.

## Critères d'acceptance
- [ ] Critère 1
- [ ] Critère 2
- [ ] ...

## Notes techniques (si pertinent)
Contraintes, pieges connus, suggestions d'approche.
```

Mécanisme qui bifurque réellement (plusieurs cas d'erreur parallèles, par exemple) dans Description ou Notes techniques : un diagramme Mermaid vaut mieux qu'un paragraphe — critères dans skills/pipe-spec/reference.md (Template de spec, section Fonctionnement technique).

## Labels

| Type dans le titre | Label |
|--------------------|-------|
| `[Bug]` | `bug` |
| `[Feature]` | `feature` |
| `[Refactor]` | `refactor` |
| `[Chore]` | `chore` |
| `[Docs]` | `docs` |
| `[Perf]` | `perf` |

Si le label n'existe pas encore sur le repo, crée-le.
