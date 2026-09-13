---
name: pipe-code
description: Implementer la feature en session dediee, guidee par les tests valides et le plan du pilotage. Apres /pipe-test.
disable-model-invocation: true
argument-hint: [cle du ticket ou rien si un seul cycle en cours]
---

**Les tests validés sont le contrat : l'implémentation les satisfait, elle ne les modifie pas.** Un test qui semble faux, contradictoire ou impossible à satisfaire arrête le travail et remonte à l'humain.

## Étape 0 — Vérifications

- Read `.claude/skills/workflow-config/SKILL.md`
- Pilotage : `bash "${CLAUDE_SKILL_DIR}/../../shared/scripts/find-plan.sh" [identifiant]` — exit 3 : demander lequel
- Prérequis : `Tests valides` coché (sinon `/pipe-test` d'abord), `git switch` sur la branche du pilotage, fichiers de tests listés présents
- Lis le pilotage en entier (plan, notes de reprise) et la spec qu'il référence (intention, philosophie, hors-scope, dépendances, pièges) : c'est tout le contexte de la session

## Étape 1 — Implémenter

- Suis le plan ; boucle coder → tests (commande de workflow-config) → corriger, jusqu'à ce que tous passent, nouveaux et existants
- Conventions de workflow-config (stack, architecture, nommage) ; le style est l'affaire des hooks, pas d'une vérification manuelle
- Commits au fil de l'eau, uniquement par changeset propre : une unité logique terminée dont les tests passent, message selon `${CLAUDE_SKILL_DIR}/../git-conventions/SKILL.md` (Read), affiché et confirmé avant chaque `git commit`. Ce qui ne forme pas encore une unité cohérente reste dans le working tree pour `/pipe-commit`
- Problème non anticipé par le plan (fichier manquant, dépendance absente, incohérence) → stop :

  ```
  Problème détecté — [en une phrase non technique : ce que ça change pour la feature]
  Détail : [description précise, une ligne]
  Option A : [approche, et ce qu'elle produit]
  Option B : [approche, et ce qu'elle produit]
  Comment tu veux procéder ?
  ```

  La décision corrige le plan en place ; si elle survit au merge, elle rejoint aussi le journal de la spec

## Étape 2 — Clôture

Tous les tests verts → coche `Dev termine`, note dans Notes de reprise les écarts au plan et le contexte utile à la review, affiche :

```
**Dev terminé — [ticket]** · tests ✅ N passent (dont M nouveaux)

Commits créés (le reste attend `/pipe-commit`) :
- emoji type(scope): description

Fichiers — `+ chemin/nouveau.ts` · `~ chemin/modifié.ts`

---
Suite : la review, dans une **nouvelle session** — `/pipe-ship [ticket]`.
```

---

## Input utilisateur

$ARGUMENTS
