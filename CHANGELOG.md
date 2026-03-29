# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Références traçables dans les entrées de changelog : SHA court, PR et issues résolues en fin de ligne (#18, PR #19, 81ff178)

### Changed

- Détection élargie des mots-clés GitHub pour les issues résolues : `close(s|d)`, `fix(es|ed)`, `resolve(s|d)` (#18, PR #19, 3d2c7ef)
- Préfixe `PR #N` pour distinguer les PR des issues dans les références (#18, PR #19, 3d2c7ef)

## [1.3.0] - 2026-03-29

### Added

- Skill `/audit-naming` pour auditer les conventions de nommage du projet avec référentiel dédié
- Intégration du référentiel audit-naming dans `/pipe-review`
- Skill `/pipe-changelog` pour générer et maintenir le CHANGELOG avec référentiel de conventions

### Changed

- Chaînage du pipeline : `/pipe-test` → `/pipe-changelog` → `/pipe-pr`

### Fixed

- Séquence git explicite dans `/pipe-code` pour la création de branche

## [1.2.4] - 2026-03-28

### Fixed

- Compatibilité sandbox : remplacement de tous les `ls` inline par `Glob/Read` dans l'ensemble des skills

## [1.2.3] - 2026-03-28

### Fixed

- Compatibilité sandbox : remplacement de `ls` par `Glob` dans `/create-skill`

## [1.2.2] - 2026-03-27

## [1.2.1] - 2026-03-27

### Removed

- Skill `/setup-init` supprimé (fonctionnalité intégrée dans `/setup`)

## [1.2.0] - 2026-03-27

### Changed

- Conformité de tous les skills au template canonique unifié

### Fixed

- Compatibilité sandbox : remplacement de `ls` par `Glob` dans `/audit-skills`

## [1.1.0] - 2026-03-27

### Added

- Pattern sub-agents dans `/create-skill` pour analyse multi-fichiers
- Skill `/audit-skills` extrait de `/create-skill` pour évaluer la maturité AI-Driven Development

## [1.0.0] - 2026-03-27

### Added

- Pipeline AI-Driven Development : `/pipe-hello` → `/pipe-plan` → `/pipe-code` → `/pipe-review` → `/pipe-test` → `/pipe-pr` → `/pipe-notifier`
- Skill `/setup` pour configurer un projet complet
- Skill `/setup-mcp` pour configurer les serveurs MCP avec catalogue de référence
- Skill `/setup-templates` pour initialiser les templates projet-spécifiques
- Skill `/setup-ui-ux` pour générer les conventions UI/UX
- Skill `/create-skill` pour créer de nouveaux skills au format `directory/SKILL.md`
- Conventions frontend (`/frontend-code-conventions`) et git (`/git-conventions`)
- Architecture plugin avec manifest `plugin.json` et skills distribués
- Template canonique unifié pour les skills avec chargement progressif
- Préfixage des skills par catégorie (`pipe-*`, `create-*`, `setup-*`, `audit-*`)
- Installation via marketplace

[Unreleased]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.3.0...HEAD
[1.3.0]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.2.4...v1.3.0
[1.2.4]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.2.3...v1.2.4
[1.2.3]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.2.2...v1.2.3
[1.2.2]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.2.1...v1.2.2
[1.2.1]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/ToolsForSaaS/claude-workflow/releases/tag/v1.0.0
