# claude-workflow

Repo central qui contient les commandes et skills Claude Code partagés entre tous mes projets.

Au lieu de dupliquer `.claude/commands/` et `.claude/skills/` dans chaque projet, tout est versionné ici et synchronisé via un script.

## Structure

```
claude-workflow/
  .claude/
    commands/        # Commandes slash (/plan, /code, /pr, /issue, /cmd, /github-labels, /lint-setup)
    skills/          # Skills partagés (shared, commit-convention, branch-convention, pr-convention, cmd, github-labels, lint-setup)
  templates/         # Squelettes pour les fichiers projet-specific (code-conventions.md)
  sync.sh            # Synchronise un projet
  sync-all.sh        # Synchronise tous les projets de projects.conf
  projects.conf      # Liste des projets à synchroniser
```

## Utilisation

### Synchroniser un projet

```bash
# Depuis n'importe où, en passant le chemin du projet
./sync.sh /path/to/mon-projet

# Depuis la racine d'un projet
/path/to/claude-workflow/sync.sh .
```

Le script :
- Crée `.claude/commands/` et `.claude/skills/` si nécessaire
- Copie les commandes et skills partagés (écrase les anciens)
- Génère les fichiers templates (ex: `code-conventions.md`) **uniquement s'ils n'existent pas encore**
- Affiche les fichiers mis à jour, ou "Déjà à jour" si rien n'a changé

### Synchroniser tous les projets d'un coup

```bash
./sync-all.sh
```

Lit `projects.conf` et lance `sync.sh` sur chaque projet listé.

### Ajouter un nouveau projet

1. Ajouter le chemin dans `projects.conf`
2. Lancer `./sync-all.sh`
3. Personnaliser `.claude/skills/code-conventions.md` dans le projet (stack, architecture, nommage)

## Fichiers partagés vs projet-specific

| Type | Où | Exemples | Sync |
|------|----|----------|------|
| **Partagé** | `claude-workflow/.claude/commands/` et `.claude/skills/` | plan, code, pr, commit-convention, branch-convention | Ecrasé à chaque sync |
| **Projet-specific** | `.claude/skills/` du projet | code-conventions.md | Jamais écrasé (créé une seule fois depuis le template) |

## Workflow de mise à jour

1. Modifier le fichier dans `claude-workflow/.claude/`
2. Commit + push
3. `./sync-all.sh` pour propager à tous les projets
4. Commit les fichiers mis à jour dans chaque projet
