# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Aligne les descriptions de `plugin.json` et `marketplace.json` pour inclure toutes les etapes du pipeline (les anciennes descriptions courtes omettaient `changelog` et `tag`) ([`e6cfb84`](https://github.com/ToolsForSaaS/claude-workflow/commit/e6cfb84))
- Refond la presentation du `README.md` autour d'une nouvelle section "Pourquoi ce plugin ?" qui resume le probleme adresse et les profils cibles (devs solo, equipes) ([`ef20049`](https://github.com/ToolsForSaaS/claude-workflow/commit/ef20049))
- Reorganise les categories de skills dans le `README.md` : nouvelle categorie "Utilitaires" pour `pipe-commit` et `worktree`, et scission de "Conventions" en "Referentiels" et "Interne" ([`ef20049`](https://github.com/ToolsForSaaS/claude-workflow/commit/ef20049))
- Transforme chaque skill liste dans le `README.md` en lien cliquable vers son fichier `SKILL.md` correspondant ([`ef20049`](https://github.com/ToolsForSaaS/claude-workflow/commit/ef20049))
- Explicite dans le `README.md` que la lecture d'issues est compatible GitHub et Jira mais que la creation d'issues et de Pull Requests reste sur GitHub uniquement ([`ef20049`](https://github.com/ToolsForSaaS/claude-workflow/commit/ef20049))
- Ajoute une section "Ressources" au `README.md` avec liens vers `CHANGELOG.md`, le repo GitHub et `CLAUDE.md` ([`ef20049`](https://github.com/ToolsForSaaS/claude-workflow/commit/ef20049))

### Fixed

- Synchronise la version annoncee dans `marketplace.json` (passe de `1.0.0` a `1.4.8`) pour aligner la version visible sur la marketplace publique avec la version reelle du plugin ([`e6cfb84`](https://github.com/ToolsForSaaS/claude-workflow/commit/e6cfb84))

## [1.4.8](https://github.com/ToolsForSaaS/claude-workflow/releases/tag/v1.4.8) - 2026-04-29

### Changed

- `/pipe-review` enrichit la revue interactive avec une question de contexte fonctionnel ("De quoi on parle ?") en tete de chaque probleme, reformule les descriptions sans jargon technique et inclut le contexte dans le rapport de synthese ([`72a4cec`](https://github.com/ToolsForSaaS/claude-workflow/commit/72a4cec))

## [1.4.7](https://github.com/ToolsForSaaS/claude-workflow/releases/tag/v1.4.7) - 2026-04-27

### Changed

- `/pipe-changelog` applique desormais une checklist de redaction explicite (5 regles : ecrire pour le consommateur, voix active au present, une information distincte par entree, API publique en backticks, BREAKING explicites) et un template mental `[Verbe actif present] [symbole/feature publique] [effet visible utilisateur] [migration si breaking]` ([#46](https://github.com/ToolsForSaaS/claude-workflow/pull/46))
- `/pipe-changelog` consolide les entrees par etat final : quand plusieurs commits successifs touchent le meme artefact dans une meme release, une seule entree decrit l'etat final (un fichier ajoute puis supprime dans la meme PR ne donne aucune entree) ([#46](https://github.com/ToolsForSaaS/claude-workflow/pull/46))

## [1.4.6] - 2026-04-23

### Changed

- `/pipe-review` présente maintenant chaque problème détecté en format Question/Réponse pédagogique avec 6 champs structurés (fichier, sévérité, description, impact, cause, correction) ([#42](https://github.com/ToolsForSaaS/claude-workflow/pull/42))

## [1.4.5] - 2026-04-17

### Changed

- `/pipe-changelog` genere et maintient desormais **deux fichiers** : `CHANGELOG.md` (orienté consommateur) et `TECHNICAL_CHANGES.md` (orienté contributeur, pour les changements techniques internes — refactors, docs internes, tests, CI, dependances, chore). Chaque commit est classe automatiquement dans un seul des deux fichiers selon son prefixe ([`c524b13`](https://github.com/ToolsForSaaS/claude-workflow/commit/c524b13))

## [1.4.4] - 2026-04-17

### Added

- `/pipe-changelog` ajoute une étape 2.5 d'audit de cohérence historique : détecte les entrées dont la PR/commit a été mergé après la date du tag de leur section et propose de les déplacer vers `[Unreleased]` ([`96cc25b`](https://github.com/ToolsForSaaS/claude-workflow/commit/96cc25b))

### Changed

- `/pipe-changelog` applique des principes de rédaction orientés consommateur : chaque entrée expose l'effet observable, explicite les valeurs concrètes (noms de commandes, fichiers, paramètres), fusionne les changements liés, indique l'impact client quand il existe, et tient sur une seule ligne ([`96cc25b`](https://github.com/ToolsForSaaS/claude-workflow/commit/96cc25b))

## [1.4.3] - 2026-04-14

### Added

- `/pipe-review` devient interactif : après la synthèse (compteurs par sévérité), chaque problème est validé manuellement avec trois options — corriger, ignorer, adapter — avec relecture du fichier avant chaque correction et avertissement explicite si des bloquants sont ignorés ([`43fa4b8`](https://github.com/ToolsForSaaS/claude-workflow/commit/43fa4b8), [`5562f17`](https://github.com/ToolsForSaaS/claude-workflow/commit/5562f17))

## [1.4.2](https://github.com/ToolsForSaaS/claude-workflow/releases/tag/v1.4.2) - 2026-04-14

### Added

- `/worktree` permet de créer, lister, supprimer et basculer entre des worktrees git via quatre actions (`create`, `list`, `remove`, `switch`) en s'appuyant sur l'outil natif `EnterWorktree` ([`fb2cce4`](https://github.com/ToolsForSaaS/claude-workflow/commit/fb2cce4))

### Removed

- `/pipe-notifier` supprimé — le pipeline se termine désormais à `/pipe-tag` ([#21](https://github.com/ToolsForSaaS/claude-workflow/pull/21))

## [1.4.1] - 2026-04-11

### Added

- `/pipe-plan` supporte JIRA et les trackers externes (Linear), avec classification du ticket (technique / métier / mixte) et génération de plans plus concis ([#28](https://github.com/ToolsForSaaS/claude-workflow/pull/28))

### Changed

- `/pipe-review` réorganisé autour d'un prompt expert structuré en cinq catégories d'analyse (bugs, sécurité, performance, architecture, types) avec trois niveaux de sévérité (blocker, major, minor) ([#29](https://github.com/ToolsForSaaS/claude-workflow/pull/29))
- `/pipe-pr` exige désormais une ligne `Closes #XX` dans chaque body de PR pour déclencher l'auto-close des issues liées au merge ([#29](https://github.com/ToolsForSaaS/claude-workflow/pull/29))

## [1.4.0](https://github.com/ToolsForSaaS/claude-workflow/releases/tag/v1.4.0) - 2026-03-29

### Added

- Convention de sélection de modèle (`model: opus | sonnet | haiku`) obligatoire dans le frontmatter de chaque skill, avec grille de catégorisation des 22 skills du plugin et choix du tier intégré dans le flow `/create-skill` ([#26](https://github.com/ToolsForSaaS/claude-workflow/pull/26))

### Changed

- Tous les skills déclarent leur tier de modèle dans le frontmatter (4 opus, 13 sonnet, 5 haiku) et les sub-agents de `/pipe-review` et `/audit-naming` utilisent explicitement sonnet ([`6b7249d`](https://github.com/ToolsForSaaS/claude-workflow/commit/6b7249d), [`e69b5f9`](https://github.com/ToolsForSaaS/claude-workflow/commit/e69b5f9))

### Fixed

- `/pipe-tag` reclassé de haiku à sonnet : le parsing SemVer et la vérification de branche principale nécessitent plus de capacité ([`b1e470e`](https://github.com/ToolsForSaaS/claude-workflow/commit/b1e470e))

## [1.3.3](https://github.com/ToolsForSaaS/claude-workflow/releases/tag/v1.3.3) - 2026-03-29

### Fixed

- Les en-têtes de version dans `CHANGELOG.md` sont rendus sous forme de lien Markdown vers le tag git correspondant (`## [X.Y.Z](url/releases/tag/vX.Y.Z)`) quand le tag existe ([#23](https://github.com/ToolsForSaaS/claude-workflow/pull/23))

## [1.3.2](https://github.com/ToolsForSaaS/claude-workflow/releases/tag/v1.3.2) - 2026-03-29

### Added

- `/pipe-tag` crée et pousse un tag git annoté sémantique (`vX.Y.Z`) en lisant la version depuis `CHANGELOG.md`, avec vérification préalable de la branche principale. Intégré dans le pipeline après `/pipe-pr` ([#20](https://github.com/ToolsForSaaS/claude-workflow/pull/20))

## [1.3.1] - 2026-03-29

### Added

- Chaque entrée de CHANGELOG se termine par une référence traçable cliquable en fin de ligne : `([#NN](url/pull/NN))` si une PR est associée, `([` SHA `](url/commit/SHA))` en fallback ([#19](https://github.com/ToolsForSaaS/claude-workflow/pull/19))

## [1.3.0] - 2026-03-29

### Added

- `/audit-naming` audite les conventions de nommage du projet (fichiers, dossiers, variables, fonctions, classes/types) avec référentiel dédié consommé automatiquement par `/pipe-review` ([#15](https://github.com/ToolsForSaaS/claude-workflow/pull/15))
- `/pipe-changelog` génère et maintient `CHANGELOG.md` selon Keep a Changelog et SemVer, avec référentiel de conventions (types, exclusions, format des entrées) ([#17](https://github.com/ToolsForSaaS/claude-workflow/pull/17))

### Changed

- Pipeline réordonné : `/pipe-test` → `/pipe-changelog` → `/pipe-pr` ([#17](https://github.com/ToolsForSaaS/claude-workflow/pull/17))

### Fixed

- `/pipe-code` expose une séquence git explicite (création et basculement de branche) avant toute écriture de code ([#13](https://github.com/ToolsForSaaS/claude-workflow/pull/13))

## [1.2.4] - 2026-03-28

### Fixed

- Compatibilité sandbox : tous les appels `ls` inline remplacés par `Glob` ou `Read` dans l'ensemble des skills ([`4e3b0a4`](https://github.com/ToolsForSaaS/claude-workflow/commit/4e3b0a4))

## [1.2.3] - 2026-03-28

### Fixed

- Compatibilité sandbox : `ls` remplacé par `Glob` dans `/create-skill` ([`52ee483`](https://github.com/ToolsForSaaS/claude-workflow/commit/52ee483))

## [1.2.2] - 2026-03-27

## [1.2.1] - 2026-03-27

### Removed

- `/setup-init` supprimé — sa fonctionnalité est désormais intégrée dans `/setup` ([`a7bb330`](https://github.com/ToolsForSaaS/claude-workflow/commit/a7bb330))

## [1.2.0] - 2026-03-27

### Changed

- Tous les skills alignés sur le template canonique unifié (frontmatter standardisé, structure de sections homogène) ([`37013b6`](https://github.com/ToolsForSaaS/claude-workflow/commit/37013b6))

### Fixed

- Compatibilité sandbox : `ls` remplacé par `Glob` dans `/audit-skills` ([`72e5f8c`](https://github.com/ToolsForSaaS/claude-workflow/commit/72e5f8c))

## [1.1.0] - 2026-03-27

### Added

- `/create-skill` expose un pattern sub-agents pour analyser plusieurs fichiers en parallèle lors de la conception d'un skill ([`81c5cda`](https://github.com/ToolsForSaaS/claude-workflow/commit/81c5cda))
- `/audit-skills` (extrait de `/create-skill`) évalue la maturité AI-Driven Development du projet sur 7 axes avec scoring 1-10 ([`20088cc`](https://github.com/ToolsForSaaS/claude-workflow/commit/20088cc))

## [1.0.0] - 2026-03-27

### Added

- Pipeline AI-Driven Development complet : `/pipe-hello` → `/pipe-plan` → `/pipe-code` → `/pipe-review` → `/pipe-test` → `/pipe-pr` ([`60bcaba`](https://github.com/ToolsForSaaS/claude-workflow/commit/60bcaba))
- `/setup` configure un projet complet (CLAUDE.md, workflow-config, hooks, plans, rules) en une passe ([#9](https://github.com/ToolsForSaaS/claude-workflow/pull/9))
- `/setup-mcp` génère un `.mcp.exemple.json` de référence avec détection automatique des MCP utilisés ([#2](https://github.com/ToolsForSaaS/claude-workflow/pull/2))
- `/setup-templates` initialise les templates projet-spécifiques dans `.claude/skills/` avec détection des placeholders ([`9f156fd`](https://github.com/ToolsForSaaS/claude-workflow/commit/9f156fd))
- `/setup-ui-ux` génère `.claude/skills/ui-ux/SKILL.md` avec les préférences visuelles et patterns d'interaction du projet ([#2](https://github.com/ToolsForSaaS/claude-workflow/pull/2))
- `/create-skill` crée de nouveaux skills au format `repertoire/SKILL.md` avec frontmatter obligatoire ([`9e23bf6`](https://github.com/ToolsForSaaS/claude-workflow/commit/9e23bf6))
- Skills de conventions partagés : `/frontend-code-conventions` et `/git-conventions` ([`00d17bb`](https://github.com/ToolsForSaaS/claude-workflow/commit/00d17bb))
- Architecture plugin avec manifest `.claude-plugin/plugin.json` et skills distribués sous `skills/nom/SKILL.md` ([#7](https://github.com/ToolsForSaaS/claude-workflow/pull/7))
- Template canonique unifié pour les skills avec frontmatter standardisé et chargement progressif des références ([`843c650`](https://github.com/ToolsForSaaS/claude-workflow/commit/843c650))
- Préfixage des skills par catégorie : `pipe-*` (pipeline), `create-*` (artefacts), `setup-*` (config), `audit-*` (audits) ([#8](https://github.com/ToolsForSaaS/claude-workflow/pull/8))
- Installation du plugin via la marketplace Claude Code ([`951edeb`](https://github.com/ToolsForSaaS/claude-workflow/commit/951edeb))

[Unreleased]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.4.7...HEAD
[1.4.7]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.4.6...v1.4.7
[1.4.6]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.4.5...v1.4.6
[1.4.5]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.4.4...v1.4.5
[1.4.4]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.4.3...v1.4.4
[1.4.3]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.4.2...v1.4.3
[1.4.2]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.4.1...v1.4.2
[1.4.1]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.4.0...v1.4.1
[1.4.0]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.3.3...v1.4.0
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
