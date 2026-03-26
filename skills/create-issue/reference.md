# Create Issue — Reference

## Regles de decoupage

### Creer plusieurs issues separees si :

- Des **domaines fonctionnels distincts** (ex : auth + dashboard + API = 3 domaines → 3 issues si les taches sont independantes)
- Un **mix de natures differentes** : un bug ET une feature dans la meme description → toujours separer
- Des **couches techniques independantes** qui peuvent etre developpees et mergees separement (ex : backend + frontend si non couples)
- Une **charge estimee > 2 jours** sur un seul sujet → decouper en sous-taches coherentes
- Des **dependances claires** entre sous-taches (A doit etre fait avant B) → issues separees avec mention de la dependance dans la description

### Garder une seule issue si :

- C'est un bug isole avec cause et correction claires
- C'est une petite feature qui tient en un seul PR coherent
- Les elements decrits sont fortement couples et ne peuvent pas etre livres separement

### En cas de doute

Prefere **decouper** : une issue trop petite est moins grave qu'une issue fourre-tout.

## Template body

```markdown
## Contexte
Pourquoi cette issue existe. Ce qui a declenche le besoin.

## Description
Ce qu'il faut faire, precisement. Pas de vague.

## Criteres d'acceptance
- [ ] Critere 1
- [ ] Critere 2
- [ ] ...

## Notes techniques (si pertinent)
Contraintes, pieges connus, suggestions d'approche.
```

## Labels

| Type dans le titre | Label |
|--------------------|-------|
| `[Bug]` | `bug` |
| `[Feature]` | `feature` |
| `[Refactor]` | `refactor` |
| `[Chore]` | `chore` |
| `[Docs]` | `docs` |
| `[Perf]` | `perf` |

Si le label n'existe pas encore sur le repo, cree-le.
