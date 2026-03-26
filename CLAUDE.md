# claude-workflow

Plugin Claude Code pour le workflow AI-Driven Development. Fournit un pipeline complet : setup, plan, code, review, test, PR.

## Plugin

Ce repo est un **plugin Claude Code** (`name: workflow`). Les skills sont namespaces : `/workflow:pipe-code`, `/workflow:pipe-review`, etc.

### Installation

Ajouter dans le `settings.json` du projet cible ou tester localement :

```bash
claude --plugin-dir /chemin/vers/claude-workflow
```

### Manifest

`.claude-plugin/plugin.json` definit le plugin (name, version, description, author).

## Pipeline

Le workflow suit un pipeline sequentiel avec des gates de validation entre chaque etape. L'humain decide quand passer a l'etape suivante.

```
/setup → /pipe-hello → /pipe-plan → /pipe-code → /pipe-review → /pipe-test → /pipe-pr → /pipe-notifier
```

Chaque skill guide vers le skill suivant. Pas de skill monolithique — chaque etape est invocable independamment.

## Regles

- Les fichiers dans `skills/` sont **partages** — ils sont distribues via le plugin
- Les fichiers dans `templates/` sont des squelettes pour les fichiers **projet-specific** — ils ne sont copies que si le repertoire n'existe pas encore dans le projet cible
- Ne jamais mettre de logique specifique a un projet (stack, architecture) dans les skills partages — ca va dans les templates
- Chaque skill est un repertoire `nom/SKILL.md` avec frontmatter obligatoire
- La qualite est garantie par les **hooks** (lint/format) et les **sub-agents** (review), jamais par des instructions au LLM
- Les references entre skills du plugin utilisent `${CLAUDE_SKILL_DIR}/../autre-skill/`
- Les references aux fichiers projet-specifiques (`workflow-config`, `tech-stack`, `ui-ux`) restent en `.claude/skills/`

## Structure

```
.claude-plugin/plugin.json    → manifest du plugin
skills/nom/SKILL.md           → skills distribues via le plugin
templates/nom/SKILL.md        → copies dans .claude/skills/ du projet cible uniquement si le repertoire n'existe pas
```

## Scripts (legacy)

- `sync.sh [path]` — synchronise un projet (defaut: repertoire courant)
- `sync-all.sh` — synchronise tous les projets listes dans `projects.conf`

## Conventions

- Nommage : `kebab-case`, chaque skill est un repertoire `nom/SKILL.md`
- Skills invocables : workflow/action avec `user-invocable: true`
- Skills expertise : conventions/regles avec `user-invocable: false`
- `$ARGUMENTS` toujours en fin de skill invocable

### Convention de nommage des skills

| Prefixe / pattern | Type | Exemples |
|-------------------|------|----------|
| `pipe-*` | Etape du pipeline de dev | `pipe-code`, `pipe-review`, `pipe-test`, `pipe-plan` |
| `create-*` | Cree un artefact (issue, skill) | `create-issue`, `create-skill` |
| `setup-*` | Configure un aspect du projet (one-shot) | `setup`, `setup-init`, `setup-mcp`, `setup-ui-ux` |
| `audit-*` | Audite et recommande des corrections | `audit-lint` |
| `*-conventions` | Expertise passive (non-invocable) | `git-conventions`, `frontend-code-conventions` |
| `_*` | Skill interne (charge automatiquement, non-invocable) | `_workflow-persona` |
