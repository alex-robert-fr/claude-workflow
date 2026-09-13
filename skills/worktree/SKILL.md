---
name: worktree
description: Creer, lister, supprimer et basculer entre worktrees git pour travailler en parallele sur plusieurs branches.
argument-hint: [create|list|remove|switch] [branche]
allowed-tools: Read, Bash(git *)
---

**Un worktree par branche, dans `<parent>/<repo>-worktrees/<slug>`** — slug = nom de branche avec `/` remplacé par `-` (`feat/123-login` → `feat-123-login`).

## Contexte

- Worktrees actifs : !`git worktree list`
- Branche courante : !`git branch --show-current`
- Répertoire du repo : !`git rev-parse --show-toplevel`

## Action (`$0`)

| `$0` | Action |
|---|---|
| `create <branche>` | Slug et chemin ; worktree déjà présent → stop ; branche existante → `git worktree add <chemin> <branche>`, sinon `git worktree add -b <branche> <chemin>` |
| `list` (défaut) | Tableau Branche · Chemin · Commit ; aucun worktree supplémentaire → `Aucun worktree supplémentaire. /worktree create <branche> pour en créer un.` |
| `remove <branche>` | Le worktree existe et on n'est pas dedans ; confirmation « Je supprime le worktree `<branche>` à `<chemin>` ? » ; puis `git worktree remove <chemin>` et `git worktree prune` |
| `switch <branche>` | Le worktree existe ; outil `EnterWorktree` avec son chemin |

Action inconnue → affiche les quatre actions, stop. `$1` manquant pour create/remove/switch → stop.

Confirme chaque action en deux lignes (branche, chemin) et le geste suivant : `/worktree switch <branche>` ou `/pipe-code` après create ; `ExitWorktree` ou `/worktree list` après switch ; `/worktree list` après remove.

---

## Input utilisateur

$ARGUMENTS
