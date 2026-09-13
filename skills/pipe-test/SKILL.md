---
name: pipe-test
description: Ecrire les tests d'une feature avant son implementation, depuis le plan du pilotage. Ils deviennent le contrat du dev.
disable-model-invocation: true
argument-hint: [cle du ticket ou rien si un seul cycle en cours]
allowed-tools:
  - Bash(bash "${CLAUDE_SKILL_DIR}/../../shared/scripts/find-plan.sh" *)
  - Bash(git status *)
  - Bash(git branch --show-current)
---

**Les tests validés ici sont le contrat du dev** : ils décrivent le comportement attendu avant qu'il n'existe, et ne changent plus ensuite sans décision humaine.

## Étape 0 — Vérifications

- Read `.claude/skills/workflow-config/SKILL.md`
- Pilotage : `bash "${CLAUDE_SKILL_DIR}/../../shared/scripts/find-plan.sh" [identifiant]` — exit 3 : demander lequel ; exit 1 : afficher son message et s'arrêter
- Prérequis : `Plan valide` coché, commande de test configurée. Sinon : une ligne, le skill à lancer avant, stop

## Étape 1 — Branche

- Branche déjà notée dans le pilotage → `git switch` dessus
- Sinon `bash "${CLAUDE_SKILL_DIR}/../../shared/scripts/new-branch.sh" <type/identifiant-titre-court>` (format : `${CLAUDE_SKILL_DIR}/../git-conventions/SKILL.md`, section Branches), puis note la branche dans la section Branche du pilotage

## Étape 2 — Écrire les tests

Sources : la section Tests du plan ; si le pilotage référence une spec, son « Comportement attendu » = tests à écrire, son « Hors scope » = à ne pas tester.

- Un test par comportement qui compte : nominal, cas limites du plan, erreurs. Critère : si tout passe, la feature est bonne
- Framework et conventions de workflow-config
- Aucune implémentation : squelette vide (signatures, types) uniquement si la suite en a besoin pour tourner
- Ticket technique (refactor, migration) : le contrat = les tests existants. Couverture insuffisante → tests de caractérisation, verts avant le dev ; suffisante → n'écris rien et dis-le

## Étape 3 — Tests rouges

Lance la commande de test. Les nouveaux tests échouent pour la bonne raison (assertion, module absent — pas une erreur dans le test) ; les tests existants passent toujours. Exception : caractérisation → verts.

## Étape 4 — Critique par l'agent `test-critic`

Lance l'agent (Agent tool, `subagent_type: "claude-workflow:test-critic"`) avec les chemins des fichiers de tests et celui du pilotage. Applique sa sortie : retire, complète, rejoue l'étape 3 sur les ajouts.

## Étape 5 — Review humaine (pause)

```
## Tests proposés — [ticket]

`chemin/fichier.spec.ts`
- quand [situation], alors [comportement]
```

Itère jusqu'à validation explicite. Puis : coche `Tests ecrits` et `Tests valides`, remplis `## Tests` du pilotage (un fichier par ligne en backticks, comportements en puces dessous), corrige le plan en place si un choix le contredit.

## Étape 6 — Suite

```
Tests validés. Suite : le dev, dans une **nouvelle session** — `/pipe-ship [ticket]`.
```

---

## Input utilisateur

$ARGUMENTS
