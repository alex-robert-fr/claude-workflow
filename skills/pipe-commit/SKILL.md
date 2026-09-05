---
name: pipe-commit
description: Decouper le travail en commits-changesets qui servent de doc technique, selon les conventions git.
argument-hint: [description optionnelle du changement]
---

## Etape 0 — Analyser l'etat

Verifie l'etat du repo :

- `git status` — fichiers modifies, stages, non-trackes
- `git diff --stat` — resume des changements

Si rien a committer → signale-le et arrete-toi.

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/../git-conventions/SKILL.md` (section Commits).

Cherche un fichier de pilotage `.claude/plans/plan-*.md` correspondant a la branche courante :

- Present avec `Code valide` coche → **mode decoupage** (fin de cycle)
- Absent → **mode simple** (commit ponctuel)

## Mode decoupage (fin de cycle)

Chaque commit est un **changeset** : une unite logique qui se lit seule. La liste des commits de la branche est la doc technique de la feature — le nom de chaque commit doit etre limpide, et son body porte le detail.

Des commits ont pu etre crees au fil du dev (`/pipe-code` committe les unites terminees) : ce mode s'applique au **travail restant non commite**. Affiche d'abord les commits deja presents sur la branche pour situer le decoupage.

### Etape 1 — Construire le plan de decoupage

- Lis l'ensemble des changements restants (diff du working tree + fichiers non trackes)
- Regroupe par unite logique : modele + migration, service metier, composant UI, config... Les tests accompagnent le changeset du comportement qu'ils verifient — pas de commit fourre-tout `tests`
- Une spec modifiee (`docs/specs/`) accompagne le changeset de la feature qu'elle decrit, pas un commit `docs` isole. Seule exception : une spec ecrite hors cycle, qui devient alors son propre commit `docs`
- Ordre logique : dependances d'abord ; chaque commit laisse idealement le projet coherent
- Granularite = le fichier (staging par chemin). Si un meme fichier melange deux changesets, rattache-le au changeset principal et documente-le dans le body
- Pour chaque changeset, redige le message complet selon `git-conventions` : titre `emoji type(scope): description`, body en puces (le pourquoi, l'approche choisie, les impacts non evidents depuis le diff)

### Etape 2 — Presenter puis committer

Affiche le plan de decoupage complet (un bloc par commit : message, body, fichiers) et attends la validation explicite de l'utilisateur avant de committer. Une fois valide, committe changeset par changeset sans redemander a chaque commit individuel.

- Stage par chemins explicites, jamais `git add .`
- Exclus les fichiers sensibles (.env, credentials) et signale tout fichier sans rapport avec le cycle
- A la fin, verifie que `git status` est propre (le pilotage, gitignore, n'y apparait pas)

Coche `Commits crees` dans le pilotage.

### Etape 3 — Proposer la suite

```
---
N commits crees. Suite : `/pipe-pr [ticket]`.
```

## Mode simple (commit ponctuel)

### Etape 1 — Stager les changements

- Stage les fichiers pertinents par chemin explicite (pas de `git add .` aveugle)
- Exclure les fichiers sensibles (.env, credentials, etc.)
- Ne demande confirmation que si un fichier sensible ou sans rapport evident avec le changement est present

### Etape 2 — Committer

A partir des changements stages et de l'argument utilisateur (si fourni), determine type, scope, description et body selon `git-conventions` (le body est obligatoire des que le changement n'est pas trivial — c'est lui qui documente le detail technique).

Affiche le message complet (titre + body) et attends la validation explicite de l'utilisateur avant de committer.

Affiche le recap apres coup :

```
**Commit cree** — emoji type(scope): description
- [puce du body si present]

Fichiers — `chemin/fichier.ts`
```

### Etape 3 — Push (optionnel)

Si la branche a un upstream, propose de push. Ne push que sur confirmation explicite.

---

## Input utilisateur

$ARGUMENTS
