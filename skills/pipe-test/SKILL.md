---
name: pipe-test
description: Ecrire les tests unitaires d'une fonctionnalite avant son implementation, depuis le plan du fichier de pilotage. Assez de tests pour couvrir le comportement, pas plus. S'arrete pour la review humaine des tests — ils deviennent le contrat du dev. Utiliser apres /pipe-plan.
argument-hint: [cle du ticket ou rien si un seul cycle en cours]
---

## Etape 0 — Verifications

Utilise Read pour charger `.claude/skills/workflow-config/SKILL.md`, puis localise le fichier de pilotage :

- Argument fourni → `.claude/plans/plan-<identifiant>.md`
- Sans argument → cherche `.claude/plans/plan-*.md` : un seul fichier → le prendre ; plusieurs → demander lequel

Verifie :

- [ ] Le pilotage existe (sinon → lancer `/pipe-plan` d'abord)
- [ ] `Plan valide` est coche dans son etat
- [ ] Une commande de test est configuree dans `workflow-config`

Si une verification echoue, signale-le clairement et arrete-toi.

## Etape 1 — Creer la branche

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/../git-conventions/SKILL.md` (conventions de branches).

Si le pilotage indique deja une branche (reprise), fais simplement un checkout dessus. Sinon, identifie la branche par defaut depuis `workflow-config` (`BASE_BRANCH`) et execute exactement :

1. `git checkout <BASE_BRANCH>`
2. `git pull origin <BASE_BRANCH>`
3. `git checkout -b <nouvelle-branche>`

Ne jamais hardcoder `main` ou `develop` — toujours lire la valeur depuis `workflow-config`.

Note la branche dans la section Branche du pilotage et annonce-la.

## Etape 2 — Ecrire les tests

Ecris les tests unitaires depuis le plan (comportement attendu, cas limites, section Tests) :

- **La regle de couverture** : si tous ces tests passent, la fonctionnalite est bonne. Chaque test verifie un comportement qui compte — cas nominal, cas limites identifies au plan, cas d'erreur. Pas de tests pour gonfler le compteur.
- Framework et conventions de test du projet (`workflow-config`)
- **N'implemente pas la fonctionnalite** : uniquement les tests, plus le squelette minimal si la suite en a besoin pour s'executer (signatures vides, types — aucune logique)

### Cas particulier — ticket technique (refactor, migration)

Un refactor ne cree pas de comportement nouveau : le contrat, ce sont les **tests existants** qui doivent rester verts a travers le changement.

- Evalue la couverture de la zone touchee. Si elle est insuffisante, ecris des **tests de caracterisation** qui capturent le comportement actuel — eux doivent etre **verts** avant le dev, contrairement aux tests d'une nouvelle fonctionnalite
- Si la couverture existante suffit, ne rajoute rien et dis-le : la review humaine (etape 4) porte alors sur la question "cette couverture suffit-elle pour refactorer sans risque ?"

## Etape 3 — Verifier que les tests sont rouges

Lance la commande de test. Les nouveaux tests **doivent echouer** — la fonctionnalite n'existe pas encore, c'est le principe. Exception : les tests de caracterisation d'un ticket technique doivent etre **verts** (ils capturent l'existant). Verifie deux choses :

- Ils echouent pour la **bonne raison** (assertion fausse, module a creer), pas a cause d'une erreur d'ecriture dans les tests eux-memes
- Les tests existants du projet continuent, eux, de passer

## Etape 4 — Review humaine des tests (pause)

Presente les tests en langage metier, un comportement par ligne :

```
## Tests proposes — [ticket]

`chemin/fichier.spec.ts`
- quand [situation], alors [comportement attendu]
- quand [cas limite], alors [comportement attendu]
```

C'est le moment des echanges : ajuste, ajoute ou supprime selon les retours de l'utilisateur, jusqu'a sa validation explicite. Ces tests deviennent le **contrat** de l'implementation — ils ne seront plus modifies sans accord humain.

Une fois valides :

- Coche `Tests ecrits` et `Tests valides` dans le pilotage
- Liste les fichiers de tests dans sa section Tests (un comportement couvert par ligne)
- Consigne dans Decisions les choix faits pendant la review

## Etape 5 — Proposer la suite

Le dev se fait dans une session neuve, avec un contexte propre — le pilotage et les tests suffisent a la reprise.

```
---
Tests valides. Phase suivante : le dev, dans une NOUVELLE session :
ouvre une session et lance `/pipe-ship [ticket]` (ou `/pipe-code [ticket]`).
```

---

## Input utilisateur

$ARGUMENTS
