# Technical Changes

All notable technical changes targeted at contributors will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.4.7] - 2026-04-27

### Refactor

- Restructurer le skill `pipe-review` : le sub-agent produit 6 champs structurés par problème (fichier, sévérité, problème_une_phrase, gravité_impact, cause, correction) et la phase 2 affiche chaque problème en format Question/Réponse pédagogique avec exemple de rendu ([#42](https://github.com/ToolsForSaaS/claude-workflow/pull/42))

### Docs

- Clarifier la convention de granularité dans `pipe-changelog` : une entrée = une seule information user-facing distincte, principe #3 reformulé pour distinguer fusion et découpages, exemples Avant/Après ajoutés ([#43](https://github.com/ToolsForSaaS/claude-workflow/pull/43))

## [1.4.2](https://github.com/ToolsForSaaS/claude-workflow/releases/tag/v1.4.2) - 2026-04-14

### Docs

- Retirer toutes les references a `pipe-notifier` dans les skills et dans `CLAUDE.md` apres sa suppression ([`12cd229`](https://github.com/ToolsForSaaS/claude-workflow/commit/12cd229), [`51a1a08`](https://github.com/ToolsForSaaS/claude-workflow/commit/51a1a08))

## [1.4.1](https://github.com/ToolsForSaaS/claude-workflow/releases/tag/v1.4.1) - 2026-04-11

### Docs

- Reecrire le README avec guide d'utilisation et catalogue complet des 21 skills, ajouter la compatibilite Jira ([`696dc0c`](https://github.com/ToolsForSaaS/claude-workflow/commit/696dc0c), [`25e5ddc`](https://github.com/ToolsForSaaS/claude-workflow/commit/25e5ddc))
- Ajouter la regle `Closes #XX` obligatoire dans le skill `git-conventions` et corriger la position de la note dans le template PR body ([`1276f89`](https://github.com/ToolsForSaaS/claude-workflow/commit/1276f89), [`3515326`](https://github.com/ToolsForSaaS/claude-workflow/commit/3515326))

## [1.4.0](https://github.com/ToolsForSaaS/claude-workflow/releases/tag/v1.4.0) - 2026-03-29

### Docs

- Mentionner la convention `model` dans `CLAUDE.md` ([`1baed93`](https://github.com/ToolsForSaaS/claude-workflow/commit/1baed93))

### Chore

- Corriger les problemes de review remontes sur le skill `create-skill` apres l'integration du champ `model` ([`b2d8016`](https://github.com/ToolsForSaaS/claude-workflow/commit/b2d8016))

## [1.3.3](https://github.com/ToolsForSaaS/claude-workflow/releases/tag/v1.3.3) - 2026-03-29

### Docs

- Corriger l'exemple de structure globale et preciser le format de `tagRef` dans le referentiel de `pipe-changelog` ([`6037eb4`](https://github.com/ToolsForSaaS/claude-workflow/commit/6037eb4))
- Documenter le format des en-tetes de version avec lien conditionnel vers le tag dans le skill `pipe-changelog` ([`614501b`](https://github.com/ToolsForSaaS/claude-workflow/commit/614501b))

## [1.3.2](https://github.com/ToolsForSaaS/claude-workflow/releases/tag/v1.3.2) - 2026-03-29

### Chore

- Corriger les violations de conventions du skill `pipe-tag` et l'integrer dans le pipeline ([`2523d5c`](https://github.com/ToolsForSaaS/claude-workflow/commit/2523d5c), [`1efd3e2`](https://github.com/ToolsForSaaS/claude-workflow/commit/1efd3e2))

## [1.3.1] - 2026-03-29

### Refactor

- Simplifier les references dans `pipe-changelog` (PR uniquement avec SHA en fallback) et elargir les mots-cles de detection ([`c0df419`](https://github.com/ToolsForSaaS/claude-workflow/commit/c0df419), [`3d2c7ef`](https://github.com/ToolsForSaaS/claude-workflow/commit/3d2c7ef))

### Docs

- Creer le fichier `CHANGELOG.md` initial du projet ([`f7d8583`](https://github.com/ToolsForSaaS/claude-workflow/commit/f7d8583))
- Ajouter la regle des liens Markdown explicites pour les references dans le skill `pipe-changelog` ([`be2f284`](https://github.com/ToolsForSaaS/claude-workflow/commit/be2f284))

## [1.3.0] - 2026-03-29

### Refactor

- Deplacer le referentiel de nommage apres la liste numerotee dans le skill `pipe-review` ([`f5488dd`](https://github.com/ToolsForSaaS/claude-workflow/commit/f5488dd))

## [1.1.0] - 2026-03-27

### Refactor

- Mettre le skill `create-skill` en conformite avec les bonnes pratiques du template canonique ([`c40b389`](https://github.com/ToolsForSaaS/claude-workflow/commit/c40b389))

### Docs

- Ajouter les instructions d'installation via la marketplace dans le README ([`4e491e6`](https://github.com/ToolsForSaaS/claude-workflow/commit/4e491e6))
- Supprimer la section de migration `sync.sh` devenue obsolete ([`7618421`](https://github.com/ToolsForSaaS/claude-workflow/commit/7618421))

## [1.0.0] - 2026-03-27

### Refactor

- Migrer tous les skills au format `directory/SKILL.md` et au chargement progressif via le pattern "utilise Read pour charger" ([`efa6e0e`](https://github.com/ToolsForSaaS/claude-workflow/commit/efa6e0e), [`fc2f3a7`](https://github.com/ToolsForSaaS/claude-workflow/commit/fc2f3a7), [`10ea164`](https://github.com/ToolsForSaaS/claude-workflow/commit/10ea164), [`40121fb`](https://github.com/ToolsForSaaS/claude-workflow/commit/40121fb))
- Remplacer le systeme de commandes classiques par des skills unifies ([`ff02fe7`](https://github.com/ToolsForSaaS/claude-workflow/commit/ff02fe7))
- Reorganiser l'arborescence : `commands/` et `skills/` dans `.claude/`, puis remontee a la racine du plugin avec references inter-skills adaptees ([`289f6d7`](https://github.com/ToolsForSaaS/claude-workflow/commit/289f6d7), [`9785305`](https://github.com/ToolsForSaaS/claude-workflow/commit/9785305), [`e1df8a4`](https://github.com/ToolsForSaaS/claude-workflow/commit/e1df8a4))
- Renommer les skills selon la convention de nommage unifiee ([`8eaf6b4`](https://github.com/ToolsForSaaS/claude-workflow/commit/8eaf6b4))
- Extraire le mode audit de `create-skill` dans le skill dedie `audit-skills` ([`20088cc`](https://github.com/ToolsForSaaS/claude-workflow/commit/20088cc))

### Docs

- Initialiser `CLAUDE.md` et le README du projet, puis les reecrire pour le contexte plugin ([`db2b40b`](https://github.com/ToolsForSaaS/claude-workflow/commit/db2b40b), [`7fafe62`](https://github.com/ToolsForSaaS/claude-workflow/commit/7fafe62), [`f7abc89`](https://github.com/ToolsForSaaS/claude-workflow/commit/f7abc89))
- Ajouter la regle "utilise Read pour charger" dans la documentation de `create-skill` ([`93d1598`](https://github.com/ToolsForSaaS/claude-workflow/commit/93d1598))
- Mettre a jour `CLAUDE.md` et le referentiel d'audit-grille pour refleter la structure plugin ([`571a9cc`](https://github.com/ToolsForSaaS/claude-workflow/commit/571a9cc), [`66cf839`](https://github.com/ToolsForSaaS/claude-workflow/commit/66cf839))

### Chore

- Initialiser le depot `claude-workflow` avec commandes, skills et scripts de sync ([`498f88a`](https://github.com/ToolsForSaaS/claude-workflow/commit/498f88a))
- Renommer le plugin et ajouter `.gitignore` ([`3f0423a`](https://github.com/ToolsForSaaS/claude-workflow/commit/3f0423a))
- Supprimer le tableau de routage des skills et le template d'index devenus obsoletes ([`88ef12c`](https://github.com/ToolsForSaaS/claude-workflow/commit/88ef12c))

[Unreleased]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.4.6...HEAD
[1.4.6]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.4.5...v1.4.6
[1.4.2]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.4.1...v1.4.2
[1.4.1]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.4.0...v1.4.1
[1.4.0]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.3.3...v1.4.0
[1.3.3]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.3.2...v1.3.3
[1.3.2]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.3.1...v1.3.2
[1.3.1]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.3.0...v1.3.1
[1.3.0]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.2.4...v1.3.0
[1.1.0]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/ToolsForSaaS/claude-workflow/releases/tag/v1.0.0
