# claude-workflow

Repo central de skills Claude Code, synchronises vers tous les projets via `sync.sh`.

## Regles

- Les fichiers dans `.claude/skills/` sont **partages** — ils sont copies tels quels dans le `.claude/` de chaque projet
- Les fichiers dans `templates/` sont des squelettes pour les fichiers **projet-specific** — ils ne sont copies que si le repertoire n'existe pas encore dans le projet cible
- Ne jamais mettre de logique specifique a un projet (stack, architecture) dans les skills partages — ca va dans les templates
- Chaque skill est un repertoire `nom/SKILL.md` avec frontmatter obligatoire

## Structure

```
.claude/skills/nom/SKILL.md   → copies dans .claude/skills/ de chaque projet
templates/nom/SKILL.md        → copies dans .claude/skills/ uniquement si le repertoire n'existe pas
```

## Scripts

- `sync.sh [path]` — synchronise un projet (defaut: repertoire courant)
- `sync-all.sh` — synchronise tous les projets listes dans `projects.conf`

## Conventions

- Nommage : `kebab-case`, chaque skill est un repertoire `nom/SKILL.md`
- Skills invocables : workflow/action avec `user-invocable: true`
- Skills expertise : conventions/regles avec `user-invocable: false`
- `$ARGUMENTS` toujours en fin de skill invocable
