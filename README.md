# claude-workflow

Plugin Claude Code pour le workflow AI-Driven Development. Fournit un pipeline complet de dev : setup, plan, code, review, test, changelog, PR et tag.

## Pourquoi ce plugin ?

Configurer un workflow AI-Driven Development de zero, c'est des dizaines d'heures de redaction de skills, hooks et conventions — et autant de risques de derive sur la duree. Ce plugin packager un pipeline pret a l'emploi qui couvre tout le cycle, de la planification d'une issue jusqu'au tag de release.

**Pour qui ?** Les devs solo et les equipes qui veulent un workflow Claude Code structure sans tout reinventer. **Quel benefice ?** Une reduction de la charge mentale (chaque etape est nommee et invocable), une qualite garantie par les hooks et les sub-agents (pas par des instructions au LLM), et une coherence entre les sessions et entre les membres de l'equipe.

**22 skills** organises en 6 categories, avec selection automatique du modele optimal (opus/sonnet/haiku) par skill.

Lecture d'issues compatible **GitHub** et **Jira** (`pipe-plan`, `pipe-code`) — la creation d'issues et de Pull Requests reste sur **GitHub** uniquement.

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

Le workflow suit un pipeline sequentiel avec des gates de validation entre chaque etape. L'humain decide quand passer a l'etape suivante. Chaque skill est invocable independamment.

```
/setup → /pipe-hello → /pipe-plan → /pipe-code → /pipe-review → /pipe-test → /pipe-changelog → /pipe-pr → [merge] → /pipe-tag
```

### Demarrage rapide

1. **Installer** le plugin (voir ci-dessus)
2. **`/workflow:setup`** — configure le projet (CLAUDE.md, hooks, workflow-config, tech-stack)
3. **`/workflow:setup-templates`** — remplir les templates projet-specifiques
4. **`/workflow:pipe-hello`** — briefing de session, puis commencer a travailler

## Une session type

Configuration unique du projet :

```
/workflow:setup            # CLAUDE.md, hooks, workflow-config, tech-stack
/workflow:setup-templates  # remplir les placeholders
```

Travail sur l'issue #42 :

```
/workflow:pipe-hello        # briefing du contexte projet
/workflow:pipe-plan #42     # analyse l'issue, produit un plan technique
/workflow:pipe-code #42     # cree la branche, implemente, commit chaque etape
/workflow:pipe-review       # sub-agent de review (bugs, securite, conventions)
/workflow:pipe-test         # tests avec boucle corrective bornee a 3 tentatives
/workflow:pipe-changelog    # alimente la section Unreleased du CHANGELOG
/workflow:pipe-pr           # cree ou met a jour la Pull Request
```

Au moment de releaser :

```
/workflow:pipe-changelog 1.5.0  # cree la section versionnee
/workflow:pipe-tag v1.5.0       # tag git annote SemVer (apres merge)
```

`pipe-plan` et `pipe-code` acceptent indifferemment un numero GitHub (`#42`), une cle Jira (`PROJ-123`) ou une URL Jira complete. Le detail de chaque skill est dans son fichier `SKILL.md` (liens dans le tableau ci-dessous).

## Skills

### Pipeline (`pipe-*`)

| Skill | Description | Modele |
|-------|-------------|--------|
| [`pipe-hello`](skills/pipe-hello/SKILL.md) | Briefing de debut de session | haiku |
| [`pipe-plan`](skills/pipe-plan/SKILL.md) | Planifier l'implementation d'une issue | opus |
| [`pipe-code`](skills/pipe-code/SKILL.md) | Implementer a partir d'un plan ou d'une issue | opus |
| [`pipe-review`](skills/pipe-review/SKILL.md) | Review automatique via sub-agent | sonnet |
| [`pipe-test`](skills/pipe-test/SKILL.md) | Tests avec boucle corrective (max 3) | sonnet |
| [`pipe-changelog`](skills/pipe-changelog/SKILL.md) | Generer/maintenir le CHANGELOG | sonnet |
| [`pipe-pr`](skills/pipe-pr/SKILL.md) | Creer ou mettre a jour une PR | sonnet |
| [`pipe-tag`](skills/pipe-tag/SKILL.md) | Creer et pousser un tag SemVer | sonnet |

### Setup (`setup-*`)

| Skill | Description | Modele |
|-------|-------------|--------|
| [`setup`](skills/setup/SKILL.md) | Configuration complete du projet (one-shot) | sonnet |
| [`setup-templates`](skills/setup-templates/SKILL.md) | Remplir les templates projet-specifiques | sonnet |
| [`setup-mcp`](skills/setup-mcp/SKILL.md) | Configurer les MCP du projet | sonnet |
| [`setup-ui-ux`](skills/setup-ui-ux/SKILL.md) | Generer les conventions UI/UX | sonnet |

