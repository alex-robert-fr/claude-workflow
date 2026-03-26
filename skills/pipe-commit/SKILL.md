---
name: pipe-commit
description: Committer les changements en cours avec un message formate selon les conventions git du projet. Utiliser pour creer un commit propre a tout moment.
argument-hint: [description optionnelle du changement]
---

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/../git-conventions/SKILL.md` (section Commits) avant de commencer.

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

A partir des changements stages et de l'argument utilisateur (si fourni), determine :

- **Type** : feat, fix, refactor, perf, docs, chore
- **Scope** : module metier concerne (obligatoire pour feat/fix/refactor/perf)
- **Description** : en francais, concise
- **Body** : optionnel, si le changement n'est pas evident

Format : `emoji type(scope): description`

## Etape 3 — Confirmer et committer

Affiche le recap :

```
Commit propose :

emoji type(scope): description

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
