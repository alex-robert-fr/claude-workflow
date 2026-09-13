# Fichier CHANGELOG.md — structure, sources, cohérence

Chargé par `/pipe-changelog` seul.

## Répartition CHANGELOG / historique git

| Question du lecteur | Où est la réponse |
|---|---|
| Qu'est-ce qui change pour moi ? | CHANGELOG — une phrase par changement |
| Dois-je adapter mon code ou mon déploiement ? | CHANGELOG — `**BREAKING**`, notes de déploiement |
| Comment c'est implémenté, et pourquoi ? | Corps du commit ou de la PR, via la référence en fin d'entrée |
| Qu'est-ce qui a changé en interne ? | Historique git seul — pas d'entrée |

Pas de fichier technique séparé (`TECHNICAL_CHANGES.md`) : il duplique l'historique git et dérive.

## Structure

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Les détails techniques de chaque changement sont documentés dans les commits et pull requests liés.

## [Unreleased]

## [1.2.0](https://github.com/org/repo/releases/tag/v1.2.0) - 2026-03-29
## [1.1.0] - 2026-02-14

[Unreleased]: https://github.com/org/repo/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/org/repo/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/org/repo/releases/tag/v1.1.0
```

- Titres de section `[MAJOR.MINOR.PATCH]` sans `v` ; les tags git portent le `v`. `[Unreleased]` toujours présent en tête, même vide, jamais lié
- Dates ISO 8601 `AAAA-MM-JJ`
- En-tête de version lié vers `releases/tag/v{version}` ssi le tag existe (`git tag --list "v${version}"`, repli sans `v`) ; texte brut sinon
- Liens de comparaison en bas : `[Unreleased]` → `compare/vDernier...HEAD`, chaque version → `compare/vPrécédent...vCourant`, la première → `releases/tag/vX.Y.Z`
- Pré-1.0.0 (`0.y.z`) : le MINOR joue le rôle du MAJOR — `0.y+1.0` pour un breaking change ou un ajout significatif, `0.y.z+1` pour un fix ou un ajout mineur

## Notes de déploiement

Tout ce qui est actionnable au déploiement reste dans le CHANGELOG :

- Breaking change de toute la release → blockquote sous l'en-tête de version, avant les types : `> **BREAKING** : le tableau \`ingredients\` devient \`lines\` — les clients adaptent leurs requêtes ([\`77e733e\`](url))`
- Variable d'environnement requise → entrée `Changed` ou `Security` qui nomme la variable et la conséquence
- Dépendance inter-services → blockquote `> Requiert [backend-index](url) ≥ 0.3.2 (colonne \`source_url\` dans l'import CSV)`

## Sources

- **Bloc `## Changelog` d'une PR** (écrit par `/pipe-pr`) : source primaire, entrées reprises telles quelles, référence = la PR. Il ne dispense pas de consolider en état final entre PR de la même release, de remonter `**BREAKING**` et notes de déploiement en blockquote quand ils concernent toute la release, ni de l'audit de cohérence : la date de merge place l'entrée
- **Changesets Turborepo** (`.changeset/*.md`) : un fichier par PR avec son bump ; son summary est l'entrée, rédigé court pour le consommateur ; source primaire pour les commits sans bloc de PR
- **Commits** : le reste, filtré et reformulé selon `entree.md`

## Cohérence versions/dates

Une entrée sous `[X.Y.Z] - date` correspond à un commit ou une PR mergé **avant** la date du tag ; un changement postérieur appartient à `[Unreleased]`. Cas typique : un CHANGELOG créé tardivement qui a absorbé des changements mergés après le premier tag. L'audit est déclenché par le skill en release seulement.
