# claude-workflow

Repo central qui contient les skills Claude Code partages entre tous mes projets.

Au lieu de dupliquer `.claude/skills/` dans chaque projet, tout est versionne ici et synchronise via un script.

## Structure

```
claude-workflow/
  .claude/
    skills/
      code/SKILL.md               # /code — implementation
      commit/SKILL.md             # /commit — commit formate
      create-issue/SKILL.md       # /create-issue — issues GitHub
      create-pr/SKILL.md          # /create-pr — Pull Requests
      create-skill/SKILL.md       # /create-skill — creation + audit skills
      frontend-code-conventions/SKILL.md  # conventions architecture frontend
      git-conventions/SKILL.md    # conventions branches/commits/PRs
      init/SKILL.md               # /init — generer CLAUDE.md
      lint-audit/SKILL.md         # /lint-audit — audit lint/format
      prepare-plan/SKILL.md       # /prepare-plan — planification
      setup-mcp/SKILL.md          # /setup-mcp — configurer les MCP
      setup-ui-ux/SKILL.md        # /setup-ui-ux — generer conventions UI/UX
      templates/SKILL.md          # /templates — remplir les templates
      workflow-persona/SKILL.md   # persona commune aux skills workflow
  templates/
    tech-stack/SKILL.md            # squelette stack + conventions projet-specific
    CLAUDE-skills-index.md        # index injecte dans le CLAUDE.md des projets
  sync.sh                         # synchronise un projet
  sync-all.sh                     # synchronise tous les projets de projects.conf
  projects.conf                   # liste des projets a synchroniser
```

## Utilisation

### Synchroniser un projet

```bash
# Depuis n'importe ou, en passant le chemin du projet
./sync.sh /path/to/mon-projet

# Depuis la racine d'un projet
/path/to/claude-workflow/sync.sh .
```

Le script :
- Cree `.claude/skills/` si necessaire
- Copie les skills partages (ecrase les anciens)
- Genere les templates **uniquement s'ils n'existent pas encore**
- Affiche les fichiers mis a jour, ou "Deja a jour" si rien n'a change

### Synchroniser tous les projets d'un coup

```bash
./sync-all.sh
```

Lit `projects.conf` et lance `sync.sh` sur chaque projet liste.

### Ajouter un nouveau projet

1. Ajouter le chemin dans `projects.conf`
2. Lancer `./sync-all.sh`
3. Personnaliser `.claude/skills/tech-stack/SKILL.md` dans le projet (stack, architecture, nommage)

## Fichiers partages vs projet-specific

| Type | Ou | Exemples | Sync |
|------|----|----------|------|
| **Partage** | `claude-workflow/.claude/skills/` | code, commit, create-pr, git-conventions | Ecrase a chaque sync |
| **Projet-specific** | `.claude/skills/` du projet | tech-stack/SKILL.md | Jamais ecrase (cree une seule fois depuis le template) |

## Workflow de mise a jour

1. Modifier le skill dans `claude-workflow/.claude/skills/`
2. Commit + push
3. `./sync-all.sh` pour propager a tous les projets
4. Commit les fichiers mis a jour dans chaque projet
