---
name: pipe-commit
description: Decouper le travail en commits-changesets qui servent de doc technique, selon les conventions git.
argument-hint: [description optionnelle du changement]
---

## Étape 0 — Analyser l'etat

Verifie l'etat du repo :

- `git status` — fichiers modifies, stages, non-trackes
- `git diff --stat` — resume des changements

Si rien a committer → signale-le et arrete-toi.

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/../git-conventions/SKILL.md` (section Commits).

Cherche un fichier de pilotage `.claude/plans/plan-*.md` correspondant a la branche courante :

- Present avec `Code valide` coche → **mode decoupage** (fin de cycle)
- Absent → **mode simple** (commit ponctuel)

## Mode decoupage (fin de cycle)

- **Changeset** — un commit = une unite logique qui se lit seule
- **Perimetre** — travail restant non commite (`/pipe-code` a déjà commit les unites terminees au fil du dev) ; affiche d'abord les commits existants pour situer le decoupage

### Étape 1 — Construire le plan de decoupage

- Lis l'ensemble des changements restants (diff du working tree + fichiers non trackes)
- Regroupe par unite logique : modele + migration, service métier, composant UI, config... Les tests accompagnent le changeset du comportement qu'ils verifient — pas de commit fourre-tout `tests`
- Une spec modifiee (`docs/specs/`) accompagne le changeset de la feature qu'elle decrit, pas un commit `docs` isole. Seule exception : une spec ecrite hors cycle, qui devient alors son propre commit `docs`
- Ordre logique : dependances d'abord ; chaque commit laisse idealement le projet cohérent
- Granularite = le fichier (staging par chemin). Si un meme fichier melange deux changesets, rattache-le au changeset principal et documente-le dans le body
- Pour chaque changeset, rédige le message complet selon `git-conventions` : titre `emoji type(scope): description`, body en puces (le pourquoi, l'approche choisie, les impacts non evidents depuis le diff)

### Étape 2 — Presenter puis committer

Affiche le plan de decoupage complet (un bloc par commit : message, body, fichiers) et attends la validation explicite de l'utilisateur avant de committer. Une fois valide, committe changeset par changeset sans redemander a chaque commit individuel.

- Stage par chemins explicites, jamais `git add .`
- Exclus les fichiers sensibles (.env, credentials) et signale tout fichier sans rapport avec le cycle
- A la fin, verifie que `git status` est propre (le pilotage, gitignore, n'y apparait pas)

Coche `Commits créés` dans le pilotage.

### Étape 3 — Proposer la suite

```
---
N commits créés. Suite : `/pipe-pr [ticket]`.
```

## Mode simple (commit ponctuel)

### Étape 1 — Stager les changements

- Stage les fichiers pertinents par chemin explicite (pas de `git add .` aveugle)
- Exclure les fichiers sensibles (.env, credentials, etc.)
- Ne demande confirmation que si un fichier sensible ou sans rapport évident avec le changement est present

### Étape 2 — Committer

A partir des changements stages et de l'argument utilisateur (si fourni), determine type, scope, description et body selon `git-conventions`.

Affiche le message complet (titre + body) et attends la validation explicite de l'utilisateur avant de committer.

Affiche le recap apres coup :

```
**Commit créé** — emoji type(scope): description
- [puce du body si present]

Fichiers — `chemin/fichier.ts`
```

### Étape 3 — Push (optionnel)

Si la branche a un upstream, propose de push. Ne push que sur confirmation explicite.

---

## Input utilisateur

$ARGUMENTS
