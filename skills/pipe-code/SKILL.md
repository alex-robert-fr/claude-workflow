---
name: pipe-code
description: Implementer la feature en session dediee, guidee par les tests valides et le plan du pilotage. Apres /pipe-test.
argument-hint: [cle du ticket ou rien si un seul cycle en cours]
---

## Étape 0 — Verifications

Utilise Read pour charger `.claude/skills/workflow-config/SKILL.md`, puis localise le fichier de pilotage :

- Argument fourni → `.claude/plans/plan-<identifiant>.md`
- Sans argument → cherche `.claude/plans/plan-*.md` : un seul fichier → le prendre ; plusieurs → demander lequel

Verifie :

- [ ] Le pilotage existe et `Tests valides` est coche (sinon → `/pipe-test` d'abord)
- [ ] La branche courante est celle du pilotage (sinon `git checkout` dessus)
- [ ] Les fichiers de tests listes dans le pilotage existent

Lis le pilotage en entier : plan, notes de reprise — c'est tout le contexte de la session.

Si le pilotage reference une spec (`docs/specs/<feature>.md`), lis-la aussi : intention, philosophie, hors-scope, dependances et pieges.

## Étape 1 — Implementer

Suis le plan, guide par les tests :

- **Les tests valides sont le contrat.** Interdiction de les modifier pour les faire passer. Si un test semble faux, contradictoire ou impossible a satisfaire, stoppe et signale-le — c'est une decision humaine.
- Boucle : coder → lancer les tests (commande de `workflow-config`) → corriger. L'implementation est terminee quand **tous** les tests passent — les nouveaux et les existants.
- **Commits au fil de l'eau, uniquement par changesets propres.** Tu peux committer quand une unite logique est terminee et que les tests qui la couvrent passent — chaque commit suit les conventions de `${CLAUDE_SKILL_DIR}/../git-conventions/SKILL.md` (utilise Read pour le charger). Ce qui ne forme pas encore une unite cohérente reste dans le working tree — `/pipe-commit` decoupera le reste en fin de cycle. Jamais de commit fourre-tout ou "wip". **Avant chaque `git commit`, affiche le message complet (titre + body) et attends la validation explicite de l'utilisateur** — meme en enchainement, ne committe jamais sans confirmation préalable.
- Respecte les conventions de `workflow-config` (stack, architecture, nommage). Pas de verification de style manuelle — c'est le rôle des hooks PostToolUse.

Si une étape revele un problème non anticipe dans le plan (fichier manquant, dependance absente, incohérence), **stoppe et signale-le** avant de continuer :

```
Problème detecte — [description précise]
Option A : [approche]
Option B : [approche]
Comment tu veux proceder ?
```

Corrige le plan en place pour refleter la decision prise (étape ou point d'attention concerne) ; si elle survit au merge, elle rejoint aussi le journal de la spec.

## Étape 2 — Cloture

Une fois tous les tests verts :

- Coche `Dev termine` dans le pilotage
- Note dans Notes de reprise les ecarts au plan et tout contexte utile a la review
- Affiche le recap :

```
**Dev termine — [ticket]** · tests ✅ N passent (dont M nouveaux)

Commits créés (le reste attend `/pipe-commit`) :
- emoji type(scope): description

Fichiers — `+ chemin/nouveau.ts` · `~ chemin/modifie.ts`

---
Suite : la review, dans une **nouvelle session** — `/pipe-ship [ticket]`.
```

`+` pour un fichier crée, `~` pour un fichier modifie : deux sections séparées pour la meme information, c'est une section de trop.

---

## Input utilisateur

$ARGUMENTS
