# claude-workflow

Repo central de commandes et skills Claude Code, synchronisés vers tous les projets via `sync.sh`.

## Règles

- Les fichiers dans `.claude/commands/` et `.claude/skills/` sont **partagés** — ils sont copiés tels quels dans le `.claude/` de chaque projet
- Les fichiers dans `templates/` sont des squelettes pour les fichiers **projet-specific** — ils ne sont copiés que si le fichier n'existe pas encore dans le projet cible
- Ne jamais mettre de logique spécifique à un projet (stack, architecture) dans les fichiers partagés — ça va dans les templates
- Les chemins dans les commandes utilisent `.claude/skills/...` (chemin identique dans ce repo et dans les projets cibles)

## Structure

```
.claude/commands/   → copiés dans .claude/commands/ de chaque projet
.claude/skills/     → copiés dans .claude/skills/ de chaque projet
templates/          → copiés dans .claude/skills/ uniquement si le fichier n'existe pas
```

## Scripts

- `sync.sh [path]` — synchronise un projet (défaut: répertoire courant)
- `sync-all.sh` — synchronise tous les projets listés dans `projects.conf`

## Conventions

- Nommage fichiers : `kebab-case.md`
- Commandes : orchestration (flux, étapes, outils) — pas de savoir métier
- Skills : expertise (règles, critères, formats) — pas de logique d'exécution
- Un skill est référencé dans une commande via `Lis .claude/skills/nom.md`
- `$ARGUMENTS` toujours en fin de commande

## Skills disponibles

Quand un sujet est abordé en conversation (hors commande slash), lis le skill correspondant **avant** de répondre :

| Sujet | Skill à lire |
|-------|-------------|
| Branches git | `.claude/skills/branch-convention.md` |
| Messages de commit | `.claude/skills/commit-convention.md` |
| Pull requests | `.claude/skills/pr-convention.md` |
| Labels GitHub | `.claude/skills/labels-catalog.md` |
| Code, conventions, stack | `.claude/skills/code-conventions.md` |
| Lint, format, DX | `.claude/skills/lint-expertise.md` |
| Créer des commandes/skills | `.claude/skills/cmd-philosophy.md` |
