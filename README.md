# claude-workflow

Plugin Claude Code pour le workflow AI-Driven Development. Fournit un pipeline complet de dev : plan co-construit, tests d'abord, dev guide par les tests, review a deux niveaux, commits-changesets, PR et release.

## Pourquoi ce plugin ?

Configurer un workflow AI-Driven Development de zero, c'est des dizaines d'heures de redaction de skills, hooks et conventions — et autant de risques de derive sur la duree. Ce plugin package un pipeline pret a l'emploi qui couvre tout le cycle, de la planification d'une issue jusqu'au tag de release.

**Pour qui ?** Les devs solo et les equipes qui veulent un workflow Claude Code structure sans tout reinventer. **Quel benefice ?** Une reduction de la charge mentale (un seul geste a retenir : `/pipe-ship <ticket>` reprend le cycle ou il en est), l'humain qui n'intervient qu'aux vrais points de decision (le plan, les tests, le code), une qualite garantie par les vrais outils et les hooks (pas par des instructions au LLM), et une coherence entre les sessions et les projets menes en parallele.

**14 skills** distribues : chaque etape du cycle est un skill invocable independamment, et `/pipe-ship` les enchaine depuis le fichier de pilotage.

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

Le cycle d'une demande metier est pilote par un **fichier de pilotage** (`.claude/plans/`, gitignore, supprime a la PR) qui porte le plan, les decisions et l'etat d'avancement — c'est lui qui permet de reprendre dans une session neuve. L'humain intervient a deux pauses : la **review des tests** (le contrat de la fonctionnalite) et la **review du code**.

```
/pipe-plan (Q/R + plan) → /pipe-test (tests d'abord + review humaine)
→ session neuve : /pipe-code (guide par les tests)
→ session neuve : /pipe-review (outils + agent + review humaine)
→ /pipe-commit (changesets) → /pipe-pr (vers develop)
```

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

Cycle du ticket PROJ-42 — session 1 (plan + tests) :

```
/workflow:pipe-plan PROJ-42   # lit le ticket Jira (et sa version cible), Q/R, plan + pilotage
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

`pipe-plan` et `pipe-ship` acceptent indifferemment un numero GitHub (`#42`), une cle Jira (`PROJ-123`) ou une URL Jira complete. Le detail de chaque skill est dans son fichier `SKILL.md` (liens dans les tableaux ci-dessous).

## Voie rapide et tickets techniques

Le cycle complet se justifie quand il y a un **comportement a valider**. Regle de tri : comportement a valider → ticket + cycle ; rien a tester → voie rapide.

**Voie rapide** — typo, libelle, casse, config triviale, bump mineur de dependance : ni ticket, ni pilotage. Correction directe + `/pipe-commit` (mode simple), puis micro-PR groupee ou push direct selon la protection de branche. Une correction reperee pendant un cycle se fait sur la branche du ticket mais dans un **commit separe**, jamais melangee aux changesets de la feature. `pipe-plan` detecte les tickets trop petits et propose lui-meme cette voie.

**Tickets techniques** (changement d'architecture, migration, mise a jour majeure avec breaking changes) : cycle complet. `pipe-plan` les classifie `technique` (questions orientees architecture), et le contrat de `pipe-test` devient **les tests existants qui doivent rester verts**, completes de tests de caracterisation si la zone est mal couverte. Cote tracker, rattache-les au ticket de version comme les demandes metier (avec un label `tech`) — le CHANGELOG les exclut deja par defaut, sauf impact consommateur.

## Skills

### Pipeline (`pipe-*`)

| Skill | Description |
|-------|-------------|
| [`pipe-ship`](skills/pipe-ship/SKILL.md) | Reprendre le cycle d'un ticket : detecte la phase et deroule jusqu'a la prochaine pause |
| [`pipe-plan`](skills/pipe-plan/SKILL.md) | Co-construire le plan par Q/R (metier + architecture), creer le fichier de pilotage |
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
    └── <nom>/               # 14 skills, un repertoire par skill
        ├── SKILL.md         # point d'entree (frontmatter + flow)
        └── reference.md     # referentiel detaille (optionnel)
```

**Chargement progressif** : chaque `SKILL.md` reste concis et charge `reference.md` a la demande, uniquement quand le flow en a besoin. Cette decoupe maintient le contexte leger pour les cas simples tout en conservant la profondeur quand elle est utile (exemples : `pipe-changelog`, `pipe-plan`, `pipe-review`).

## Fichiers projet-specifiques

Le plugin ne contient aucune info specifique a un projet. La config vit dans le `.claude/skills/` du projet cible, creee par `/setup` :

| Fichier | Role |
|---------|------|
| `workflow-config/SKILL.md` | Source unique : plateforme, branches, commandes, stack, conventions |

Les projets configures avant la 1.5.0 peuvent garder leur `tech-stack/SKILL.md` (lu en fallback legacy) ; `/setup` propose la migration vers `workflow-config`.

Ces fichiers ne sont jamais ecrases par une mise a jour du plugin.

## Ressources

- [CHANGELOG.md](CHANGELOG.md) — historique des versions et evolutions du plugin
- [Repository GitHub](https://github.com/ToolsForSaaS/claude-workflow)
- [Conventions du plugin](CLAUDE.md) — regles internes pour contribuer
