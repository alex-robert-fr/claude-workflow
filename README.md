# claude-workflow

Repo central qui contient les commandes et skills Claude Code partagés entre tous mes projets.

Au lieu de dupliquer `.claude/commands/` et `.claude/skills/` dans chaque projet, tout est versionné ici et synchronisé via un script.

## Structure

```
claude-workflow/
  .claude/
    commands/                    # Commandes slash (/plan, /code, /pr, /issue, /github-labels, /lint-setup)
    skills/
      nom/SKILL.md              # Skills partagés (shared, commit-convention, branch-convention, etc.)
  templates/
    nom/SKILL.md                # Squelettes pour les skills projet-specific (code-conventions)
    CLAUDE-skills-index.md      # Index injecté dans le CLAUDE.md des projets
  sync.sh                       # Synchronise un projet
  sync-all.sh                   # Synchronise tous les projets de projects.conf
  projects.conf                 # Liste des projets à synchroniser
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
3. Personnaliser `.claude/skills/code-conventions/SKILL.md` dans le projet (stack, architecture, nommage)

## Fichiers partagés vs projet-specific

| Type | Où | Exemples | Sync |
|------|----|----------|------|
| **Partagé** | `claude-workflow/.claude/commands/` et `.claude/skills/` | plan, code, pr, commit-convention, branch-convention | Ecrasé à chaque sync |
| **Projet-specific** | `.claude/skills/` du projet | code-conventions/SKILL.md | Jamais écrasé (créé une seule fois depuis le template) |

## Workflow de mise à jour

1. Modifier le fichier dans `claude-workflow/.claude/`
2. Commit + push
3. `./sync-all.sh` pour propager à tous les projets
4. Commit les fichiers mis à jour dans chaque projet
