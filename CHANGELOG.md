# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Les détails techniques de chaque changement sont documentés dans les commits et pull requests liés.

## [Unreleased]

## [1.6.0] - 2026-07-30

### Added

- Ajoute `/pipe-spec`, l'étape de cadrage en tête du cycle : elle produit une spec par feature dans `docs/specs/` (versionnée), qui aligne les attentes avant le dev et sert ensuite de contexte de référence — intention, philosophie, comportement attendu, hors-scope, dépendances, décisions et points d'entrée techniques ([#54](https://github.com/ToolsForSaaS/claude-workflow/pull/54))
- Ajoute le mode inventaire de `/pipe-spec` (appel sans argument) : il repère les features déjà livrées d'un projet existant, les classe par valeur et en cadre une par passe — sans quoi les specs n'arriveraient qu'au rythme des futurs tickets ([#54](https://github.com/ToolsForSaaS/claude-workflow/pull/54))
- Gère la fin de vie d'une spec : quand une feature est retirée, `/pipe-review` la passe au statut `depreciee` (version et raison du retrait, corps conservé) au lieu de laisser une doc qui décrit du code disparu. Le hook `SessionStart` cesse alors de l'injecter et `check-specs.sh` cesse de contrôler ses points d'entrée. Le script signale le cas — tous les points d'entrée disparus d'un coup — mais la dépréciation reste une décision humaine ([#54](https://github.com/ToolsForSaaS/claude-workflow/pull/54))
- Ajoute `check-specs.sh`, lancé par `/pipe-review` avec le format, le lint et les tests : il détecte mécaniquement les points d'entrée pointant vers des fichiers disparus et les specs absentes de l'index (donc jamais injectées dans le contexte) ([#54](https://github.com/ToolsForSaaS/claude-workflow/pull/54))

### Changed

- Le cycle démarre par la spec : `/pipe-plan` s'assure qu'elle est à jour avant de planifier, `/pipe-test` en tire les garanties à couvrir, `/pipe-code` la lit comme contexte global, et `/pipe-review` vérifie en fin de cycle qu'elle ne ment pas ([#54](https://github.com/ToolsForSaaS/claude-workflow/pull/54))
- `/setup` crée `docs/specs/` avec son index, installe un hook `SessionStart` qui injecte cet index dans le contexte de chaque session — les specs sont lues d'office et non plus sur bonne volonté du modèle — et ajoute au `CLAUDE.md` du projet le pointeur correspondant ([#54](https://github.com/ToolsForSaaS/claude-workflow/pull/54))
- `/pipe-review` ne se contente plus de matcher les points d'entrée exacts pour repérer les specs à vérifier : il croise aussi le répertoire, la spec du pilotage et les écarts du check outillé. Un fichier structurant ajouté par le ticket ne figure dans aucune liste de points d'entrée — c'était l'angle mort, et précisément le cas où la spec devient fausse ([#54](https://github.com/ToolsForSaaS/claude-workflow/pull/54))
- Le fichier de pilotage est désormais ouvert par `/pipe-spec` dès l'identification de la feature, et non plus à la création du plan : la phase de cadrage devient reprenable par `/pipe-ship` dans une session neuve, comme les autres ([#54](https://github.com/ToolsForSaaS/claude-workflow/pull/54))
- Les scripts distribués (hooks universels, checks) sont désormais de vrais fichiers versionnés dans `skills/setup/scripts/`, copiés tels quels par `/setup`, au lieu de blocs de code que le modèle recopiait depuis un markdown. Seuls les templates réellement variables (lint, format, test) restent documentés en markdown ([#54](https://github.com/ToolsForSaaS/claude-workflow/pull/54))
- Allège le contexte payé à chaque session : les 16 descriptions de skills passent de 3 952 à 1 646 caractères, et les référentiels purs (`git-conventions`, `workflow-config`) sortent du catalogue du modèle puisqu'ils ne sont jamais invoqués, seulement lus ([`5bae04b`](https://github.com/ToolsForSaaS/claude-workflow/commit/5bae04b), [`7a1e112`](https://github.com/ToolsForSaaS/claude-workflow/commit/7a1e112))
- Allège le contexte chargé à l'invocation des skills : `/pipe-review` ne charge plus le contenu des fichiers que son sous-agent relit déjà (~14 000 tokens par review), et `/pipe-tag` comme `/pipe-changelog` n'extraient plus qu'une section du CHANGELOG au lieu du fichier entier (~12 200 tokens par release) ([`7b9b4ab`](https://github.com/ToolsForSaaS/claude-workflow/commit/7b9b4ab))
- L'index des specs peut être regroupé en sections thématiques quand leur nombre le justifie ; les noms de fichiers restent à plat ([`f5b33f7`](https://github.com/ToolsForSaaS/claude-workflow/commit/f5b33f7))

### Fixed

- `/setup` câblait dans `settings.json` des hooks `PostToolUse` et `Stop` pointant vers des fichiers inexistants, et son placeholder d'extensions produisait un JSON invalide qui cassait les quatre hooks d'un coup. Les scripts sont désormais copiés tels quels, le template est validé par `jq`, et le diagnostic vérifie que chaque commande pointe vers un fichier existant ([`4a59e7a`](https://github.com/ToolsForSaaS/claude-workflow/commit/4a59e7a))
- Le hook `Stop` ne bloquait jamais : il sortait en `exit 1` avec son diagnostic sur stdout, alors que seul un `exit 2` avec message sur stderr arrête la fin de tâche. Des tests pouvaient échouer sans que le garde-fou intervienne ([`4a59e7a`](https://github.com/ToolsForSaaS/claude-workflow/commit/4a59e7a))
- Le hook `PreToolUse` bloquait sans transmettre son motif : Claude recevait « No stderr output » et pouvait retenter la même commande ([`7770502`](https://github.com/ToolsForSaaS/claude-workflow/commit/7770502))
- Les hooks des specs étaient silencieusement inertes hors locale UTF-8 : une spec dépréciée continuait d'être injectée dans chaque session, et une spec absente de l'index passait au vert dès qu'une autre spec contenait son nom ([`33ffff1`](https://github.com/ToolsForSaaS/claude-workflow/commit/33ffff1))

## [1.5.0] - 2026-07-12

> **BREAKING** : cette version refond le pipeline (v2). Les projets configurés doivent repasser par `/setup` pour migrer `tech-stack` vers `workflow-config` et adopter le nouveau cycle.

### Added

- Ajoute `/pipe-ship <ticket>`, la commande de reprise du cycle : elle lit le fichier de pilotage, détecte la phase courante et déroule jusqu'à la prochaine pause humaine ou frontière de session ([#52](https://github.com/ToolsForSaaS/claude-workflow/pull/52), [`3fcfa3c`](https://github.com/ToolsForSaaS/claude-workflow/commit/3fcfa3c))
- Ajoute `/pipe-release` : écrit le CHANGELOG orienté métier au moment de livrer, puis crée la PR de la branche d'intégration vers la branche de production ([#52](https://github.com/ToolsForSaaS/claude-workflow/pull/52))
- Ajoute la voie rapide : les changements sans comportement à tester (typo, libellé, bump mineur) passent par `/pipe-commit` sans ticket ni pilotage ([#52](https://github.com/ToolsForSaaS/claude-workflow/pull/52))
- Ajoute le contrat des tickets techniques (refactor, migration) : les tests existants doivent rester verts, complétés de tests de caractérisation si la zone touchée est mal couverte ([#52](https://github.com/ToolsForSaaS/claude-workflow/pull/52))

### Changed

- **BREAKING** — Refond le cycle d'un ticket en TDD piloté : plan co-construit par Q/R (`/pipe-plan`), tests écrits et validés par review humaine avant le dev (`/pipe-test`), dev puis review en sessions dédiées (`/pipe-code`, `/pipe-review`), le tout porté par un fichier de pilotage dans `.claude/plans/` ([#52](https://github.com/ToolsForSaaS/claude-workflow/pull/52))
- **BREAKING** — Fait de `workflow-config` la source unique de configuration projet (plateforme, commandes, stack, branche de production, clés JIRA) ; l'ancien `tech-stack` reste lu en fallback et `/setup` propose la migration ([`d8fa7f5`](https://github.com/ToolsForSaaS/claude-workflow/commit/d8fa7f5), [#52](https://github.com/ToolsForSaaS/claude-workflow/pull/52))
- Le CHANGELOG s'écrit au moment de la release, plus après chaque feature — le détail technique vit dans les corps de commits vers lesquels chaque entrée pointe ([#52](https://github.com/ToolsForSaaS/claude-workflow/pull/52))
- `/pipe-review` lance format, lint et tests via les commandes du projet avant l'agent de review, qui applique une barre de valeur explicite — un rapport vide est un résultat valide ([#52](https://github.com/ToolsForSaaS/claude-workflow/pull/52))
- `/pipe-commit` gagne le mode découpage en commits-changesets en fin de cycle ; le mode simple committe directement sans confirmation systématique, seul le push reste confirmé ([`2e54e3f`](https://github.com/ToolsForSaaS/claude-workflow/commit/2e54e3f), [#52](https://github.com/ToolsForSaaS/claude-workflow/pull/52))
- `/pipe-pr` clôt le cycle : le body porte le ticket, la version cible et les changesets depuis le pilotage, qui est supprimé à la création de la PR ([#52](https://github.com/ToolsForSaaS/claude-workflow/pull/52))
- Les branches et PRs acceptent les clés de tickets externes (`feat/PROJ-42-...`) en plus des numéros d'issues ([#52](https://github.com/ToolsForSaaS/claude-workflow/pull/52))
- `/pipe-changelog` associe les PR aux commits en un seul appel `gh` batch, n'execute l'audit de coherence historique qu'en release (ou sur demande) et ne demande plus qu'une confirmation unique avant ecriture ([`b644459`](https://github.com/ToolsForSaaS/claude-workflow/commit/b644459))
- Retire le champ `model` du frontmatter de tous les skills : il bascule reellement le modele pour le reste du tour (auto-invocation comprise) et pouvait retrograder la session ([`d7af963`](https://github.com/ToolsForSaaS/claude-workflow/commit/d7af963))
- Passe `/setup`, `/pipe-tag` et `/pipe-release` en slash-only (`disable-model-invocation: true`) : leur description ne coute plus de contexte a chaque session ([`128de48`](https://github.com/ToolsForSaaS/claude-workflow/commit/128de48), [#52](https://github.com/ToolsForSaaS/claude-workflow/pull/52))

### Removed

- **BREAKING** — Supprime 7 skills sans usage mesure : `/pipe-hello`, `/setup-mcp`, `/setup-ui-ux`, `/audit-lint`, `/audit-naming`, `/audit-skills` et `frontend-code-conventions` ([`b5099f0`](https://github.com/ToolsForSaaS/claude-workflow/commit/b5099f0))
- **BREAKING** — Supprime `/setup-templates` ; son remplissage de placeholders est integre au diagnostic de `/setup` ([`7c1697c`](https://github.com/ToolsForSaaS/claude-workflow/commit/7c1697c))
- **BREAKING** — Supprime le skill interne `_workflow-persona` et son chargement systematique en tete de chaque skill ([`b3b567f`](https://github.com/ToolsForSaaS/claude-workflow/commit/b3b567f))
- **BREAKING** — Retire `/create-skill` de la distribution du plugin — il devient outillage local du repo claude-workflow ([`dd48610`](https://github.com/ToolsForSaaS/claude-workflow/commit/dd48610))

### Fixed

- Corrige la detection du dernier tag dans `/pipe-changelog` : la spec de tri `version:refSort` etait invalide et faisait echouer la commande a chaque run (`--sort=-version:refname`) ([`a7573db`](https://github.com/ToolsForSaaS/claude-workflow/commit/a7573db))
- `/pipe-tag` met a jour la branche locale (`git pull --ff-only`) avant de tagger, pour ne plus poser de tag sur une branche principale en retard sur le remote ([`47c4b5a`](https://github.com/ToolsForSaaS/claude-workflow/commit/47c4b5a))

## [1.4.9] - 2026-07-12

### Added

- Le référentiel changelog gagne une section « Notes de déploiement » : BREAKING en blockquote sous l'en-tête de version, variables d'environnement requises et dépendances inter-services (`Requiert <service> ≥ x.y.z`) ([`a726e2a`](https://github.com/ToolsForSaaS/claude-workflow/commit/a726e2a))

### Changed

- `/pipe-changelog` génère désormais un CHANGELOG unique, court et orienté consommateur : `TECHNICAL_CHANGES.md` est abandonné, le détail technique vit dans les corps de commits vers lesquels chaque entrée pointe, et le skill propose la suppression du fichier obsolète dans les projets qui en ont un ([`a726e2a`](https://github.com/ToolsForSaaS/claude-workflow/commit/a726e2a))
- Le corps de commit devient obligatoire pour tout changement non trivial (`git-conventions`, `/pipe-commit`) — c'est lui qui documente le détail technique ([`a726e2a`](https://github.com/ToolsForSaaS/claude-workflow/commit/a726e2a))
- Refond le `README.md` : nouvelle section « Pourquoi ce plugin ? », catégories de skills réorganisées, liens cliquables vers chaque skill, compatibilité GitHub/Jira explicitée et section « Ressources » ([`ef20049`](https://github.com/ToolsForSaaS/claude-workflow/commit/ef20049))
- Aligne les descriptions de `plugin.json` et `marketplace.json` sur toutes les étapes du pipeline ([`e6cfb84`](https://github.com/ToolsForSaaS/claude-workflow/commit/e6cfb84))

### Fixed

- Synchronise la version annoncée dans `marketplace.json` avec la version réelle du plugin ([`e6cfb84`](https://github.com/ToolsForSaaS/claude-workflow/commit/e6cfb84))

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

[Unreleased]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.6.0...HEAD
[1.6.0]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.5.0...v1.6.0
[1.5.0]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.4.9...v1.5.0
[1.4.9]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.4.8...v1.4.9
[1.4.8]: https://github.com/ToolsForSaaS/claude-workflow/compare/v1.4.7...v1.4.8
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
