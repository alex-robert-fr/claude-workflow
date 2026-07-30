# claude-workflow

Plugin Claude Code pour le workflow AI-Driven Development. Fournit un pipeline complet de dev : plan co-construit, tests d'abord, dev guide par les tests, review a deux niveaux, commits-changesets, PR et release.

## Pourquoi ce plugin ?

Configurer un workflow AI-Driven Development de zero, c'est des dizaines d'heures de redaction de skills, hooks et conventions — et autant de risques de derive sur la duree. Ce plugin package un pipeline pret a l'emploi qui couvre tout le cycle, de la planification d'une issue jusqu'au tag de release.

**Pour qui ?** Les devs solo et les equipes qui veulent un workflow Claude Code structure sans tout reinventer. **Quel benefice ?** Une reduction de la charge mentale (un seul geste a retenir : `/pipe-ship <ticket>` reprend le cycle ou il en est), l'humain qui n'intervient qu'aux vrais points de decision (le plan, les tests, le code), une qualite garantie par les vrais outils et les hooks (pas par des instructions au LLM), et une coherence entre les sessions et les projets menes en parallele.

**15 skills** distribues : chaque etape du cycle est un skill invocable independamment, et `/pipe-ship` les enchaine depuis le fichier de pilotage.

Lecture de tickets compatible **GitHub** et **Jira** (hierarchie epic → version → demande) — la creation d'issues et de Pull Requests reste sur **GitHub** uniquement.

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

Le cycle d'une demande metier est pilote par un **fichier de pilotage** (`.claude/plans/`, gitignore, ouvert des le cadrage et supprime a la PR) qui porte le plan, les decisions et l'etat d'avancement — c'est lui qui permet de reprendre dans une session neuve, a n'importe quelle phase. L'humain intervient a trois pauses : la **validation de la spec** (les attentes, avant tout dev), la **review des tests** (le contrat de la fonctionnalite) et la **review du code**.

```
/pipe-spec (cadrage de la feature + validation humaine)
→ /pipe-plan (Q/R + plan) → /pipe-test (tests d'abord + review humaine)
→ session neuve : /pipe-code (guide par les tests)
→ session neuve : /pipe-review (outils + agent + review humaine + fraicheur de la spec)
→ /pipe-commit (changesets) → /pipe-pr (vers develop)
```

### Les specs, memoire de tes features

Le cycle demarre par le **cadrage** : `/pipe-spec` produit une spec par feature dans `docs/specs/`, **versionnee** dans le repo — a ne pas confondre avec le plan, qui est ephemere.

| | Spec (`docs/specs/`) | Plan (`.claude/plans/`) |
|---|---|---|
| Repond a | Qu'est-ce que cette feature ? Pourquoi ? | Qu'est-ce qu'on fait, dans quel ordre ? |
| Duree de vie | Durable, versionnee | Ephemere, supprimee a la PR |
| Portee | Une feature, alimentee par N tickets | Un ticket |

Une spec porte l'intention, la philosophie qui tranche les arbitrages, le comportement attendu, le **hors-scope**, les dependances, les decisions prises et les **points d'entree techniques** (quels fichiers, pour quel role).

Deux benefices : les attentes sont alignees **avant** la premiere ligne de code, et les sessions suivantes chargent la spec au lieu de parcourir le codebase — moins de tokens brules, et un contexte global que l'exploration ne donne jamais. `/pipe-review` verifie a chaque cycle que la spec ne ment pas, `/pipe-plan` et `/pipe-code` la lisent.

Pour que ce contexte soit reellement utilise et non simplement disponible, `/setup` installe un hook **SessionStart** qui injecte l'index des specs au demarrage de chaque session : la doc de tes features est presente d'office, sans dependre de la bonne volonte du modele. Cout : l'index seul, une ligne par feature.

