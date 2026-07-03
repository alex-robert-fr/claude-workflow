# claude-workflow

Plugin Claude Code pour le workflow AI-Driven Development. Fournit un pipeline complet de dev : setup, plan, ship (code → review → test → changelog → PR) et tag.

## Pourquoi ce plugin ?

Configurer un workflow AI-Driven Development de zero, c'est des dizaines d'heures de redaction de skills, hooks et conventions — et autant de risques de derive sur la duree. Ce plugin package un pipeline pret a l'emploi qui couvre tout le cycle, de la planification d'une issue jusqu'au tag de release.

**Pour qui ?** Les devs solo et les equipes qui veulent un workflow Claude Code structure sans tout reinventer. **Quel benefice ?** Une reduction de la charge mentale (le chemin nominal tient en 3 gestes), une qualite garantie par les hooks et les sub-agents (pas par des instructions au LLM), et une coherence entre les sessions et entre les membres de l'equipe.

**13 skills** distribues : `/pipe-ship` livre une issue en un seul geste, chaque etape unitaire reste invocable independamment.

Lecture d'issues compatible **GitHub** et **Jira** (`pipe-plan`, `pipe-code`, `pipe-ship`) — la creation d'issues et de Pull Requests reste sur **GitHub** uniquement.

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

## Une session type

Configuration unique du projet :

```
/workflow:setup            # CLAUDE.md, hooks, workflow-config (+ placeholders)
```

Travail sur l'issue #42 :

```
/workflow:pipe-plan #42    # analyse l'issue, produit un plan technique persiste
/workflow:pipe-ship        # implemente, review, teste, changelog, PR — 1 confirmation
```

Au moment de releaser :

```
/workflow:pipe-changelog 1.5.0  # cree la section versionnee
/workflow:pipe-tag v1.5.0       # tag git annote SemVer (apres merge)
```

`pipe-plan`, `pipe-code` et `pipe-ship` acceptent indifferemment un numero GitHub (`#42`), une cle Jira (`PROJ-123`) ou une URL Jira complete. Le detail de chaque skill est dans son fichier `SKILL.md` (liens dans les tableaux ci-dessous).

Sur un projet **niveau B** (script/outil declare dans `workflow-config`), `/pipe-ship` reduit sa route a code → tests → push, sans changelog ni review formelle.

## Skills

### Pipeline (`pipe-*`)

| Skill | Description |
|-------|-------------|
| [`pipe-plan`](skills/pipe-plan/SKILL.md) | Planifier l'implementation d'une issue |
| [`pipe-ship`](skills/pipe-ship/SKILL.md) | Livrer une issue en un geste (code → review → test → changelog → PR) |
| [`pipe-code`](skills/pipe-code/SKILL.md) | Implementer a partir d'un plan ou d'une issue |
| [`pipe-review`](skills/pipe-review/SKILL.md) | Review automatique via sub-agent |
| [`pipe-test`](skills/pipe-test/SKILL.md) | Tests avec boucle corrective (max 3) |
| [`pipe-changelog`](skills/pipe-changelog/SKILL.md) | Generer/maintenir CHANGELOG.md et TECHNICAL_CHANGES.md |
| [`pipe-pr`](skills/pipe-pr/SKILL.md) | Creer ou mettre a jour une PR |
| [`pipe-tag`](skills/pipe-tag/SKILL.md) | Creer et pousser un tag SemVer (slash-only) |

### Utilitaires

Commandes invocables a tout moment, hors du flow principal du pipeline.

| Skill | Description |
|-------|-------------|
| [`setup`](skills/setup/SKILL.md) | Configuration complete du projet, one-shot (slash-only) |
| [`pipe-commit`](skills/pipe-commit/SKILL.md) | Commit formate selon les conventions git, sans friction |
| [`create-issue`](skills/create-issue/SKILL.md) | Issues GitHub structurees avec decoupage |
| [`worktree`](skills/worktree/SKILL.md) | Creer, lister, supprimer et basculer entre worktrees git |

### Referentiels (consultables, non-invocables)

Charges automatiquement par les skills du pipeline qui en dependent.

| Skill | Description |
|-------|-------------|
| [`git-conventions`](skills/git-conventions/SKILL.md) | Branches, commits, Pull Requests |

Les skills marques **slash-only** (`disable-model-invocation: true`) ne coutent aucun contexte en session : ils ne sont charges que quand tu les invoques.

## Structure du plugin

```
claude-workflow/
├── .claude-plugin/
│   ├── plugin.json          # manifest (name, version, author)
│   └── marketplace.json     # vitrine pour la marketplace publique
├── .claude/skills/
│   └── create-skill/        # outillage local du repo (non distribue)
├── CLAUDE.md                # conventions du plugin
├── CHANGELOG.md             # historique des versions
└── skills/
    └── <nom>/               # 13 skills, un repertoire par skill
        ├── SKILL.md         # point d'entree (frontmatter + flow)
        └── reference.md     # referentiel detaille (optionnel)
```

**Chargement progressif** : chaque `SKILL.md` reste concis et charge `reference.md` a la demande, uniquement quand le flow en a besoin. Cette decoupe maintient le contexte leger pour les cas simples tout en conservant la profondeur quand elle est utile (exemples : `pipe-changelog`, `pipe-plan`, `pipe-review`).

## Fichiers projet-specifiques

Le plugin ne contient aucune info specifique a un projet. La config vit dans le `.claude/skills/` du projet cible, creee par `/setup` :

| Fichier | Role |
|---------|------|
| `workflow-config/SKILL.md` | Source unique : niveau de projet (A/B), plateforme, commandes, stack, conventions |

Les projets configures avant la 1.5.0 peuvent garder leur `tech-stack/SKILL.md` (lu en fallback legacy) ; `/setup` propose la migration vers `workflow-config`.

Ces fichiers ne sont jamais ecrases par une mise a jour du plugin.

## Ressources

- [CHANGELOG.md](CHANGELOG.md) — historique des versions et evolutions du plugin
- [Repository GitHub](https://github.com/ToolsForSaaS/claude-workflow)
- [Conventions du plugin](CLAUDE.md) — regles internes pour contribuer
