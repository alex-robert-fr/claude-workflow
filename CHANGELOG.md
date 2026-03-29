# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Convention de sélection de modèle (`model`) dans le frontmatter des skills avec 3 tiers (opus, sonnet, haiku) et grille de catégorisation des 22 skills existants ([#26](https://github.com/ToolsForSaaS/claude-workflow/pull/26))
- Choix du tier modèle intégré dans le flow de création de skill (`/create-skill`) ([#26](https://github.com/ToolsForSaaS/claude-workflow/pull/26))

## [1.3.3](https://github.com/ToolsForSaaS/claude-workflow/releases/tag/v1.3.3) - 2026-03-29

### Fixed

- Les en-têtes de version dans CHANGELOG.md sont maintenant liés au tag git correspondant quand il existe ([#23](https://github.com/ToolsForSaaS/claude-workflow/pull/23))

## [1.3.2](https://github.com/ToolsForSaaS/claude-workflow/releases/tag/v1.3.2) - 2026-03-29

### Added

- Skill `/pipe-tag` pour créer et pousser un tag git annoté SemVer depuis CHANGELOG ([#20](https://github.com/ToolsForSaaS/claude-workflow/pull/20))

### Changed

- Intégration de `/pipe-tag` dans le pipeline entre `/pipe-pr` et `/pipe-notifier` ([#20](https://github.com/ToolsForSaaS/claude-workflow/pull/20))

## [1.3.1] - 2026-03-29

### Added

- Références traçables dans les entrées de changelog avec liens cliquables vers la PR ou le commit source ([#19](https://github.com/ToolsForSaaS/claude-workflow/pull/19))

## [1.3.0] - 2026-03-29

### Added

- Skill `/audit-naming` pour auditer les conventions de nommage du projet avec référentiel dédié ([#15](https://github.com/ToolsForSaaS/claude-workflow/pull/15))
- Intégration du référentiel audit-naming dans `/pipe-review` ([#15](https://github.com/ToolsForSaaS/claude-workflow/pull/15))
- Skill `/pipe-changelog` pour générer et maintenir le CHANGELOG avec référentiel de conventions ([#17](https://github.com/ToolsForSaaS/claude-workflow/pull/17))

### Changed

- Chaînage du pipeline : `/pipe-test` → `/pipe-changelog` → `/pipe-pr` ([#17](https://github.com/ToolsForSaaS/claude-workflow/pull/17))

### Fixed

- Séquence git explicite dans `/pipe-code` pour la création de branche ([#13](https://github.com/ToolsForSaaS/claude-workflow/pull/13))

## [1.2.4] - 2026-03-28

### Fixed

- Compatibilité sandbox : remplacement de tous les `ls` inline par `Glob/Read` dans l'ensemble des skills ([`4e3b0a4`](https://github.com/ToolsForSaaS/claude-workflow/commit/4e3b0a4))

## [1.2.3] - 2026-03-28

### Fixed

- Compatibilité sandbox : remplacement de `ls` par `Glob` dans `/create-skill` ([`52ee483`](https://github.com/ToolsForSaaS/claude-workflow/commit/52ee483))

## [1.2.2] - 2026-03-27

## [1.2.1] - 2026-03-27

### Removed

- Skill `/setup-init` supprimé (fonctionnalité intégrée dans `/setup`) ([`a7bb330`](https://github.com/ToolsForSaaS/claude-workflow/commit/a7bb330))

## [1.2.0] - 2026-03-27

### Changed

- Conformité de tous les skills au template canonique unifié ([`37013b6`](https://github.com/ToolsForSaaS/claude-workflow/commit/37013b6))

### Fixed

- Compatibilité sandbox : remplacement de `ls` par `Glob` dans `/audit-skills` ([`72e5f8c`](https://github.com/ToolsForSaaS/claude-workflow/commit/72e5f8c))

## [1.1.0] - 2026-03-27

### Added

- Pattern sub-agents dans `/create-skill` pour analyse multi-fichiers ([`81c5cda`](https://github.com/ToolsForSaaS/claude-workflow/commit/81c5cda))
- Skill `/audit-skills` extrait de `/create-skill` pour évaluer la maturité AI-Driven Development ([`20088cc`](https://github.com/ToolsForSaaS/claude-workflow/commit/20088cc))

## [1.0.0] - 2026-03-27

### Added

- Pipeline AI-Driven Development : `/pipe-hello` → `/pipe-plan` → `/pipe-code` → `/pipe-review` → `/pipe-test` → `/pipe-pr` → `/pipe-notifier` ([`60bcaba`](https://github.com/ToolsForSaaS/claude-workflow/commit/60bcaba))
- Skill `/setup` pour configurer un projet complet ([#9](https://github.com/ToolsForSaaS/claude-workflow/pull/9))
- Skill `/setup-mcp` pour configurer les serveurs MCP avec catalogue de référence ([#2](https://github.com/ToolsForSaaS/claude-workflow/pull/2))
- Skill `/setup-templates` pour initialiser les templates projet-spécifiques ([`9f156fd`](https://github.com/ToolsForSaaS/claude-workflow/commit/9f156fd))
- Skill `/setup-ui-ux` pour générer les conventions UI/UX ([#2](https://github.com/ToolsForSaaS/claude-workflow/pull/2))
- Skill `/create-skill` pour créer de nouveaux skills au format `directory/SKILL.md` ([`9e23bf6`](https://github.com/ToolsForSaaS/claude-workflow/commit/9e23bf6))
- Conventions frontend (`/frontend-code-conventions`) et git (`/git-conventions`) ([`00d17bb`](https://github.com/ToolsForSaaS/claude-workflow/commit/00d17bb))
- Architecture plugin avec manifest `plugin.json` et skills distribués ([#7](https://github.com/ToolsForSaaS/claude-workflow/pull/7))
- Template canonique unifié pour les skills avec chargement progressif ([`843c650`](https://github.com/ToolsForSaaS/claude-workflow/commit/843c650))
- Préfixage des skills par catégorie (`pipe-*`, `create-*`, `setup-*`, `audit-*`) ([#8](https://github.com/ToolsForSaaS/claude-workflow/pull/8))
- Installation via marketplace ([`951edeb`](https://github.com/ToolsForSaaS/claude-workflow/commit/951edeb))

[Unreleased]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.3.3...HEAD
[1.3.3]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.3.2...v1.3.3
[1.3.2]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.3.1...v1.3.2
[1.3.1]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.3.0...v1.3.1
[1.3.0]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.2.4...v1.3.0
[1.2.4]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.2.3...v1.2.4
[1.2.3]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.2.2...v1.2.3
[1.2.2]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.2.1...v1.2.2
[1.2.1]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/ToolsForSaaS/claude-workflow/releases/tag/v1.0.0
