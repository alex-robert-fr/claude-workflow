# claude-workflow

Plugin Claude Code pour le workflow AI-Driven Development. Fournit un pipeline complet de dev : setup, plan, code, review, test, changelog, PR et tag.

**21 skills** organises en 5 categories, avec selection automatique du modele optimal (opus/sonnet/haiku) par skill.

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

## Guide d'utilisation

### 1. Configuration initiale (une seule fois)

```
/workflow:setup
```

Scaffolde tout le necessaire pour un projet AI-Driven Development :
- `CLAUDE.md` avec les instructions du projet
- `.claude/skills/workflow-config/SKILL.md` — commandes lint/test/build, plateforme, notifications
- `.claude/skills/tech-stack/SKILL.md` — stack technique et conventions de code
- Hooks de pre-commit et de qualite

Ensuite, personnaliser les templates :

```
/workflow:setup-templates
```

Detecte les placeholders (`__PLACEHOLDER__`) dans les fichiers generes et propose des valeurs adaptees au projet.

Optionnel :
- **`/workflow:setup-ui-ux`** — genere les conventions UI/UX (wizard interactif ou theme fourni)
- **`/workflow:setup-mcp`** — genere un `.mcp.exemple.json` avec les MCP detectes dans le projet

### 2. Debut de session

```
/workflow:pipe-hello
```

Affiche un briefing complet : contexte projet, branches actives, travail en cours, etat du repo. A lancer a chaque debut de session.

### 3. Planification

```
/workflow:pipe-plan #42
/workflow:pipe-plan PROJ-123
/workflow:pipe-plan https://myorg.atlassian.net/browse/PROJ-123
```

Analyse l'issue (GitHub ou Jira — numero, cle, URL ou texte libre), explore le code concerne et produit un plan technique detaille : etapes, fichiers a modifier, approche, risques.

### 4. Implementation

```
/workflow:pipe-code #42
/workflow:pipe-code PROJ-123
```

Cree la branche, implemente le code selon le plan, commit chaque etape. Accepte un numero GitHub ou une cle Jira. Fonctionne aussi sans argument si un plan est deja present en session.

### 5. Review

```
/workflow:pipe-review
```

Lance un sub-agent de review automatique qui verifie : patterns du projet, complexite, edge cases, securite, conventions de nommage.

### 6. Tests

```
/workflow:pipe-test
```

Execute les tests avec une boucle corrective bornee (max 3 tentatives). Corrige automatiquement les erreurs entre chaque tentative.

### 7. Changelog

```
/workflow:pipe-changelog 1.5.0
```

Genere ou met a jour le `CHANGELOG.md` depuis les commits. Passer une version pour preparer une release, ou rien pour alimenter la section `[Unreleased]`.

### 8. Pull Request

```
/workflow:pipe-pr
```

Cree ou met a jour la PR GitHub : titre, description structuree et commentaire d'iteration. Detecte automatiquement la branche courante.

### 9. Merge puis Tag

Apres le merge de la PR :

```
/workflow:pipe-tag v1.5.0
```

Cree et pousse un tag git annote SemVer. Verifie qu'on est sur la branche principale et que la version existe dans le CHANGELOG.

## Skills

### Pipeline (`pipe-*`)

| Skill | Description | Modele |
|-------|-------------|--------|
| `pipe-hello` | Briefing de debut de session | haiku |
| `pipe-plan` | Planifier l'implementation d'une issue | opus |
| `pipe-code` | Implementer a partir d'un plan ou d'une issue | opus |
| `pipe-review` | Review automatique via sub-agent | sonnet |
| `pipe-test` | Tests avec boucle corrective (max 3) | sonnet |
| `pipe-changelog` | Generer/maintenir le CHANGELOG | sonnet |
| `pipe-commit` | Commit formate selon les conventions | sonnet |
| `pipe-pr` | Creer ou mettre a jour une PR | sonnet |
| `pipe-tag` | Creer et pousser un tag SemVer | sonnet |

### Setup (`setup-*`)

| Skill | Description | Modele |
|-------|-------------|--------|
| `setup` | Configuration complete du projet (one-shot) | sonnet |
| `setup-templates` | Remplir les templates projet-specifiques | sonnet |
| `setup-mcp` | Configurer les MCP du projet | sonnet |
| `setup-ui-ux` | Generer les conventions UI/UX | sonnet |

### Creation (`create-*`)

| Skill | Description | Modele |
|-------|-------------|--------|
| `create-issue` | Issues GitHub structurees avec decoupage | opus |
| `create-skill` | Creation et audit de skills Claude Code | opus |

### Audit (`audit-*`)

| Skill | Description | Modele |
|-------|-------------|--------|
| `audit-skills` | Audit maturite AI-Driven Development (7 axes, scoring 1-10) | sonnet |
| `audit-naming` | Audit conventions de nommage via sub-agent | sonnet |
| `audit-lint` | Audit lint/format avec recommandations | sonnet |

### Conventions (non-invocables)

| Skill | Description | Modele |
|-------|-------------|--------|
| `git-conventions` | Branches, commits, PRs | haiku |
| `frontend-code-conventions` | Architecture frontend | haiku |
| `_workflow-persona` | Persona commune (interne) | haiku |

## Tiers de modeles

Chaque skill declare un tier de modele dans son frontmatter pour optimiser le ratio cout/qualite :

| Tier | Usage | Skills |
|------|-------|--------|
| **opus** | Raisonnement complexe, generation de code, planification | 4 skills |
| **sonnet** | Taches structurees, reviews, configuration | 13 skills |
| **haiku** | References, conventions, persona | 4 skills |

## Structure du plugin

```
claude-workflow/
├── .claude-plugin/
│   └── plugin.json                    # manifest (name, version, author)
├── CLAUDE.md                          # conventions du plugin
├── CHANGELOG.md                       # historique des versions
└── skills/
    ├── pipe-hello/SKILL.md            # pipeline
    ├── pipe-plan/SKILL.md
    ├── pipe-code/SKILL.md
    ├── pipe-review/SKILL.md
    ├── pipe-test/SKILL.md
    ├── pipe-changelog/SKILL.md
    ├── pipe-commit/SKILL.md
    ├── pipe-pr/SKILL.md
    ├── pipe-tag/SKILL.md
    ├── setup/SKILL.md                 # setup + templates de reference
    ├── setup-templates/SKILL.md
    ├── setup-mcp/SKILL.md
    ├── setup-ui-ux/SKILL.md
    ├── create-issue/SKILL.md          # creation
    ├── create-skill/SKILL.md
    ├── audit-skills/SKILL.md          # audit
    ├── audit-naming/SKILL.md
    ├── audit-lint/SKILL.md
    ├── git-conventions/SKILL.md       # conventions
    ├── frontend-code-conventions/SKILL.md
    └── _workflow-persona/SKILL.md     # interne
```

## Fichiers projet-specifiques

Le plugin ne contient aucune info specifique a un projet. Les fichiers suivants vivent dans le `.claude/skills/` du projet cible et sont crees par `/setup` :

| Fichier | Role |
|---------|------|
| `workflow-config/SKILL.md` | Commandes lint/test/build, plateforme, notifications |
| `tech-stack/SKILL.md` | Stack technique, conventions de code |
| `ui-ux/SKILL.md` | Conventions UI/UX (cree par `/setup-ui-ux`) |

Ces fichiers ne sont jamais ecrases par une mise a jour du plugin.
