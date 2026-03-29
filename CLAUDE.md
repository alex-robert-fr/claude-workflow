# claude-workflow

Plugin Claude Code pour le workflow AI-Driven Development. Fournit un pipeline complet : setup, plan, code, review, test, PR.

## Plugin

Ce repo est un **plugin Claude Code** (`name: workflow`). Les skills sont namespaces : `/workflow:pipe-code`, `/workflow:pipe-review`, etc.

Installation : `claude --plugin-dir /chemin/vers/claude-workflow`

Manifest : `.claude-plugin/plugin.json` (name, version, description, author).

Structure : `.claude-plugin/plugin.json` (manifest), `skills/nom/SKILL.md` (skills distribues).

## Pipeline

Le workflow suit un pipeline sequentiel avec des gates de validation entre chaque etape. L'humain decide quand passer a l'etape suivante.

```
/setup → /pipe-hello → /pipe-plan → /pipe-code → /pipe-review → /pipe-test → /pipe-changelog → /pipe-pr → [merge] → /pipe-tag → /pipe-notifier
```

Chaque skill guide vers le skill suivant. Pas de skill monolithique — chaque etape est invocable independamment.

## Regles

- Les fichiers dans `skills/` sont **partages** — distribues via le plugin
- Les templates projet-specifiques sont dans `skills/setup/`, deployes par `/setup`
- Ne jamais mettre de logique specifique a un projet dans les skills partages
- Chaque skill est un repertoire `nom/SKILL.md` avec frontmatter obligatoire
- La qualite est garantie par les **hooks** et les **sub-agents**, jamais par des instructions au LLM
- References entre skills du plugin : `${CLAUDE_SKILL_DIR}/../autre-skill/`
- References aux fichiers projet-specifiques : `.claude/skills/`

## Versioning

Lors d'une release (`/pipe-changelog` avec version + `/pipe-tag`), toujours mettre a jour `version` dans `.claude-plugin/plugin.json` en meme temps que le CHANGELOG.

## Git

Les conventions git (commits, branches, PRs) sont definies dans `skills/git-conventions/SKILL.md`. Les respecter systematiquement.

## Conventions

- Nommage : `kebab-case`, chaque skill est un repertoire `nom/SKILL.md`
- Skills invocables : `user-invocable: true` (defaut)
- Skills expertise : `user-invocable: false`
- `$ARGUMENTS` toujours en fin de skill invocable
- Prefixes : `pipe-*` (pipeline), `create-*` (artefacts), `setup-*` (config), `audit-*` (audits), `*-conventions` (expertise), `_*` (interne)
- Chaque skill declare un `model` dans son frontmatter : `opus` (complexe), `sonnet` (standard), `haiku` (simple). Voir `skills/create-skill/reference.md` section `model` pour la grille complete.
