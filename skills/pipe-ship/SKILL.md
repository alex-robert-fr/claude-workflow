---
name: pipe-ship
description: Reprendre le cycle d'un ticket : lit le pilotage, détecte la phase, déroule jusqu'à la prochaine pause humaine.
disable-model-invocation: true
argument-hint: [clé du ticket ou rien pour détecter le cycle en cours]
allowed-tools:
  - Bash(bash "${CLAUDE_SKILL_DIR}/../../shared/scripts/find-plan.sh" *)
  - Bash(bash .claude/scripts/check-specs.sh)
  - Bash(git status *)
  - Bash(git log *)
  - Bash(git diff *)
  - Bash(git remote get-url origin)
  - Bash(git branch --show-current)
  - Bash(gh pr list *)
  - Bash(gh pr view *)
---

**Le pilotage dit où en est le cycle ; ce skill charge le skill de la phase courante et enchaîne jusqu'à la prochaine pause humaine ou frontière de session.** Les skills unitaires restent invocables directement.

## Étape 0 — Pilotage

`bash "${CLAUDE_SKILL_DIR}/../../shared/scripts/find-plan.sh" [identifiant]` — exit 3 : demander lequel ; exit 1 (aucun pilotage) : le cycle n'a pas commencé, c'est le cadrage qui l'ouvre → phase `Spec a jour` avec l'argument reçu comme ticket. Sans argument, demande d'abord le ticket ou le nom de la feature : `/pipe-spec` sans argument ouvre le mode inventaire, qui n'est pas un cycle.

## Étape 1 — Phase

Lis le pilotage en entier. Phase = première case non cochée de l'État (cadrage si aucun pilotage). Annonce en une ligne : ticket, branche, phase, ce qui va se passer.

| Première case non cochée | Skill (Read) | Session |
|---|---|---|
| `Spec a jour` | `${CLAUDE_SKILL_DIR}/../pipe-spec/SKILL.md` | courante |
| `Plan valide` | `${CLAUDE_SKILL_DIR}/../pipe-plan/SKILL.md` | courante |
| `Tests ecrits` ou `Tests valides` | `${CLAUDE_SKILL_DIR}/../pipe-test/SKILL.md` | courante |
| `Dev termine` | `${CLAUDE_SKILL_DIR}/../pipe-code/SKILL.md` | neuve obligatoire |
| `Code valide` | `${CLAUDE_SKILL_DIR}/../pipe-review/SKILL.md` | neuve obligatoire |
| `Commits créés` | `${CLAUDE_SKILL_DIR}/../pipe-commit/SKILL.md` | courante |
| `PR créée` | `${CLAUDE_SKILL_DIR}/../pipe-pr/SKILL.md` | courante |

Toutes cochées → le cycle est terminé (`/pipe-pr` aurait dû supprimer le pilotage) : dis-le, propose la suppression.

## Étape 2 — Dérouler

- Charge le skill de la phase, applique toutes ses étapes, reviens à la table. Les pauses humaines (review des tests, du code) sont gérées par les skills eux-mêmes : la validation de l'utilisateur permet de continuer. Ignore leurs blocs « Suite » : c'est ce skill qui pilote
- Frontière de session : si la phase exige une session neuve et qu'une autre phase vient d'être exécutée dans cette conversation, n'enchaîne pas — affiche `Suite : [dev | review], dans une nouvelle session — /pipe-ship [ticket]`. Lancé en début de session (rien exécuté avant), exécute la phase courante directement, quelle qu'elle soit

## Étape 3 — Fin de tour

Quel que soit le point d'arrêt (pause humaine, frontière de session, fin de cycle) : une ligne — où on en est, le prochain geste.

---

## Input utilisateur

$ARGUMENTS
