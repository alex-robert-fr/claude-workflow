---
name: pipe-commit
description: Committer les changements en cours avec un message formate selon les conventions git du projet. Utiliser pour creer un commit propre a tout moment.
model: sonnet
argument-hint: [description optionnelle du changement]
---

## Contexte

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/../_workflow-persona/SKILL.md` avant de commencer.

---

## Etape 0 — Analyser l'etat

Verifie l'etat du repo :

- `git status` — fichiers modifies, stages, non-trackes
- `git diff --stat` — resume des changements

Si rien a committer → signale-le et arrete-toi.

## Etape 1 — Stager les changements

Si des fichiers ne sont pas stages :

- Propose les fichiers a stager (pas de `git add .` aveugle)
- Exclure les fichiers sensibles (.env, credentials, etc.)
- Demande confirmation si necessaire

## Etape 2 — Formater le message

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/../git-conventions/SKILL.md` (section Commits).

A partir des changements stages et de l'argument utilisateur (si fourni), determine :

- **Type** : feat, fix, refactor, perf, docs, chore
- **Scope** : module metier concerne (obligatoire pour feat/fix/refactor/perf)
- **Description** : en francais, concise
- **Body** : obligatoire si le changement n'est pas trivial — c'est le corps du commit qui documente le detail technique (le CHANGELOG reste court et pointe vers le commit). Liste a puces : le pourquoi, l'approche choisie, les impacts non evidents depuis le diff.

Format : `emoji type(scope): description`

## Etape 3 — Confirmer et committer

Affiche le recap :

```
Commit propose :

emoji type(scope): description

- [puce du body si present]
- [puce du body si present]

Fichiers :
- chemin/fichier.ts
- chemin/autre.ts
```

Demande confirmation puis commit.

## Etape 4 — Push (optionnel)

Si la branche a un upstream, propose de push :

```
Push vers origin/branche-courante ?
```

Ne push que sur confirmation explicite.

---

## Input utilisateur

$ARGUMENTS
