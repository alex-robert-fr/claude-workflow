# Développement guide par les tests

> **Statut** : active
> **Tickets** : —

## En une phrase

Les tests sont ecrits, valides par un humain, puis figes : l'implementation les suit dans une session dediee et n'a pas le droit de les changer.

## Intention

Un modele qui ecrit le code et ses tests dans la meme foulee ajuste les seconds au premier — la suite devient verte sans rien garantir. Et une session qui a déjà porte le cadrage, le plan et les tests n'a plus le contexte disponible pour implementer proprement.

Reussi quand la suite verte est une preuve, et non un constat d'accord du code avec lui-meme.

## Philosophie

**Les tests valides sont le contrat.** Ce qui a ete valide par un humain ne se renegocie pas en cours d'implementation : un test qui semble faux arrete le travail au lieu d'être corrige.

## Comportement attendu

- Les tests s'ecrivent avant l'implementation, depuis le plan du ticket
- La branche est créée a ce moment-la, depuis la branche par defaut lue dans la configuration, jamais depuis un nom code en dur
- La spec de la feature enonce ce qui doit rester garanti ; son hors-scope delimite ce qu'il ne faut pas tester
- La règle de couverture est qualitative : si tous ces tests passent, la fonctionnalité est bonne — aucun test pour gonfler un compteur
- Aucune logique n'est implementee a l'ecriture des tests, au plus le squelette minimal permettant a la suite de s'executer
- Les nouveaux tests doivent echouer, et pour la bonne raison ; les tests existants doivent continuer de passer
- Un ticket technique produit au besoin des tests de caracterisation, qui doivent eux être verts avant le dev
- Les tests sont presentes en langage métier, un comportement par ligne, et ne sont figes qu'apres accord explicite
- L'implementation se fait dans une session neuve, dont tout le contexte est le pilotage, les tests et la spec
- Un test suspecte de fausseté arrete l'implementation et remonte a l'humain
- Les unites logiques terminees sont committees au fil du dev, chacune déjà conforme aux conventions ; le reste attend le decoupage de fin de cycle
- Un problème non anticipe par le plan arrete l'implementation, avec des options presentees

## Hors scope

- Vérifier le style ou le formatage — les garde-fous outilles s'en chargent a l'ecriture du fichier
- Mesurer un taux de couverture — la question est la valeur des comportements vérifiés, pas leur nombre
- Modifier un test pour faire passer une suite, meme s'il parait faux : la decision est humaine
- Reviewer son propre travail : la review a sa propre session et son propre contexte

## Fonctionnement technique

Deux phases, séparées par une pause humaine et une frontiere de session. La première crée la branche, ecrit les tests, verifie qu'ils sont rouges pour la bonne raison, et les fait valider. La seconde repart d'un contexte vide : elle relit le pilotage et la spec, puis boucle coder, tester, corriger jusqu'a ce que tout passe.

La frontiere de session est ce qui rend le contrat effectif : le contexte qui implemente n'a pas assiste a la negociation des tests, il ne peut donc que les satisfaire.

Les ecarts au plan et le contexte utile a la review sont notes dans le pilotage a la cloture, pas conserves en memoire de session.

## Dependances

- **Internes** : [`plan-technique-d-un-ticket.md`](plan-technique-d-un-ticket.md), dont la section des tests est la source ; [`fichier-de-pilotage.md`](fichier-de-pilotage.md) ; [`cycle-de-vie-d-une-spec.md`](cycle-de-vie-d-une-spec.md) pour les garanties de la feature ; [`livraison-git.md`](livraison-git.md) pour les commits au fil de l'eau ; la configuration du projet pour la commande de test et la branche par defaut
- **Externes** : le framework de test du projet ; `git`
- **Dependants** : [`review-de-fin-de-cycle.md`](review-de-fin-de-cycle.md), qui suppose la suite verte

## Decisions

| Version | Ticket | Decision | Raison | Alternative ecartee |
|---------|--------|----------|--------|---------------------|
| — | — | Les tests valides sont interdits a l'implementation | Un modele qui peut ajuster le test ajuste le test : la suite devient verte sans rien prouver | Autoriser les ajustements justifies |
| — | — | L'implementation exige une session neuve | Le contexte qui a negocie les tests est aussi celui qui serait tente de les relacher, et il est déjà charge par trois phases | Enchainer dans la meme session |
| — | — | Les tests doivent être rouges pour la bonne raison | Un test rouge par erreur d'ecriture passe au vert des qu'on le corrige, sans qu'aucun comportement soit verifie | Constater simplement l'echec |
| — | — | Un ticket technique utilise des tests de caracterisation verts | Un refactor ne crée aucun comportement : son contrat est que l'existant survive, et il faut donc capturer l'existant avant | Ecrire des tests rouges quand meme |
| — | — | Des commits naissent pendant le dev | Attendre la fin du cycle pour tout decouper produit un diff que plus personne ne separe proprement | Tout committer en fin de cycle |

## Points d'entrée

| Fichier | Rôle |
|---------|------|
| `skills/pipe-test/SKILL.md` | Branche, ecriture des tests, verification rouge, review humaine |
| `skills/pipe-code/SKILL.md` | Boucle d'implementation, commits au fil de l'eau, cloture |

## Pieges et zones sensibles

- **La frontiere de session est structurelle, pas une preference** : l'enjamber remet le contrat entre les mains de qui doit le satisfaire
- **Les tests de caracterisation inversent la règle du rouge** : les traiter comme les autres ferait echouer la verification alors que tout est correct
- La branche est créée a l'ecriture des tests, donc avant toute implementation : une reprise doit s'y remettre plutot que d'en créer une seconde
- Le squelette minimal autorise avant l'implementation est une zone de derive : y glisser de la logique rend la verification rouge inoperante
