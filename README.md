# claude-workflow

Plugin Claude Code pour le workflow AI-Driven Development. Fournit un pipeline complet de dev : plan co-construit, tests d'abord, dev guide par les tests, review a deux niveaux, commits-changesets, PR et release.

## Pourquoi ce plugin ?

Configurer un workflow AI-Driven Development de zero, c'est des dizaines d'heures de rédaction de skills, hooks et conventions — et autant de risques de derive sur la duree. Ce plugin package un pipeline pret a l'emploi qui couvre tout le cycle, de la planification d'une issue jusqu'au tag de release.

**Pour qui ?** Les devs solo et les equipes qui veulent un workflow Claude Code structure sans tout reinventer. **Quel benefice ?** Une reduction de la charge mentale (un seul geste a retenir : `/pipe-ship <ticket>` reprend le cycle ou il en est), l'humain qui n'intervient qu'aux vrais points de decision (le plan, les tests, le code), une qualité garantie par les vrais outils et les hooks (pas par des instructions au LLM), et une cohérence entre les sessions et les projets menes en parallele.

**16 skills** distribués : chaque étape du cycle est un skill invocable indépendamment, et `/pipe-ship` les enchaîne depuis le fichier de pilotage. Ils s'appuient sur **6 agents** (review, critique des tests et des specs, audit), **5 hooks** actifs dès l'installation et des **scripts partagés** exécutés depuis le plugin.

Lecture de tickets compatible **GitHub** et **Jira** (hierarchie epic → version → demande) — la creation d'issues et de Pull Requests reste sur **GitHub** uniquement.

## Installation

### Via la marketplace (recommande)

Dans Claude Code :

```
/plugin marketplace add alex-robert-fr/claude-workflow
/plugin install claude-workflow
```

Puis recharger les plugins :

```
/reload-plugins
```

### Via clone local (dev / contribution)

