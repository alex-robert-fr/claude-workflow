---
name: pipe-test
description: Ecrire les tests d'une feature avant son implementation, depuis le plan du pilotage. Ils deviennent le contrat du dev.
argument-hint: [cle du ticket ou rien si un seul cycle en cours]
---

## Étape 0 — Verifications

Utilise Read pour charger `.claude/skills/workflow-config/SKILL.md`, puis localise le fichier de pilotage :

- Argument fourni → `.claude/plans/plan-<identifiant>.md`
- Sans argument → cherche `.claude/plans/plan-*.md` : un seul fichier → le prendre ; plusieurs → demander lequel

Verifie :

- [ ] Le pilotage existe (sinon → lancer `/pipe-plan` d'abord)
- [ ] `Plan valide` est coche dans son etat
- [ ] Une commande de test est configuree dans `workflow-config`

Si une verification echoue, signale-le clairement et arrete-toi.

## Étape 1 — Creer la branche

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/../git-conventions/SKILL.md` (conventions de branches).

Si le pilotage indique déjà une branche (reprise), fais simplement un checkout dessus. Sinon, identifie la branche par defaut depuis `workflow-config` (`BASE_BRANCH`) et execute exactement :

1. `git checkout <BASE_BRANCH>`
2. `git pull origin <BASE_BRANCH>`
3. `git checkout -b <nouvelle-branche>`

Ne jamais hardcoder `main` ou `develop` — toujours lire la valeur depuis `workflow-config`.

Note la branche dans la section Branche du pilotage et annonce-la.

## Étape 2 — Ecrire les tests

Ecris les tests unitaires depuis le plan (comportement attendu, cas limites, section Tests) :

- **Si le pilotage reference une spec** (`docs/specs/<feature>.md`), lis-la : sa section « Comportement attendu » enonce les garanties de la feature — ce sont des tests. Son « Hors scope » delimite ce qu'il ne faut **pas** tester.
- **La règle de couverture** : si tous ces tests passent, la fonctionnalité est bonne. Chaque test verifie un comportement qui compte — cas nominal, cas limites identifies au plan, cas d'erreur. Pas de tests pour gonfler le compteur.
- Framework et conventions de test du projet (`workflow-config`)
- **N'implemente pas la fonctionnalité** : uniquement les tests, plus le squelette minimal si la suite en a besoin pour s'executer (signatures vides, types — aucune logique)

### Cas particulier — ticket technique (refactor, migration)

Un refactor ne crée pas de comportement nouveau : le contrat, ce sont les **tests existants** qui doivent rester verts a travers le changement.

- Evalue la couverture de la zone touchee. Si elle est insuffisante, ecris des **tests de caracterisation** qui capturent le comportement actuel — eux doivent être **verts** avant le dev, contrairement aux tests d'une nouvelle fonctionnalité
- Si la couverture existante suffit, ne rajoute rien et dis-le : la review humaine (étape 5) porte alors sur la question "cette couverture suffit-elle pour refactorer sans risque ?"

## Étape 3 — Vérifier que les tests sont rouges

Lance la commande de test. Les nouveaux tests **doivent echouer** — la fonctionnalité n'existe pas encore, c'est le principe. Exception : les tests de caracterisation d'un ticket technique (étape 2) doivent être **verts**. Verifie deux choses :

- Ils echouent pour la **bonne raison** (assertion fausse, module a créer), pas a cause d'une erreur d'ecriture dans les tests eux-memes
- Les tests existants du projet continuent, eux, de passer

## Étape 4 — Critique indépendante des tests (sub-agent)

Avant la review humaine : un sub-agent qui n'a pas écrit ces tests les critique à froid. L'isolation de contexte est la garantie d'indépendance, pas une simple relecture.

Lance un **sub-agent** (Agent tool, type `general-purpose`, model `sonnet`).

Prompt du sub-agent :

```
Utilise Read pour charger les fichiers de tests suivants :
- [chemin fichier de tests]

Utilise Read pour charger le pilotage : [chemin du pilotage] — sa section "Tests" énonce les comportements attendus et les cas limites visés.

Mission : critique sans complaisance de ces tests, sans rien réécrire ni implémenter. Identifie :
- Tests redondants : deux tests qui vérifient au fond la même chose sous une forme différente
- Tests qui vérifient le framework/langage plutôt que le comportement de la feature (ex : vérifier qu'un objet a bien la propriété qu'on vient de lui assigner deux lignes plus haut, sans logique métier impliquée)
- Tests à l'assertion triviale ou tautologique : ils passeraient même si l'implémentation était fausse
- Cas limites cités dans la section "Tests" du plan mais absents des tests écrits

Sortie au format Question/Réponse, courte, sans prose :

À retirer
- [test] → [raison en une ligne]

À compléter
- [cas limite manquant] → [raison en une ligne]

Rien à signaler dans une catégorie → l'écrire explicitement ("Aucun test à retirer.").
```

Remplace les crochets par les valeurs réelles avant de lancer le sub-agent.

Applique la critique avant toute présentation à l'utilisateur : retire les tests signalés « à retirer », écris ceux signalés « à compléter », puis reprends l'étape 3 pour eux — ils doivent, eux aussi, échouer pour la bonne raison.

## Étape 5 — Review humaine des tests (pause)

Présente les tests, déjà resserrés par la critique de l'étape précédente, en langage métier, un comportement par ligne :

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
- Un choix fait pendant la review qui contredit le plan corrige le plan en place (section Tests ou point d'attention)

## Étape 6 — Proposer la suite

Le dev se fait dans une session neuve, avec un contexte propre — le pilotage et les tests suffisent a la reprise.

```
---
Tests valides. Suite : le dev, dans une **nouvelle session** — `/pipe-ship [ticket]`.
```

---

## Input utilisateur

$ARGUMENTS
