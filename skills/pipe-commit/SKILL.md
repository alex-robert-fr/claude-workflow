---
name: pipe-commit
description: Decouper le travail en commits-changesets qui servent de doc technique, selon les conventions git.
argument-hint: [description optionnelle du changement]
---

**Un commit est un changeset qui se lit seul**, et son corps est la doc technique du projet. Conventions : `${CLAUDE_SKILL_DIR}/../git-conventions/SKILL.md` (Read) — le hook `pre-git-guard.sh` refuse `git add .` et les signatures.

## Étape 0 — État

- `git status` et `git diff --stat` ; rien à committer → une ligne, stop
- Pilotage : `bash "${CLAUDE_SKILL_DIR}/../../shared/scripts/find-plan.sh"` — trouvé avec `Code valide` coché → mode découpage ; sinon → mode simple

## Mode découpage (fin de cycle)

Périmètre : le travail non commité (`/pipe-code` a déjà commité les unités terminées) — affiche d'abord les commits existants pour situer.

1. Lis l'ensemble des changements restants (diff + fichiers non trackés) et regroupe par unité logique : modèle + migration, service métier, composant UI, config… Les tests accompagnent le changeset du comportement qu'ils vérifient ; une spec modifiée accompagne le changeset de sa feature (une spec écrite hors cycle est le seul commit `docs` isolé). Ordre : dépendances d'abord, chaque commit laisse le projet cohérent. Granularité = le fichier ; un fichier qui mélange deux changesets va au principal, et son corps le dit
2. Rédige chaque message complet selon git-conventions (titre, corps en puces : le pourquoi, l'approche, les impacts non évidents)
3. Affiche le plan de découpage entier (un bloc par commit : message, corps, fichiers) et attends la validation explicite ; puis committe changeset par changeset sans redemander, en stageant par chemins explicites. Fichiers sensibles exclus, fichier sans rapport avec le cycle signalé
4. `git status` propre à la fin (le pilotage, gitignoré, n'y apparaît pas) ; coche `Commits créés`

```
N commits créés. Suite : `/pipe-pr [ticket]`.
```

## Mode simple (commit ponctuel)

1. Stage les fichiers pertinents par chemin explicite ; confirmation seulement si un fichier sensible ou sans rapport évident est présent
2. Type, scope, description et corps depuis les changements stagés et l'argument ; affiche le message complet, attends la validation, committe

```
**Commit créé** — emoji type(scope): description
- [puce du corps si présent]

Fichiers — `chemin/fichier.ts`
```

3. Branche avec upstream → propose le push, sur confirmation explicite seulement

---

## Input utilisateur

$ARGUMENTS
