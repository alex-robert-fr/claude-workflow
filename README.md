# claude-workflow

Plugin Claude Code pour le workflow AI-Driven Development. Fournit un pipeline complet de dev : setup, plan, ship (code → review → test → changelog → PR) et tag.

**13 skills** distribues : le chemin nominal tient en 3 gestes (`/pipe-plan` → `/pipe-ship` → merge → `/pipe-tag`), chaque etape unitaire reste invocable independamment.

Compatible **GitHub** et **Jira** — les skills de planification et d'implementation acceptent des issues des deux plateformes.

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

Les skills sont accessibles avec le namespace `workflow:` (ex: `/workflow:pipe-ship`).

## Pipeline

Chemin nominal — 3 gestes, l'humain ne decide qu'aux vrais points de decision (quoi faire, le code est-il bon, on publie) :

```
/setup (une fois) → /pipe-plan → /pipe-ship → [merge] → /pipe-tag
```

`/pipe-ship` enchaine code → review → tests → changelog → PR et ne s'arrete que sur probleme bloquant (incoherence de plan, bloquant de review, tests rouges apres 3 tentatives) puis demande une seule confirmation avant push + PR.

Chaque etape reste invocable individuellement pour derouler pas a pas :

```
/pipe-code → /pipe-review → /pipe-test → /pipe-changelog → /pipe-pr
```

### Demarrage rapide

1. **Installer** le plugin (voir ci-dessus)
2. **`/workflow:setup`** — configure le projet (CLAUDE.md, hooks, workflow-config) et remplit les placeholders detectes
3. **`/workflow:pipe-plan #42`** — planifie une issue
4. **`/workflow:pipe-ship`** — livre l'issue planifiee

## Guide d'utilisation

### 1. Configuration initiale (une seule fois)

```
/workflow:setup
```

Scaffolde tout le necessaire :
- `CLAUDE.md` avec les instructions du projet
- `.claude/skills/workflow-config/SKILL.md` — **source unique de config projet** : niveau (A: pipeline complet / B: workflow leger), plateforme, commandes lint/test/build, stack, conventions
- Hooks de qualite (PreToolUse, PostToolUse, Stop)
- Remplissage des placeholders `<!-- ... -->` detectes dans `.claude/skills/`

### 2. Planification

```
/workflow:pipe-plan #42
/workflow:pipe-plan PROJ-123
/workflow:pipe-plan https://myorg.atlassian.net/browse/PROJ-123
```

Analyse l'issue (GitHub ou Jira — numero, cle, URL ou texte libre), explore le code concerne et produit un plan technique persiste dans `.claude/plans/`.

### 3. Livraison

```
/workflow:pipe-ship
```

Implemente selon le plan, review par sub-agent, tests avec boucle corrective bornee, changelog, puis PR — une seule confirmation, avant push. Sur un projet **niveau B**, la route se reduit a code → tests → push.

### 4. Merge puis tag

Apres le merge de la PR :

```
/workflow:pipe-tag v1.5.0
```

Cree et pousse un tag git annote SemVer (verifie la branche principale, `git pull --ff-only` avant de tagger, notes extraites du CHANGELOG).

### A tout moment

```
/workflow:pipe-commit      # commit formate selon les conventions (sans friction)
/workflow:create-issue     # transformer une demande en issues structurees
/workflow:worktree         # travailler en parallele sur plusieurs branches
```

## Skills

### Pipeline (`pipe-*`)

| Skill | Description |
|-------|-------------|
| `pipe-plan` | Planifier l'implementation d'une issue |
| `pipe-ship` | Livrer une issue en un geste (code → review → test → changelog → PR) |
| `pipe-code` | Implementer a partir d'un plan ou d'une issue |
| `pipe-review` | Review automatique via sub-agent |
| `pipe-test` | Tests avec boucle corrective (max 3) |
| `pipe-changelog` | Generer/maintenir CHANGELOG.md et TECHNICAL_CHANGES.md |
| `pipe-commit` | Commit formate selon les conventions |
| `pipe-pr` | Creer ou mettre a jour une PR |
| `pipe-tag` | Creer et pousser un tag SemVer (slash-only) |

### Autres skills invocables

| Skill | Description |
|-------|-------------|
| `setup` | Configuration complete du projet, one-shot (slash-only) |
| `create-issue` | Issues GitHub structurees avec decoupage |
| `worktree` | Creer/gerer des worktrees git |

### Conventions (non-invocables)

| Skill | Description |
|-------|-------------|
| `git-conventions` | Branches, commits, PRs |

Les skills marques **slash-only** (`disable-model-invocation: true`) ne coutent aucun contexte en session : ils ne sont charges que quand tu les invoques.

## Structure du plugin

```
claude-workflow/
├── .claude-plugin/
│   └── plugin.json                    # manifest (name, version, author)
├── .claude/skills/
│   └── create-skill/                  # outillage local du repo (non distribue)
├── CLAUDE.md                          # conventions du plugin
├── CHANGELOG.md                       # historique des versions
└── skills/
    ├── pipe-plan/
    ├── pipe-ship/
    ├── pipe-code/
    ├── pipe-review/
    ├── pipe-test/
    ├── pipe-changelog/
    ├── pipe-commit/
    ├── pipe-pr/
    ├── pipe-tag/
    ├── setup/                         # + templates workflow-config et hooks
    ├── create-issue/
    ├── worktree/
    └── git-conventions/
```

## Fichiers projet-specifiques

Le plugin ne contient aucune info specifique a un projet. La config vit dans le `.claude/skills/` du projet cible, creee par `/setup` :

| Fichier | Role |
|---------|------|
| `workflow-config/SKILL.md` | Source unique : niveau de projet, plateforme, commandes, stack, conventions |

Les projets configures avant la v2 peuvent garder leur `tech-stack/SKILL.md` (lu en fallback legacy) ; `/setup` propose la migration vers `workflow-config`.

Ces fichiers ne sont jamais ecrases par une mise a jour du plugin.
