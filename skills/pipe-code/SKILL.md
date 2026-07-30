---
name: pipe-code
description: Implementer la feature en session dediee, guidee par les tests valides et le plan du pilotage. Apres /pipe-test.
argument-hint: [cle du ticket ou rien si un seul cycle en cours]
---

## Etape 0 — Verifications

Utilise Read pour charger `.claude/skills/workflow-config/SKILL.md`, puis localise le fichier de pilotage :

- Argument fourni → `.claude/plans/plan-<identifiant>.md`
- Sans argument → cherche `.claude/plans/plan-*.md` : un seul fichier → le prendre ; plusieurs → demander lequel

Verifie :

- [ ] Le pilotage existe et `Tests valides` est coche (sinon → `/pipe-test` d'abord)
- [ ] La branche courante est celle du pilotage (sinon `git checkout` dessus)
- [ ] Les fichiers de tests listes dans le pilotage existent

Lis le pilotage en entier : plan, decisions, notes de reprise — c'est tout le contexte de la session.

Si le pilotage reference une spec (`docs/specs/<feature>.md`), lis-la aussi : intention, philosophie, hors-scope, dependances et pieges. C'est le contexte global de la feature, celui qui evite de reparcourir le code et de reprendre une direction ecartee volontairement.

## Etape 1 — Implementer

Suis le plan, guide par les tests :

- **Les tests valides sont le contrat.** Interdiction de les modifier pour les faire passer. Si un test semble faux, contradictoire ou impossible a satisfaire, stoppe et signale-le — c'est une decision humaine.
- Boucle : coder → lancer les tests (commande de `workflow-config`) → corriger. L'implementation est terminee quand **tous** les tests passent — les nouveaux et les existants.
- **Commits au fil de l'eau, uniquement par changesets propres.** Tu peux committer quand une unite logique est terminee et que les tests qui la couvrent passent — chaque commit suit `git-conventions` (utilise Read pour le charger) : titre limpide, body detaille, c'est de la doc technique. Ce qui ne forme pas encore une unite coherente reste dans le working tree — `/pipe-commit` decoupera le reste en fin de cycle. Jamais de commit fourre-tout ou "wip".
- Respecte les conventions de `workflow-config` (stack, architecture, nommage). Pas de verification de style manuelle — c'est le role des hooks PostToolUse.

Si une etape revele un probleme non anticipe dans le plan (fichier manquant, dependance absente, incoherence), **stoppe et signale-le** avant de continuer :

```
Probleme detecte — [description precise]
Option A : [approche]
Option B : [approche]
Comment tu veux proceder ?
```

Consigne la decision prise dans la section Decisions du pilotage.

## Etape 2 — Cloture

Une fois tous les tests verts :

- Coche `Dev termine` dans le pilotage
- Note dans Notes de reprise les ecarts au plan et tout contexte utile a la review
- Affiche le recap :

```
## Implementation terminee — [ticket]

Tests : ✅ N passent (dont M nouveaux)

### Commits crees (le reste attend /pipe-commit)
- emoji type(scope): description

### Fichiers crees
- chemin/fichier.ts

### Fichiers modifies
- chemin/fichier.ts
```

```
---
Phase suivante : la review, dans une NOUVELLE session :
ouvre une session et lance `/pipe-ship [ticket]` (ou `/pipe-review [ticket]`).
```

---

## Input utilisateur

$ARGUMENTS
