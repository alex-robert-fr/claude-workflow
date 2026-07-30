---
name: pipe-ship
description: Reprendre le cycle en cours d'un ticket : lit le fichier de pilotage, detecte la phase courante et deroule jusqu'a la prochaine pause humaine ou frontiere de session. Le seul geste a retenir dans chaque nouvelle session. Utiliser a tout moment du cycle.
argument-hint: [cle du ticket ou rien pour detecter le cycle en cours]
---

Ce skill n'a pas de logique propre : il localise le pilotage, identifie la phase courante et applique le skill unitaire correspondant. Les skills unitaires restent invocables directement.

## Etape 0 — Localiser le pilotage

- Argument fourni → `.claude/plans/plan-<identifiant>.md`
- Sans argument → cherche `.claude/plans/plan-*.md` : un seul fichier → le prendre ; plusieurs → demander lequel
- Aucun pilotage → pas de cycle en cours : propose de demarrer par le cadrage, `/pipe-spec [ticket]` (c'est lui qui ouvre le pilotage), et arrete-toi

## Etape 1 — Identifier la phase courante

Lis le pilotage en entier. Dans la section Etat, la **premiere case non cochee** donne la phase courante. Annonce en une ligne : ticket, branche, phase courante, ce qui va se passer.

## Etape 2 — Derouler

| Premiere case non cochee | Phase a executer | Skill a charger (Read) | Session |
|---|---|---|---|
| `Spec a jour` | cadrage de la feature dans `docs/specs/` | `${CLAUDE_SKILL_DIR}/../pipe-spec/SKILL.md` | courante |
| `Plan valide` | co-construction du plan | `${CLAUDE_SKILL_DIR}/../pipe-plan/SKILL.md` | courante |
| `Tests ecrits` ou `Tests valides` | ecriture + review humaine des tests | `${CLAUDE_SKILL_DIR}/../pipe-test/SKILL.md` | courante |
| `Dev termine` | implementation guidee par les tests | `${CLAUDE_SKILL_DIR}/../pipe-code/SKILL.md` | **neuve obligatoire** |
| `Code valide` | checks outilles + review agent + review humaine | `${CLAUDE_SKILL_DIR}/../pipe-review/SKILL.md` | **neuve obligatoire** |
| `Commits crees` | decoupage en changesets | `${CLAUDE_SKILL_DIR}/../pipe-commit/SKILL.md` | courante |
| `PR creee` | creation de la Pull Request | `${CLAUDE_SKILL_DIR}/../pipe-pr/SKILL.md` | courante |

Toutes cochees → le cycle est termine (le pilotage aurait du etre supprime par `/pipe-pr`) : signale-le et propose de le supprimer.

### Frontieres de session

Le dev et la review se font chacun dans une session neuve, avec un contexte propre — le pilotage suffit a la reprise.

- Si la phase a executer exige une session neuve **et** qu'une autre phase vient d'etre executee dans cette conversation, ne pas enchainer. Afficher :

```
Phase suivante : [dev | review] — a lancer dans une NOUVELLE session :
ouvre une session et lance `/pipe-ship [ticket]`.
```

- Si `/pipe-ship` est lance en debut de session (rien d'autre execute avant), executer la phase courante directement, quelle qu'elle soit.

### Enchainement

Tant qu'on ne franchit pas une frontiere de session, enchaine les phases : charge le skill unitaire, applique toutes ses etapes, puis reviens a la table ci-dessus. Les pauses humaines (review des tests, review du code) sont gerees par les skills unitaires eux-memes — la validation de l'utilisateur dans la session permet de continuer.

Adaptation en enchainement : ignorer les blocs "Proposer la suite" des skills unitaires — c'est ce skill qui pilote la suite.

## Etape 3 — Fin de tour

Quel que soit le point d'arret (pause humaine, frontiere de session, fin de cycle), termine par une ligne : ou on en est, et le prochain geste.

---

## Input utilisateur

$ARGUMENTS