### Creation (`create-*`)

| Skill | Description | Modele |
|-------|-------------|--------|
| [`create-issue`](skills/create-issue/SKILL.md) | Issues GitHub structurees avec decoupage | opus |
| [`create-skill`](skills/create-skill/SKILL.md) | Creation et audit de skills Claude Code | opus |

### Audit (`audit-*`)

| Skill | Description | Modele |
|-------|-------------|--------|
| [`audit-skills`](skills/audit-skills/SKILL.md) | Audit maturite AI-Driven Development (7 axes, scoring 1-10) | sonnet |
| [`audit-naming`](skills/audit-naming/SKILL.md) | Audit conventions de nommage via sub-agent | sonnet |
| [`audit-lint`](skills/audit-lint/SKILL.md) | Audit lint/format avec recommandations | sonnet |

### Utilitaires

Commandes invocables a tout moment, hors du flow principal du pipeline.

| Skill | Description | Modele |
|-------|-------------|--------|
| [`pipe-commit`](skills/pipe-commit/SKILL.md) | Commit formate selon les conventions git | sonnet |
| [`worktree`](skills/worktree/SKILL.md) | Creer, lister, supprimer et basculer entre worktrees git | sonnet |

### Referentiels (consultables, non-invocables)

Charges automatiquement par les skills du pipeline qui en dependent.

| Skill | Description | Modele |
|-------|-------------|--------|
| `git-conventions` | Branches, commits, Pull Requests | haiku |
| [`frontend-code-conventions`](skills/frontend-code-conventions/SKILL.md) | Architecture frontend | haiku |

### Interne

| Skill | Description | Modele |
|-------|-------------|--------|
| [`_workflow-persona`](skills/_workflow-persona/SKILL.md) | Persona Lead Developer chargee en debut de chaque skill workflow | haiku |

## Tiers de modeles

La selection automatique du modele par skill reduit le cout d'usage Claude Code en reservant Opus aux taches qui en ont besoin (planification, generation de code) et Haiku aux skills legers (briefing, conventions). Sonnet couvre tout le milieu : reviews, configuration, taches structurees.

Chaque skill declare son tier dans son frontmatter :

| Tier | Usage | Skills |
|------|-------|--------|
| **opus** | Raisonnement complexe, generation de code, planification | 4 skills |
| **sonnet** | Taches structurees, reviews, configuration | 14 skills |
| **haiku** | References, conventions, persona | 4 skills |

## Structure du plugin

```
claude-workflow/
├── .claude-plugin/
│   ├── plugin.json          # manifest (name, version, author)
│   └── marketplace.json     # vitrine pour la marketplace publique
├── CLAUDE.md                # conventions du plugin
├── CHANGELOG.md             # historique des versions
└── skills/
    └── <nom>/               # 22 skills, un repertoire par skill
        ├── SKILL.md         # point d'entree (frontmatter + flow)
        ├── reference.md     # referentiel detaille (optionnel)
        ├── templates.md     # patrons reutilisables (optionnel)
        └── guide.md         # guide approfondi (optionnel)
```

**Chargement progressif** : chaque `SKILL.md` reste concis et charge `reference.md` / `templates.md` / `guide.md` a la demande, uniquement quand le flow en a besoin. Cette decoupe maintient le contexte leger pour les cas simples tout en conservant la profondeur quand elle est utile (exemples : `create-skill`, `pipe-changelog`, `pipe-plan`, `pipe-tag`).

## Fichiers projet-specifiques

Le plugin ne contient aucune info specifique a un projet. Les fichiers suivants vivent dans le `.claude/skills/` du projet cible et sont crees par `/setup` :

| Fichier | Role |
|---------|------|
| `workflow-config/SKILL.md` | Commandes lint/test/build, plateforme, notifications |
| `tech-stack/SKILL.md` | Stack technique, conventions de code |
| `ui-ux/SKILL.md` | Conventions UI/UX (cree par `/setup-ui-ux`) |

Ces fichiers ne sont jamais ecrases par une mise a jour du plugin.

## Ressources

- [CHANGELOG.md](CHANGELOG.md) — historique des versions et evolutions du plugin
- [Repository GitHub](https://github.com/ToolsForSaaS/claude-workflow)
- [Conventions du plugin](CLAUDE.md) — regles internes pour contribuer
