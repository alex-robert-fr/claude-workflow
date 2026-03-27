# claude-workflow

Plugin Claude Code pour le workflow AI-Driven Development. Fournit un pipeline complet de dev : setup, plan, code, review, test, PR.

## Installation

### Via la marketplace (recommande)

Dans Claude Code :

```
/plugin marketplace add ToolsForSaaS/claude-workflow
/plugin install workflow
```

Puis recharger les plugins :

```
/reload-plugins
```

### Via clone local (dev / contribution)

```bash
git clone git@github.com:ToolsForSaaS/claude-workflow.git
```

Puis dans `.claude/settings.json` du projet cible :

```json
{
  "plugins": ["/chemin/vers/claude-workflow"]
}
```

Ou pour tester sur une session :

```bash
claude --plugin-dir /chemin/vers/claude-workflow
```

Les skills sont accessibles avec le namespace `workflow:` (ex: `/workflow:pipe-code`).

## Pipeline

Le workflow suit un pipeline sequentiel. L'humain decide quand passer a l'etape suivante.

```
/setup → /pipe-hello → /pipe-plan → /pipe-code → /pipe-review → /pipe-test → /pipe-pr → /pipe-notifier
```

### Demarrage rapide

1. Installer le plugin (voir ci-dessus)
2. `/workflow:setup` — configure le projet (CLAUDE.md, hooks, workflow-config, tech-stack)
3. `/workflow:pipe-hello` — briefing de session

## Skills

### Pipeline (`pipe-*`)

| Skill | Description |
|-------|-------------|
| `pipe-hello` | Briefing de debut de session |
| `pipe-plan` | Planifier l'implementation d'une issue |
| `pipe-code` | Implementer a partir d'un plan |
| `pipe-review` | Review automatique via sub-agent |
| `pipe-test` | Tests avec boucle corrective (max 3) |
| `pipe-commit` | Commit formate selon les conventions |
| `pipe-pr` | Creer ou mettre a jour une PR |
| `pipe-notifier` | Notification apres creation de PR |

### Setup (`setup-*`)

| Skill | Description |
|-------|-------------|
| `setup` | Configuration complete du projet (one-shot) |
| `setup-templates` | Remplir les templates projet-specifiques |
| `setup-mcp` | Configurer les MCP du projet |
| `setup-ui-ux` | Generer les conventions UI/UX |

### Creation (`create-*`)

| Skill | Description |
|-------|-------------|
| `create-issue` | Issues GitHub structurees avec decoupage |
| `create-skill` | Creation et audit de skills Claude Code |

### Audit (`audit-*`)

| Skill | Description |
|-------|-------------|
| `audit-lint` | Audit lint/format avec recommandations |

### Conventions (non-invocables)

| Skill | Description |
|-------|-------------|
| `git-conventions` | Branches, commits, PRs |
| `frontend-code-conventions` | Architecture frontend |
| `_workflow-persona` | Persona commune (interne) |

## Structure du plugin

```
claude-workflow/
├── .claude-plugin/
│   └── plugin.json              # manifest du plugin
└── skills/
    ├── pipe-code/SKILL.md       # pipeline
    ├── pipe-review/SKILL.md
    ├── setup/SKILL.md           # setup + templates de reference
    ├── create-issue/SKILL.md    # creation
    ├── audit-lint/SKILL.md      # audit
    ├── git-conventions/SKILL.md # conventions
    └── _workflow-persona/SKILL.md # interne
```

## Fichiers projet-specifiques

Le plugin ne contient aucune info specifique a un projet. Les fichiers suivants vivent dans le `.claude/skills/` du projet cible et sont crees par `/setup` :

| Fichier | Role |
|---------|------|
| `workflow-config/SKILL.md` | Commandes lint/test/build, plateforme, notifications |
| `tech-stack/SKILL.md` | Stack technique, conventions de code |
| `ui-ux/SKILL.md` | Conventions UI/UX (cree par `/setup-ui-ux`) |

Ces fichiers ne sont jamais ecrases par une mise a jour du plugin.
