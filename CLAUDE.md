# claude-workflow

Plugin Claude Code pour le workflow AI-Driven Development. Fournit un pipeline complet : plan co-construit, tests d'abord, dev guide par les tests, review, commits-changesets, PR, release.

## Plugin

Ce repo est un **plugin Claude Code** (`name: workflow`). Les skills sont namespaces : `/workflow:pipe-code`, `/workflow:pipe-review`, etc.

Installation : `claude --plugin-dir /chemin/vers/claude-workflow`

Manifest : `.claude-plugin/plugin.json` (name, version, description, author).

Structure : `.claude-plugin/plugin.json` (manifest), `skills/nom/SKILL.md` (skills distribues).

## Pipeline

Cycle d'une demande metier (ticket JIRA ou issue), pilote par un **fichier de pilotage** dans `.claude/plans/` du projet cible (gitignore, ouvert par `/pipe-spec` des le cadrage, supprime a la PR). L'humain intervient a trois pauses : la validation de la spec, la review des tests et la review du code. Le dev et la review se font chacun dans une session neuve — le pilotage porte le contexte de reprise.

```
/pipe-spec (cadrage de la feature + validation humaine)
→ /pipe-plan (Q/R + plan) → /pipe-test (tests d'abord + review humaine)
→ session neuve : /pipe-code (guide par les tests, changesets au fil de l'eau)
→ session neuve : /pipe-review (format/lint/tests outilles + agent haute valeur + review humaine + fraicheur de la spec)
→ /pipe-commit (decoupage en changesets) → /pipe-pr (vers la branche d'integration)
```

## Specs

Deux documents, deux durees de vie — ne jamais les confondre :

- **Spec** (`docs/specs/<feature>.md`, versionnee) : ce que la feature **est**. Intention, philosophie, comportement attendu, hors-scope, dependances, decisions, points d'entree techniques. Une spec par feature, alimentee par N tickets, ecrite au present. Elle survit au cycle et sert de contexte de reference aux sessions suivantes — on la lit au lieu de parcourir le code.
- **Pilotage** (`.claude/plans/plan-<ticket>.md`, gitignore) : ce qu'on **fait** sur ce ticket. Ephemere, supprime a la PR.

Sur un projet existant, `/pipe-spec` sans argument inventorie les features deja livrees et les classe par valeur (frequence de modification), pour rattraper l'existant une feature a la fois — jamais en masse : chaque spec exige son cadrage humain.

Un hook `SessionStart` (deploye par `/setup`) injecte l'index `docs/specs/README.md` dans le contexte de chaque session : conformement a la regle du projet, la lecture des specs est garantie par un hook, pas par une instruction au LLM.

Regle : si une phrase devient fausse une fois le ticket merge, elle n'a rien a faire dans une spec. Aucune etape d'implementation, aucun bloc de code, aucun TODO. Le detail est dans `skills/pipe-spec/reference.md`.

`/pipe-ship <ticket>` est la commande de reprise : elle lit le pilotage, detecte la phase courante et deroule jusqu'a la prochaine pause humaine ou frontiere de session. Les skills unitaires restent invocables independamment.

Release, quand assez de features sont mergees sur la branche d'integration : `/pipe-release` (CHANGELOG oriente metier + PR integration → production) → [merge + deploiement] → `/pipe-tag`.

Voie rapide : les changements sans comportement a tester (typo, libelle, bump mineur) passent par `/pipe-commit` sans ticket, ni pilotage, ni spec. Les tickets techniques (refactor, migration) suivent le cycle complet avec les tests existants comme contrat (+ caracterisation si zone mal couverte) ; ils ne creent pas de spec mais peuvent en mettre une a jour.

## Regles

- Les fichiers dans `skills/` sont **partages** — distribues via le plugin
- `.claude/skills/` contient l'outillage local du repo (create-skill) — jamais distribue
- Les templates projet-specifiques sont dans `skills/setup/`, deployes par `/setup`. `workflow-config` est la source unique de config projet (plateforme, commandes, stack)
- Ne jamais mettre de logique specifique a un projet dans les skills partages
- Chaque skill est un repertoire `nom/SKILL.md` avec frontmatter obligatoire
- La qualite est garantie par les **hooks** et les **sub-agents**, jamais par des instructions au LLM
- References entre skills du plugin : `${CLAUDE_SKILL_DIR}/../autre-skill/`
- References aux fichiers projet-specifiques : `.claude/skills/`

## Versioning

Lors d'une release (`/pipe-release` puis `/pipe-tag`), toujours mettre a jour la version simultanement dans :
- `.claude-plugin/plugin.json` (champ `version`)
- `.claude-plugin/marketplace.json` (champs `metadata.version` ET `plugins[0].version`)
- `CHANGELOG.md`

Les trois doivent rester strictement synchronises sous peine de desynchroniser la version annoncee dans la marketplace publique.

## Git

Les conventions git (commits, branches, PRs) sont definies dans `skills/git-conventions/SKILL.md`. Les respecter systematiquement.

## Conventions

- Nommage : `kebab-case`, chaque skill est un repertoire `nom/SKILL.md`
- Skills invocables : `user-invocable: true` (defaut)
- Skills expertise : `user-invocable: false`
- `$ARGUMENTS` toujours en fin de skill invocable
- Prefixes : `pipe-*` (pipeline), `create-*` (artefacts), `setup-*` (config), `*-conventions` (expertise)
- Pas de champ `model` dans le frontmatter des skills : il bascule reellement le modele pour le reste du tour (auto-invocation comprise) et peut retrograder la session. Voir `.claude/skills/create-skill/reference.md` section `model`.
