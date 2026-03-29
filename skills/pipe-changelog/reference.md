# Pipe Changelog — Referentiel de conventions

## Standard de reference

**[Keep a Changelog](https://keepachangelog.com/en/1.1.0/)** + **[Semantic Versioning](https://semver.org/spec/v2.0.0.html)**

## Structure globale du CHANGELOG

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.0] - 2026-03-29
## [1.1.0] - 2026-02-14
## [1.0.0] - 2026-01-01

[Unreleased]: https://github.com/org/repo/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/org/repo/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/org/repo/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/org/repo/releases/tag/v1.0.0
```

## Types d'entrees (ordre impose)

Les types doivent toujours apparaitre dans cet ordre. Ne pas inclure les types sans entrees.

| Type | Usage |
|---|---|
| `Added` | Nouvelle fonctionnalite |
| `Changed` | Modification de comportement existant |
| `Deprecated` | Fonctionnalite vouee a etre supprimee |
| `Removed` | Suppression definitive |
| `Fixed` | Correction de bug |
| `Security` | Patch de securite |

Pas de types custom (`Improved`, `Refactored`, `Chore`, etc.).

## Mapping prefixe de commit → type CHANGELOG

| Prefixe commit | Type CHANGELOG | Notes |
|---|---|---|
| `feat` | Added | Nouvelle fonctionnalite |
| `refactor` | Changed | Modification de comportement ou restructuration |
| `perf` | Changed | Optimisation de performance |
| `fix` | Fixed | Correction de bug |
| `docs` | — | Exclure sauf si impact utilisateur (ex: nouveau guide public) |
| `chore` | — | Exclure sauf si impact utilisateur (ex: changement de config publique) |

Cas speciaux (detectes par le contenu du commit, pas par le prefixe seul) :
- Suppression explicite d'une fonctionnalite → `Removed`
- Deprecation explicite → `Deprecated`
- Patch de securite → `Security`
- Breaking change → prefixer l'entree par `**BREAKING**`

## Regles de contenu

- Une entree = un changement notable cote utilisateur/consommateur
- Redigee pour le lecteur, pas pour le dev — pas de detail d'implementation interne
- Chaque entree sur une ligne, commencant par un verbe a l'infinitif ou un nom
- Chaque entree inclut ses references tracables en fin de ligne (voir section "References dans les entrees")
- Breaking changes marques : `**BREAKING**` en prefixe de l'entree
- Ne jamais copier les messages de commit verbatim — reformuler pour le consommateur

## References dans les entrees

Chaque entree de changelog inclut une reference tracable entre parentheses en fin de ligne. Cela permet de remonter a l'origine d'un changement.

### Regle

- **Si une PR existe** : lier la PR. C'est la reference principale — elle contient le contexte, les commits et les issues liees.
- **Si pas de PR** (commit direct) : lier le SHA court en fallback.

Une seule reference par entree. Pas besoin de doublonner PR + SHA + issue.

### Format

```
- Texte reformule ([#N](url))
```

**Important** : GitHub n'auto-link pas les references dans les fichiers `.md` du depot. Il faut systematiquement utiliser des liens Markdown explicites `[texte](url)`. L'URL du remote est detectee a l'etape 1 du skill.

### Exemples

```markdown
- Ajouter le support multi-langue ([#15](https://github.com/org/repo/pull/15))
```
PR #15 — le lecteur y trouvera les commits, l'issue liee et le contexte.

```markdown
- Corriger le parsing des dates ([`def5678`](https://github.com/org/repo/commit/def5678))
```
Commit direct, pas de PR — SHA court en fallback.

## Versioning

- Format strict dans les titres de section : `[MAJOR.MINOR.PATCH]` — jamais `v1.2.0`
- `[Unreleased]` toujours present en tete, meme si vide
- Date au format ISO 8601 : `YYYY-MM-DD`
- Les tags git utilisent le prefixe `v` : `v1.2.0`

## Versioning pre-v1.0.0

Plage `0.y.z` — semantique SemVer adaptee pour phase dev :

| Bump | Quand |
|---|---|
| `0.y` → `0.y+1.0` | Breaking change ou ajout significatif |
| `0.y.z` → `0.y.z+1` | Fix, ajout mineur |

En `0.x`, le MAJOR est implicitement instable — le MINOR joue le role du MAJOR.

## Liens de comparaison

Toujours generes en bas du fichier CHANGELOG :

- `[Unreleased]` pointe vers `compare/vX.Y.Z...HEAD` (dernier tag vs HEAD)
- Chaque version pointe vers `compare/vPRECEDENT...vCOURANT`
- La premiere version pointe vers `releases/tag/vX.Y.Z`

Format :
```markdown
[Unreleased]: https://github.com/org/repo/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/org/repo/compare/v1.1.0...v1.2.0
[1.0.0]: https://github.com/org/repo/releases/tag/v1.0.0
```

## Exclusions

Ne pas inclure dans le CHANGELOG :

- Les merges (`Merge branch...`, `Merge pull request...`)
- Les rebases et fixups (`fixup!`, `squash!`)
- Les changements de CI/CD internes
- Les mises a jour de dependances mineures (sauf impact API publique)
- Les typos de commentaires ou de docs internes
- Le contenu des commits verbatim

## Changesets (Turborepo) — optionnel

Si le projet utilise Changesets :

- Un fichier `.changeset/*.md` par PR avec le bon bump (`major` / `minor` / `patch`)
- Le summary dans le changeset = ce qui apparaitra dans le CHANGELOG → redige pour le consommateur
- Ne pas editer manuellement le CHANGELOG genere — editer les changesets en amont
- Si des changesets existent, les utiliser comme source primaire au lieu des commits