```bash
git clone git@github.com:alex-robert-fr/claude-workflow.git
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

Les skills sont accessibles avec le namespace `claude-workflow:` (ex: `/claude-workflow:pipe-ship`).

## Pipeline

Le cycle d'une demande métier est pilote par un **fichier de pilotage** (`.claude/plans/`, gitignore, ouvert des le cadrage et supprime a la PR) qui porte le plan, les decisions et l'etat d'avancement — c'est lui qui permet de reprendre dans une session neuve, a n'importe quelle phase. L'humain intervient a trois pauses : la **validation de la spec** (les attentes, avant tout dev), la **review des tests** (le contrat de la fonctionnalité) et la **review du code**.

<!-- pipeline:debut -->
```
/pipe-spec (cadrage de la feature + validation humaine)
→ /pipe-plan (Q/R + plan) → /pipe-test (tests d'abord + review humaine)
→ session neuve : /pipe-code (guide par les tests, changesets au fil de l'eau)
→ session neuve : /pipe-review (format/lint/tests outilles + agent + review humaine + fraicheur de la spec)
→ /pipe-commit (decoupage en changesets) → /pipe-pr (vers la branche d'integration)
```
<!-- pipeline:fin -->

Ce diagramme est reproduit a l'identique dans `CLAUDE.md` (aide-memoire de session) et dans le recap de `/setup`. `.claude/scripts/check-skills.sh` verifie qu'ils ne divergent pas : les trois avaient déjà diverge une fois, le dernier ayant perdu une pause humaine.

### Les specs, memoire de tes features

Le cycle demarre par le **cadrage** : `/pipe-spec` produit une spec par feature dans `docs/specs/`, **versionnee** dans le repo — a ne pas confondre avec le plan, qui est ephemere.

| | Spec (`docs/specs/`) | Plan (`.claude/plans/`) |
|---|---|---|
| Repond a | Qu'est-ce que cette feature ? Pourquoi ? | Qu'est-ce qu'on fait, dans quel ordre ? |
| Duree de vie | Durable, versionnee | Ephemere, supprimee a la PR |
| Portee | Une feature, alimentee par N tickets | Un ticket |

Une spec porte l'intention, la philosophie qui tranche les arbitrages, le comportement attendu, le **hors-scope**, les dependances, les decisions prises et les **points d'entrée techniques** (quels fichiers, pour quel rôle).

Deux benefices : les attentes sont alignees **avant** la première ligne de code, et les sessions suivantes chargent la spec au lieu de parcourir le codebase — moins de tokens brules, et un contexte global que l'exploration ne donne jamais. `/pipe-review` verifie a chaque cycle que la spec ne ment pas, `/pipe-plan` et `/pipe-code` la lisent.

Pour que ce contexte soit reellement utilise et non simplement disponible, `/setup` installe un hook **SessionStart** qui injecte l'index des specs au demarrage de chaque session : la doc de tes features est presente d'office, sans dependre de la bonne volonte du modele. Cout : l'index seul, une ligne par feature — c'est le seul poste de contexte qui grossit avec le projet, d'où la phrase de résumé bornée à 80 caractères et vérifiée par script.

Une spec qui ment etant pire que pas de spec, la fraicheur est vérifiée a deux niveaux : un script (`check-specs.sh`) lance par `/pipe-review` avec le format et les tests, qui detecte les points d'entrée pointant vers des fichiers disparus et les specs oubliees de l'index ; et la review elle-meme, qui juge si le comportement decrit correspond encore au code livre.

Quand une feature est **retiree**, sa spec ne se corrige pas : elle passe au statut `depreciee`, avec sa version de retrait et sa raison. Le corps est conserve — il repond a « pourquoi cette feature a existe, et pourquoi elle a disparu », ce qui evite de la reintroduire par erreur. Elle sort alors du contexte injecte et du controle des chemins, sans disparaitre de l'historique.

**Projet existant ?** `/pipe-spec` sans argument inventorie les features déjà livrees, les classe par valeur (les zones les plus retouchees du `git log` sont celles qu'on relira le plus) et en cadre une par passe. Sans ce rattrapage, les specs n'arriveraient qu'au rythme des futurs tickets — donc jamais pour le code déjà ecrit.

`/pipe-ship <ticket>` est la commande de reprise : dans chaque session, elle lit le pilotage, detecte la phase courante et deroule jusqu'a la prochaine pause humaine ou frontiere de session. Sur un ticket qui n'a pas encore de pilotage, elle demarre le cycle par le cadrage — c'est donc aussi la commande d'entrée, pas seulement de reprise. Chaque étape reste invocable individuellement.

Quand assez de features sont mergees sur la branche d'integration :

```
/pipe-release (CHANGELOG métier + PR develop → main) → [merge + deploiement] → /pipe-tag
```

## Une session type

Configuration unique du projet :

```
/claude-workflow:setup            # CLAUDE.md, hooks, workflow-config (+ placeholders)
```

Cycle du ticket PROJ-42 — session 1 (spec + plan + tests) :

```
/claude-workflow:pipe-spec PROJ-42   # lit le ticket Jira, ouvre le pilotage, cadre la feature,
                                     # s'arrete pour ta validation de la spec
/claude-workflow:pipe-plan PROJ-42   # Q/R architecture, plan (enchaine depuis la spec)
/claude-workflow:pipe-ship PROJ-42   # ecrit les tests, s'arrete pour ta review des tests
```

Session 2 (dev) puis session 3 (review → PR) :

```
/claude-workflow:pipe-ship PROJ-42   # session neuve : implemente jusqu'a tests verts
/claude-workflow:pipe-ship PROJ-42   # session neuve : format/lint/tests, review agent,
                                     # ta review du code, puis commits-changesets et PR
```

Au moment de releaser :

```
/claude-workflow:pipe-release 0.5.2  # CHANGELOG métier + PR develop → main
/claude-workflow:pipe-tag v0.5.2     # tag git annote SemVer (apres merge + deploiement)
```

`pipe-spec`, `pipe-plan` et `pipe-ship` acceptent indifferemment un numéro GitHub (`#42`), une cle Jira (`PROJ-123`) ou une URL Jira complète. Le detail de chaque skill est dans son fichier `SKILL.md` (liens dans les tableaux ci-dessous).

## Voie rapide et tickets techniques

Le cycle complet se justifie quand il y a un **comportement a valider**. Règle de tri : comportement a valider → ticket + cycle ; rien a tester → voie rapide.

**Voie rapide** — typo, libelle, casse, config triviale, bump mineur de dependance : ni ticket, ni pilotage, ni spec. Correction directe + `/pipe-commit` (mode simple), puis micro-PR groupee ou push direct selon la protection de branche. Une correction reperee pendant un cycle se fait sur la branche du ticket mais dans un **commit separe**, jamais melangee aux changesets de la feature. `pipe-plan` detecte les tickets trop petits et propose lui-meme cette voie.

**Tickets techniques** (changement d'architecture, migration, mise a jour majeure avec breaking changes) : cycle complet. Ils ne creent pas de spec — mais mettent a jour celle des features touchees (fonctionnement technique, points d'entrée, decisions). `pipe-plan` les classifie `technique` (questions orientees architecture), et le contrat de `pipe-test` devient **les tests existants qui doivent rester verts**, complétés de tests de caracterisation si la zone est mal couverte. Cote tracker, rattache-les au ticket de version comme les demandes métier (avec un label `tech`) — le CHANGELOG les exclut déjà par defaut, sauf impact consommateur.

**Tickets d'investigation** (label `question`, `spike`, titre en « Investiguer ») : la reponse n'existe pas encore, donc rien n'est planifiable. `pipe-spec` les traite en **spike** : le livrable est la spec de la feature concernee, jamais du code. L'exploration (prototype, stories, variantes d'ecran) vit sur une branche `spike/`, poussee pour sauvegarde et jamais mergee ; la spec part seule sur une branche `docs/`, par `/pipe-commit` puis `/pipe-pr`. Une fois mergee, la branche `spike/` est supprimee, le ticket est clos en pointant la spec, et le dev repart de nouveaux tickets (`/create-issue`) avec un cycle complet — on ne nettoie pas un prototype pour le livrer, on le reecrit depuis la spec. `pipe-plan` renvoie vers `pipe-spec` s'il recoit un tel ticket.

## Skills

### Pipeline (`pipe-*`)

| Skill | Description |
|-------|-------------|
| [`pipe-ship`](skills/pipe-ship/SKILL.md) | Reprendre le cycle d'un ticket : detecte la phase et deroule jusqu'a la prochaine pause |
| [`pipe-spec`](skills/pipe-spec/SKILL.md) | Cadrer la feature dans une spec durable (`docs/specs/`), ouvrir le pilotage ; sans argument, inventorier l'existant |
| [`pipe-plan`](skills/pipe-plan/SKILL.md) | Co-construire le plan par Q/R (métier + architecture), completer le fichier de pilotage |
| [`pipe-test`](skills/pipe-test/SKILL.md) | Ecrire les tests avant le dev, review humaine — ils deviennent le contrat |
| [`pipe-code`](skills/pipe-code/SKILL.md) | Implementer en session dediee, guide par les tests, jusqu'a tests verts |
| [`pipe-review`](skills/pipe-review/SKILL.md) | Checks outilles + review agent haute valeur + review humaine du code |
| [`pipe-commit`](skills/pipe-commit/SKILL.md) | Decouper le travail en commits-changesets qui servent de doc technique |
| [`pipe-pr`](skills/pipe-pr/SKILL.md) | Creer ou mettre a jour la PR (ticket, version cible, changesets) |
| [`pipe-release`](skills/pipe-release/SKILL.md) | Preparer une release : CHANGELOG métier + PR develop → main |
| [`pipe-changelog`](skills/pipe-changelog/SKILL.md) | Generer/maintenir CHANGELOG.md (court, oriente métier) |
| [`pipe-tag`](skills/pipe-tag/SKILL.md) | Creer et pousser un tag SemVer apres merge + deploiement |

### Utilitaires

Commandes invocables a tout moment, hors du flow principal du pipeline.

| Skill | Description |
|-------|-------------|
| [`setup`](skills/setup/SKILL.md) | Configuration complète du projet, one-shot |
| [`create-issue`](skills/create-issue/SKILL.md) | Issues GitHub structurees avec decoupage |
| [`worktree`](skills/worktree/SKILL.md) | Creer, lister, supprimer et basculer entre worktrees git |
| [`audit-conformity`](skills/audit-conformity/SKILL.md) | Auditer le code contre un document de reference (spec, règle, skill) et planifier la remediation |

### Referentiels (consultables, non-invocables)

Charges automatiquement par les skills du pipeline qui en dependent.

| Skill | Description |
|-------|-------------|
| [`git-conventions`](skills/git-conventions/SKILL.md) | Branches, commits, Pull Requests |

Tous les skills sont **slash-only** (`disable-model-invocation: true`) : chacun écrit, pousse ou lance des agents, aucun ne doit partir sur une initiative du modèle, et leur description ne coûte ainsi aucun contexte en session — ils ne sont chargés que quand tu les invoques. `check-skills.sh` refuse un skill qui ne le déclare pas.

Chaque skill pré-approuve (`allowed-tools`) les commandes qu'il lance en lecture — scripts du plugin, `git status|log|diff`, `gh pr list|view` — pour le tour qui l'invoque ; `commit`, `push` et `tag` restent soumis à confirmation.

### Agents

Les jugements qui exigent un regard neuf sont confiés à des agents du plugin, lancés par les skills avec le seul contexte utile — une relecture par le modèle qui vient d'écrire est complaisante par construction, l'isolation de contexte est ce qui rend la critique indépendante.

| Agent | Lancé par | Rôle |
|-------|-----------|------|
| [`reviewer`](agents/reviewer.md) | `pipe-review` | Bugs, sécurité, architecture, simplifications nettes — 7 champs par constat |
| [`test-critic`](agents/test-critic.md) | `pipe-test` | Tests redondants, tautologiques, cas limites manquants |
| [`spec-critic`](agents/spec-critic.md) | `pipe-spec` | Budget, redondance, schéma vs prose, lien vs duplication |
| [`auditor`](agents/auditor.md), [`refuter`](agents/refuter.md), [`gap-finder`](agents/gap-finder.md) | `audit-conformity` | Audit par zone, contre-audit, angles morts |

### Garde-fous du plugin

Six hooks déclarés dans [`hooks/hooks.json`](hooks/hooks.json), actifs partout où le plugin est installé, sans `/setup` : accents français (avant écriture et avant de s'arrêter), pédagogie des réponses, commentaires de code (un commentaire qui décrit le *quoi* au lieu du *pourquoi*, ou superflu, est renvoyé pour correction dès l'écriture), conventions git (`git add` par chemins explicites, aucune signature automatique dans un commit ou une PR — la convention prime sur toute instruction de session), et verrou des tests validés tant que la review n'a pas validé le code. Ces règles n'ont plus à être écrites dans les skills : un hook ne les oublie pas.

Deux de ces hooks (pédagogie, commentaires) font appel à un juge LLM en Haiku (`hooks/scripts/judge.sh` : sans thinking, démarrage minimal — environ trois secondes et quelques centimes par verdict), les autres sont déterministes. Le juge de pédagogie ne tourne que sur une réponse substantielle ; celui des commentaires, seulement sur un fichier de code dont le texte écrit contient au moins un commentaire, et en arrière-plan : l'écriture n'attend pas, le retour arrive quelques secondes plus tard.

## Structure du plugin

```
claude-workflow/
├── .claude-plugin/
│   ├── plugin.json          # manifest (name, version, author)
│   └── marketplace.json     # vitrine pour la marketplace publique
├── .claude/skills/
│   └── create-skill/        # outillage local du repo (non distribue)
├── .claude/scripts/         # outillage local : check-skills, measure-skills, test-hooks, test-scripts
├── CLAUDE.md                # conventions du plugin
├── CHANGELOG.md             # historique des versions
├── agents/                  # 6 agents : prompts système des sub-agents du pipeline
├── evals/                   # suite `claude plugin eval` : un cas par comportement, gradé sans relecture humaine
├── hooks/                   # hooks.json + scripts : garde-fous actifs sans /setup
├── shared/
│   ├── pilotage-template.md # template du fichier de pilotage
│   └── scripts/             # find-plan, new-branch, changelog-section, detect-version, list-tickets — exécutés depuis le plugin
└── skills/
    ├── <nom>/               # 16 skills, un repertoire par skill
    │   ├── SKILL.md         # invariant + étapes, 50–80 lignes
    │   └── *.md             # annexes chargées par chemin, selon le besoin (template, spike, fraîcheur…)
    └── setup/scripts/       # scripts universels, copies tels quels par /setup
```

**Évaluer les skills.** `test-hooks.sh` et `test-scripts.sh` prouvent la mécanique, pas le comportement : rien n'y dit si `/pipe-spec` ouvre bien par une vue haut niveau ou si `/pipe-commit` attend la validation. C'est le rôle de `evals/` : chaque cas est un dépôt jetable (`fixture.sh`), un prompt tel qu'un utilisateur le taperait, et des graders surtout déterministes (regex sur la réponse, outil appelé ou non, fichier écrit ou non) — un juge LLM seulement là où une règle ne suffit pas. Lancer `claude plugin eval . --scaffold --allow-tools Bash --no-publish` depuis la racine (Bash exige un sandbox : `bubblewrap` et `socat`) ; `--case <nom> --runs 1 --ablation none` pour itérer à moindre coût, la baseline sans plugin dit ensuite ce que le plugin apporte réellement. Un cas s'arrête à la première pause humaine du skill : c'est elle qu'on grade, pas ce qu'un modèle ferait sans personne.

Les scripts (hooks, checks) sont de **vrais fichiers** versionnes, pas des blocs de code dans un markdown : `/setup` les copie (`cp` + `chmod +x`) au lieu de les faire recopier par le modele. Seuls les templates reellement variables — commandes de lint, format et test — restent dans les markdown, avec les valeurs du projet.

**Doctrine des skills.** Un modèle se perd moins dans un long texte que dans des règles de poids égal, répétées et justifiées : chaque `SKILL.md` ouvre donc sur son invariant, enchaîne des puces impératives sans justification, et tient en 50–80 lignes. Ce qui sert à chaque exécution y reste ; ce qui est conditionnel (spike, inventaire, dépréciation, décomposition, pre-release) vit dans une annexe chargée sur ce chemin seul, à un seul niveau de profondeur. Le protocole d'un sub-agent est un agent du plugin, la mécanique répétée est un script, et le *pourquoi* d'une règle est ici — dans un skill, il n'est gardé que s'il tranche un conflit réel. `.claude/scripts/measure-skills.sh` mesure le graphe de chargement de chaque skill (SKILL.md + annexes transitives) : la refonte de la 1.9.0 l'a ramené de ~111 k à ~43 k tokens pour l'ensemble du plugin.

## Fichiers projet-spécifiques

Le plugin ne contient aucune info spécifique a un projet. La config vit dans le `.claude/skills/` du projet cible, créée par `/setup` :

| Fichier | Rôle |
|---------|------|
| `workflow-config/SKILL.md` | Source unique : plateforme, branches, commandes, stack, conventions |

Et, hors `.claude/`, dans le repo du projet cible :

| Fichier | Rôle |
|---------|------|
| `docs/specs/<feature>.md` | Une spec par feature — versionnee, maintenue par `/pipe-spec` |
| `docs/specs/README.md` | Index des specs : point d'entrée unique pour savoir quelles features existent |

Les projets configures avant la 1.5.0 peuvent garder leur `tech-stack/SKILL.md` (lu en fallback legacy) ; `/setup` propose la migration vers `workflow-config`.

Ces fichiers ne sont jamais ecrases par une mise a jour du plugin.

## Ressources

- [CHANGELOG.md](CHANGELOG.md) — historique des versions et evolutions du plugin
- [Repository GitHub](https://github.com/alex-robert-fr/claude-workflow)
- [Conventions du plugin](CLAUDE.md) — règles internes pour contribuer
