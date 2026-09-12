---
name: pipe-ship
description: Reprendre le cycle d'un ticket : lit le pilotage, detecte la phase, deroule jusqu'a la prochaine pause humaine.
argument-hint: [cle du ticket ou rien pour détecter le cycle en cours]
---

Les skills unitaires restent invocables directement.

## Étape 0 — Localiser le pilotage

- Argument fourni → `.claude/plans/plan-<identifiant>.md`
- Sans argument → cherche `.claude/plans/plan-*.md` : un seul fichier → le prendre ; plusieurs → demander lequel
- Aucun pilotage → le cycle n'a pas encore commence : c'est le cadrage qui l'ouvrira. Va directement a la phase `Spec a jour` de l'étape 2, avec l'argument reçu comme ticket. Sans argument, demande d'abord le ticket ou le nom de la feature : ne charge jamais `/pipe-spec` sans argument depuis ici, ce declencheur ouvre le mode inventaire, qui n'est pas un cycle

## Étape 1 — Identifier la phase courante

- Lis le pilotage en entier
- Phase courante = première case non cochée de la section Etat (cadrage si aucun pilotage)
- Annonce en une ligne : ticket, branche, phase courante, ce qui va se passer

## Étape 2 — Derouler

| Première case non cochee | Phase a executer | Skill a charger (Read) | Session |
|---|---|---|---|
| `Spec a jour` | cadrage de la feature dans `docs/specs/` | `${CLAUDE_SKILL_DIR}/../pipe-spec/SKILL.md` | courante |
| `Plan valide` | co-construction du plan | `${CLAUDE_SKILL_DIR}/../pipe-plan/SKILL.md` | courante |
| `Tests ecrits` ou `Tests valides` | ecriture + review humaine des tests | `${CLAUDE_SKILL_DIR}/../pipe-test/SKILL.md` | courante |
| `Dev termine` | implementation guidee par les tests | `${CLAUDE_SKILL_DIR}/../pipe-code/SKILL.md` | **neuve obligatoire** |
| `Code valide` | checks outilles + review agent + review humaine | `${CLAUDE_SKILL_DIR}/../pipe-review/SKILL.md` | **neuve obligatoire** |
| `Commits créés` | decoupage en changesets | `${CLAUDE_SKILL_DIR}/../pipe-commit/SKILL.md` | courante |
| `PR créée` | creation de la Pull Request | `${CLAUDE_SKILL_DIR}/../pipe-pr/SKILL.md` | courante |

Toutes cochees → le cycle est termine (le pilotage aurait du être supprime par `/pipe-pr`) : signale-le et propose de le supprimer.

### Frontieres de session

Le dev et la review se font chacun dans une session neuve, avec un contexte propre — le pilotage suffit a la reprise.

- Si la phase a executer exige une session neuve **et** qu'une autre phase vient d'être exécutée dans cette conversation, ne pas enchainer. Afficher :

```
Suite : [dev | review], dans une **nouvelle session** — `/pipe-ship [ticket]`.
```

- Si `/pipe-ship` est lance en debut de session (rien d'autre execute avant), executer la phase courante directement, quelle qu'elle soit.

### Enchainement

Tant qu'on ne franchit pas une frontiere de session, enchaine les phases : charge le skill unitaire, applique toutes ses étapes, puis reviens a la table ci-dessus. Les pauses humaines (review des tests, review du code) sont gerees par les skills unitaires eux-memes — la validation de l'utilisateur dans la session permet de continuer.

Adaptation en enchainement : ignorer les blocs "Proposer la suite" des skills unitaires — c'est ce skill qui pilote la suite.

## Étape 3 — Fin de tour

Quel que soit le point d'arret (pause humaine, frontiere de session, fin de cycle), termine par une ligne : ou on en est, et le prochain geste.

---

## Input utilisateur

$ARGUMENTS
