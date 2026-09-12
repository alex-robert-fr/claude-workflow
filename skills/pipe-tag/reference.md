# Reference — Conventions de tags git

## Semantic Versioning (SemVer)

Format : `vMAJOR.MINOR.PATCH`

| Composant | Quand l'incrementer |
|-----------|-------------------|
| MAJOR | Breaking change (incompatibilite API publique) |
| MINOR | Nouvelle fonctionnalité retro-compatible |
| PATCH | Correction de bug retro-compatible |

**Règles strictes :**
- Toujours 3 composants numeriques : `v1.2.3` (jamais `v1.2`)
- Prefixe `v` obligatoire pour les tags git
- Dans le CHANGELOG.md, les sections utilisent le format `[X.Y.Z]` sans prefixe `v`

## Pre-releases

Format : `vX.Y.Z-QUALIFICATIF.N`

| Tag | Signification |
|-----|--------------|
| `v1.0.0-alpha.1` | Première alpha — instable, usage interne |
| `v1.0.0-beta.2` | Deuxieme beta — tests externes |
| `v1.0.0-rc.1` | Release candidate — quasi-stable |

Ordre de precedence SemVer : `alpha` < `beta` < `rc` < release stable

## Tags annotes vs tags legers

| Type | Commande | Quand utiliser |
|------|----------|----------------|
| **Annote** | `git tag -a vX.Y.Z -m "..."` | Toutes les releases (obligatoire) |
| Leger | `git tag vX.Y.Z` | Marqueurs internes temporaires uniquement |

Les tags annotes stockent : tagger, email, date, message. Ils permettent la verification GPG et offrent une meilleure tracabilite.

## Règles de nommage

- Casse : minuscules uniquement
- Pas d'espaces, pas de slashes

## Erreurs frequentes

| Erreur | Conséquence | Bonne pratique |
|--------|-------------|----------------|
| Tag leger en production | Pas de metadata, pas de tracabilite | Utiliser `-a` systematiquement |
| Tagger sur une feature branch | Version associee a un commit non merge | Toujours tagger sur `main` |
| Format `v1.2` (2 composants) | Ambiguite SemVer | Toujours `v1.2.0` |
| Force-push d'un tag existant | Casse les pipelines CI/CD | Supprimer + recrer avec un nouveau numéro |
| Tag sans push | Tag local seulement, CI/CD pas declenche | Toujours `git push origin vX.Y.Z` |

## Suppression d'un tag

A eviter en production. Si nécessaire :

```bash
# Supprimer localement
git tag -d vX.Y.Z

# Supprimer sur le remote
git push --delete origin vX.Y.Z
```

## Lien avec le pipeline

```
/pipe-changelog [v1.2.3]   <- met a jour CHANGELOG.md avec la version
        ↓
/pipe-pr                   <- soumet la PR
        ↓
[merge de la PR sur main]
        ↓
/pipe-tag [v1.2.3]         <- crée et pousse le tag
```
