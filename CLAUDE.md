# claude-workflow

Plugin Claude Code pour le workflow AI-Driven Development (`name: claude-workflow` dans `.claude-plugin/plugin.json` — les skills sont namespacés `/claude-workflow:pipe-code`).

Le détail fonctionnel — raison d'être, pipeline commenté, specs, voie rapide, installation, inventaire des skills — vit dans `README.md`. Le lire avant de modifier le comportement d'un skill : il est la source unique, ce fichier n'en est pas une copie.

## Pipeline

<!-- pipeline:debut -->
```
/pipe-spec (cadrage de la feature + validation humaine)
→ /pipe-plan (Q/R + plan) → /pipe-test (tests d'abord + review humaine)
→ session neuve : /pipe-code (guidé par les tests, changesets au fil de l'eau)
→ session neuve : /pipe-review (format/lint/tests outillés + agent + review humaine + fraîcheur de la spec)
→ /pipe-commit (découpage en changesets) → /pipe-pr (vers la branche d'intégration)
```
<!-- pipeline:fin -->
`/pipe-ship <ticket>` est la commande de reprise : elle lit le pilotage, détecte la phase et déroule jusqu'à la prochaine pause humaine. Release : `/pipe-release` → [merge + déploiement] → `/pipe-tag`.

Deux documents, deux durées de vie — ne jamais les confondre. La **spec** (`docs/specs/<feature>.md`, versionnée) dit ce que la feature **est** ; le **pilotage** (`.claude/plans/plan-<ticket>.md`, gitignoré) dit ce qu'on **fait** sur ce ticket, et meurt à la PR. Règle de tri : si une phrase devient fausse une fois le ticket mergé, elle n'a rien à faire dans une spec.

## Règles

- Les fichiers de `skills/` sont **partagés** — distribués via le plugin. `.claude/` porte l'outillage local du repo (create-skill, scripts de check) et n'est jamais distribué
- Les templates projet-spécifiques sont dans `skills/setup/`, déployés par `/setup`. `workflow-config` est la source unique de config projet (plateforme, commandes, stack)
- **Un script est un fichier, jamais un bloc de code dans un markdown** : la mécanique appelée par les skills vit dans `shared/scripts/` (exécutée depuis le plugin), les hooks sans variable projet dans `hooks/`, les scripts à variable projet dans `skills/setup/scripts/` (copiés par `/setup`). Seuls les templates réellement variables (commandes de lint, format, test) restent dans les markdown — le pourquoi est dans `README.md`
- La qualité est garantie par les **hooks** et les **agents** (`agents/`), jamais par des instructions au LLM. Outillage local : `.claude/scripts/check-skills.sh` (cohérence des skills), `measure-skills.sh` (graphe de chargement, avant/après toute refonte), `test-hooks.sh` et `test-scripts.sh` (hooks et scripts partagés), `claude plugin eval . --scaffold --allow-tools Bash` (comportement des skills, `evals/`) ; `skills/setup/scripts/check-specs.sh` (cohérence des specs, lancé par `/pipe-review`)
- **Doctrine d'un skill** : invariant en tête, puces impératives sans justification, 50–80 lignes ; annexe par chemin seulement pour un contenu conditionnel, un seul niveau ; protocole de sub-agent = agent du plugin ; le pourquoi va dans `README.md`, sauf s'il tranche un conflit réel
- Ne jamais mettre de logique spécifique à un projet dans les skills partagés
- Chaque skill est un répertoire `nom/SKILL.md` avec frontmatter obligatoire
- Références entre skills du plugin : `${CLAUDE_SKILL_DIR}/../autre-skill/`. **Toujours un chemin qualifié**, jamais un nom de fichier nu : `Read` exige un chemin absolu, et un nom nu n'est résolvable que depuis le cwd de ce repo — pas depuis un plugin installé
- Toute ligne ajoutée ici est payée dans **chaque** session : ce fichier reste un aide-mémoire opérationnel, pas de la documentation

## Renvois

- Écrire ou modifier un skill : `.claude/skills/create-skill/` (conventions de nommage, frontmatter, seuils de délégation)
- Commits, branches, Pull Requests : `skills/git-conventions/SKILL.md` — à respecter systématiquement
- Publier une version : `/pipe-release` puis `/pipe-tag`. **`/pipe-release` ne bump pas `plugin.json`** (logique spécifique à ce repo, exclue du skill partagé) : entre son étape 3 (CHANGELOG committé) et son étape 4 (push + PR), lancer `.claude/scripts/bump-version.sh X.Y.Z` et committer avant de pousser — jamais éditer `version` à la main. Sans ce bump, aucun utilisateur ne reçoit quoi que ce soit et `/plugin update` répond « already at the latest version » : panne totale et silencieuse, qu'aucun test ne rattrape. Même exigence pour la cible d'installation de `marketplace.json` (`repo`, `homepage`, `repository`) : divergente du remote, elle fait installer un autre dépôt que celui publié