Une spec qui ment etant pire que pas de spec, la fraicheur est verifiee a deux niveaux : un script (`check-specs.sh`) lance par `/pipe-review` avec le format et les tests, qui detecte les points d'entree pointant vers des fichiers disparus et les specs oubliees de l'index ; et la review elle-meme, qui juge si le comportement decrit correspond encore au code livre.

**Projet existant ?** `/pipe-spec` sans argument inventorie les features deja livrees, les classe par valeur (les zones les plus retouchees du `git log` sont celles qu'on relira le plus) et en cadre une par passe. Sans ce rattrapage, les specs n'arriveraient qu'au rythme des futurs tickets — donc jamais pour le code deja ecrit.

`/pipe-ship <ticket>` est la commande de reprise : dans chaque session, elle lit le pilotage, detecte la phase courante et deroule jusqu'a la prochaine pause humaine ou frontiere de session. Chaque etape reste invocable individuellement.

Quand assez de features sont mergees sur la branche d'integration :

```
/pipe-release (CHANGELOG metier + PR develop → main) → [merge + deploiement] → /pipe-tag
```

## Une session type

Configuration unique du projet :

```
/workflow:setup            # CLAUDE.md, hooks, workflow-config (+ placeholders)
```

Cycle du ticket PROJ-42 — session 1 (spec + plan + tests) :

```
/workflow:pipe-spec PROJ-42   # lit le ticket Jira, ouvre le pilotage, cadre la feature,
                              # s'arrete pour ta validation de la spec
/workflow:pipe-plan PROJ-42   # Q/R architecture, plan (enchaine depuis la spec)
/workflow:pipe-ship PROJ-42   # ecrit les tests, s'arrete pour ta review des tests
```

Session 2 (dev) puis session 3 (review → PR) :

```
/workflow:pipe-ship PROJ-42   # session neuve : implemente jusqu'a tests verts
/workflow:pipe-ship PROJ-42   # session neuve : format/lint/tests, review agent,
                              # ta review du code, puis commits-changesets et PR
```

Au moment de releaser :

```
/workflow:pipe-release 0.5.2  # CHANGELOG metier + PR develop → main
/workflow:pipe-tag v0.5.2     # tag git annote SemVer (apres merge + deploiement)
```

`pipe-spec`, `pipe-plan` et `pipe-ship` acceptent indifferemment un numero GitHub (`#42`), une cle Jira (`PROJ-123`) ou une URL Jira complete. Le detail de chaque skill est dans son fichier `SKILL.md` (liens dans les tableaux ci-dessous).

## Voie rapide et tickets techniques

Le cycle complet se justifie quand il y a un **comportement a valider**. Regle de tri : comportement a valider → ticket + cycle ; rien a tester → voie rapide.

**Voie rapide** — typo, libelle, casse, config triviale, bump mineur de dependance : ni ticket, ni pilotage, ni spec. Correction directe + `/pipe-commit` (mode simple), puis micro-PR groupee ou push direct selon la protection de branche. Une correction reperee pendant un cycle se fait sur la branche du ticket mais dans un **commit separe**, jamais melangee aux changesets de la feature. `pipe-plan` detecte les tickets trop petits et propose lui-meme cette voie.

**Tickets techniques** (changement d'architecture, migration, mise a jour majeure avec breaking changes) : cycle complet. Ils ne creent pas de spec — mais mettent a jour celle des features touchees (fonctionnement technique, points d'entree, decisions). `pipe-plan` les classifie `technique` (questions orientees architecture), et le contrat de `pipe-test` devient **les tests existants qui doivent rester verts**, completes de tests de caracterisation si la zone est mal couverte. Cote tracker, rattache-les au ticket de version comme les demandes metier (avec un label `tech`) — le CHANGELOG les exclut deja par defaut, sauf impact consommateur.

## Skills

### Pipeline (`pipe-*`)

| Skill | Description |
|-------|-------------|
| [`pipe-ship`](skills/pipe-ship/SKILL.md) | Reprendre le cycle d'un ticket : detecte la phase et deroule jusqu'a la prochaine pause |
| [`pipe-spec`](skills/pipe-spec/SKILL.md) | Cadrer la feature dans une spec durable (`docs/specs/`), ouvrir le pilotage ; sans argument, inventorier l'existant |
| [`pipe-plan`](skills/pipe-plan/SKILL.md) | Co-construire le plan par Q/R (metier + architecture), completer le fichier de pilotage |
| [`pipe-test`](skills/pipe-test/SKILL.md) | Ecrire les tests avant le dev, review humaine — ils deviennent le contrat |
| [`pipe-code`](skills/pipe-code/SKILL.md) | Implementer en session dediee, guide par les tests, jusqu'a tests verts |
| [`pipe-review`](skills/pipe-review/SKILL.md) | Checks outilles + review agent haute valeur + review humaine du code |
| [`pipe-commit`](skills/pipe-commit/SKILL.md) | Decouper le travail en commits-changesets qui servent de doc technique |
| [`pipe-pr`](skills/pipe-pr/SKILL.md) | Creer ou mettre a jour la PR (ticket, version cible, changesets) |
| [`pipe-release`](skills/pipe-release/SKILL.md) | Preparer une release : CHANGELOG metier + PR develop → main (slash-only) |
| [`pipe-changelog`](skills/pipe-changelog/SKILL.md) | Generer/maintenir CHANGELOG.md (court, oriente metier) |
| [`pipe-tag`](skills/pipe-tag/SKILL.md) | Creer et pousser un tag SemVer apres merge + deploiement (slash-only) |

### Utilitaires

Commandes invocables a tout moment, hors du flow principal du pipeline.

| Skill | Description |
|-------|-------------|
| [`setup`](skills/setup/SKILL.md) | Configuration complete du projet, one-shot (slash-only) |
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
    ├── <nom>/               # 15 skills, un repertoire par skill
    │   ├── SKILL.md         # point d'entree (frontmatter + flow)
    │   └── reference.md     # referentiel detaille (optionnel)
    └── setup/scripts/       # scripts universels, copies tels quels par /setup
```

Les scripts (hooks, checks) sont de **vrais fichiers** versionnes, pas des blocs de code dans un markdown : `/setup` les copie (`cp` + `chmod +x`) au lieu de les faire recopier par le modele. Seuls les templates reellement variables — commandes de lint, format et test — restent dans les markdown, avec les valeurs du projet.

**Chargement progressif** : chaque `SKILL.md` reste concis et charge `reference.md` a la demande, uniquement quand le flow en a besoin. Cette decoupe maintient le contexte leger pour les cas simples tout en conservant la profondeur quand elle est utile (exemples : `pipe-changelog`, `pipe-plan`, `pipe-review`).

## Fichiers projet-specifiques

Le plugin ne contient aucune info specifique a un projet. La config vit dans le `.claude/skills/` du projet cible, creee par `/setup` :

| Fichier | Role |
|---------|------|
| `workflow-config/SKILL.md` | Source unique : plateforme, branches, commandes, stack, conventions |

Et, hors `.claude/`, dans le repo du projet cible :

| Fichier | Role |
|---------|------|
| `docs/specs/<feature>.md` | Une spec par feature — versionnee, maintenue par `/pipe-spec` |
| `docs/specs/README.md` | Index des specs : point d'entree unique pour savoir quelles features existent |

Les projets configures avant la 1.5.0 peuvent garder leur `tech-stack/SKILL.md` (lu en fallback legacy) ; `/setup` propose la migration vers `workflow-config`.

Ces fichiers ne sont jamais ecrases par une mise a jour du plugin.

## Ressources

- [CHANGELOG.md](CHANGELOG.md) — historique des versions et evolutions du plugin
- [Repository GitHub](https://github.com/ToolsForSaaS/claude-workflow)
- [Conventions du plugin](CLAUDE.md) — regles internes pour contribuer
