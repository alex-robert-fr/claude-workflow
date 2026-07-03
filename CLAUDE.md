# claude-workflow

Plugin Claude Code pour le workflow AI-Driven Development. Fournit un pipeline complet : setup, plan, code, review, test, PR.

## Plugin

Ce repo est un **plugin Claude Code** (`name: workflow`). Les skills sont namespaces : `/workflow:pipe-code`, `/workflow:pipe-review`, etc.

Installation : `claude --plugin-dir /chemin/vers/claude-workflow`

Manifest : `.claude-plugin/plugin.json` (name, version, description, author).

Structure : `.claude-plugin/plugin.json` (manifest), `skills/nom/SKILL.md` (skills distribues).

## Pipeline

Chemin nominal en 3 gestes — l'humain ne decide qu'aux vrais points de decision :

```
/setup (une fois) → /pipe-plan → /pipe-ship → [merge] → /pipe-tag
```

`/pipe-ship` enchaine code → review → test → changelog → PR avec arret uniquement sur bloquant, en reutilisant les skills unitaires (`/pipe-code`, `/pipe-review`, `/pipe-test`, `/pipe-changelog`, `/pipe-pr`) qui restent invocables independamment pour derouler pas a pas.

## Regles

- Les fichiers dans `skills/` sont **partages** — distribues via le plugin
- `.claude/skills/` contient l'outillage local du repo (create-skill) — jamais distribue
- Les templates projet-specifiques sont dans `skills/setup/`, deployes par `/setup`. `workflow-config` est la source unique de config projet (niveau A/B, plateforme, commandes, stack)
- Ne jamais mettre de logique specifique a un projet dans les skills partages
- Chaque skill est un repertoire `nom/SKILL.md` avec frontmatter obligatoire
- La qualite est garantie par les **hooks** et les **sub-agents**, jamais par des instructions au LLM
- References entre skills du plugin : `${CLAUDE_SKILL_DIR}/../autre-skill/`
- References aux fichiers projet-specifiques : `.claude/skills/`

## Versioning

Lors d'une release (`/pipe-changelog` avec version + `/pipe-tag`), toujours mettre a jour la version simultanement dans :
- `.claude-plugin/plugin.json` (champ `version`)
- `.claude-plugin/marketplace.json` (champs `metadata.version` ET `plugins[0].version`)
- `CHANGELOG.md`

Les trois doivent rester strictement synchronises sous peine de desynchroniser la version annoncee dans la marketplace publique.

## Git

Les conventions git (commits, branches, PRs) sont definies dans `skills/git-conventions/SKILL.md`. Les respecter systematiquement.

## Conventions

- Nommage : `kebab-case`, chaque skill est un repertoire `nom/SKILL.md`
- Skills invocables : `user-invocable: true` (defaut)
- Skills expertise : `user-invocable: false`
- `$ARGUMENTS` toujours en fin de skill invocable
- Prefixes : `pipe-*` (pipeline), `create-*` (artefacts), `setup-*` (config), `*-conventions` (expertise)
- Pas de champ `model` dans le frontmatter des skills : il bascule reellement le modele pour le reste du tour (auto-invocation comprise) et peut retrograder la session. Voir `.claude/skills/create-skill/reference.md` section `model`.
