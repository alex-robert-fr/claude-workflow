# Livraison : commits, branches et PR

> **Statut** : active
> **Tickets** : —

## En une phrase

Des commits qui se lisent comme la documentation technique du projet, et une Pull Request qui n'en est que le sommaire.

## Intention

Un CHANGELOG oriente consommateur ne peut pas porter le detail technique, et une description de Pull Request est reecrite a chaque iteration. Il reste un seul emplacement stable pour repondre a « pourquoi ce code est comme ca » : le corps du commit.

Reussi quand relire l'historique d'une branche suffit a comprendre la feature et les arbitrages qu'elle a demandes.

## Philosophie

**Un commit est un changeset qui se lit seul.** Le decoupage suit les unites logiques du changement, jamais la nature des fichiers — d'ou l'absence de commit `tests` ou `docs` isole quand ils accompagnent un comportement.

## Comportement attendu

- Une branche porte son type, l'identifiant de son ticket et un titre court en anglais
- Un commit porte un emoji, un type, un scope metier obligatoire pour les changements de code, et une description en francais
- Le corps est obligatoire des que le changement n'est pas trivial, et documente ce que le diff ne montre pas
- Aucune signature automatique n'est ajoutee a un message de commit, a une description de Pull Request ni a un commentaire d'iteration
- Les tests accompagnent le changeset du comportement qu'ils verifient ; une spec modifiee accompagne le changeset de sa feature
- Une spec ecrite hors cycle est la seule a former son propre commit de documentation
- Les fichiers sont stages par chemin explicite ; les fichiers sensibles sont exclus et signales
- Un commit n'est jamais cree sans validation humaine : le message complet (titre + corps) est affiche et confirme avant chaque `git commit`, y compris en enchainement automatique
- Un push n'a jamais lieu sans confirmation explicite
- La description d'une Pull Request decrit toujours son etat complet actuel, jamais son delta
- La description d'une Pull Request est un sommaire : contexte, ce qui a ete fait, un bloc Changelog, et ce qui reste a verifier a la main — jamais de liste de fichiers ni de commits, de section tests ni de points de review
- Le bloc Changelog d'une Pull Request est ecrit au format du CHANGELOG du projet, pour le consommateur, avec ses references vers les commits : il decrit l'etat final de la branche et sera repris tel quel a la release
- Chaque Pull Request reference son ticket, avec fermeture automatique si la plateforme le permet
- L'evolution d'une Pull Request deja ouverte passe par un commentaire d'iteration, pas par sa description
- Le document de pilotage est supprime a la creation de la Pull Request

## Hors scope

- Merger, ou decider quand merger — la protection de branche et l'humain tranchent
- Deduire une version depuis les prefixes de commit — voir [`changelog-et-release.md`](changelog-et-release.md)
- Reecrire l'historique : un commit pousse est immuable, une erreur dans un corps ne se corrige pas apres coup
- Committer un travail non valide : le decoupage de fin de cycle suppose le code deja review

## Fonctionnement technique

Les conventions vivent dans un referentiel unique, jamais invoque et toujours charge par chemin qualifie — depuis le decoupage, la creation de branche, la Pull Request et l'installation d'un projet.

Le decoupage a deux modes, distingues par la presence d'un pilotage valide sur la branche courante : decoupage de fin de cycle sur le travail restant non commite, ou commit ponctuel. Des commits ont pu naitre pendant le dev : le mode de fin de cycle les affiche d'abord pour situer le reste.

La Pull Request tire son contexte du pilotage, sinon de l'identifiant present dans le nom de branche. Son corps porte un bloc Changelog au format du CHANGELOG, redige avec le referentiel de `pipe-changelog` : c'est le sommaire pour le consommateur, le detail restant dans chaque commit que les entrees referencent.

## Dependances

- **Internes** : [`fichier-de-pilotage.md`](fichier-de-pilotage.md) pour le ticket, la version cible et les decisions ; [`review-de-fin-de-cycle.md`](review-de-fin-de-cycle.md), dont la validation precede le decoupage ; la configuration du projet pour la plateforme et la branche par defaut
- **Externes** : `git` ; le MCP de la plateforme pour creer et mettre a jour une Pull Request
- **Dependants** : [`changelog-et-release.md`](changelog-et-release.md), qui reprend les blocs Changelog des Pull Requests mergees et associe les commits restants a leurs Pull Requests

## Decisions

| Version | Ticket | Decision | Raison | Alternative ecartee |
|---------|--------|----------|--------|---------------------|
| — | — | Le corps du commit porte le detail technique | Le CHANGELOG doit rester court et non technique, et une description de PR est reecrite a chaque iteration : le commit est le seul emplacement stable | Un fichier de changements techniques |
| — | — | Chaque commit est valide par un humain avant sa creation | Un commit pousse est immuable et son corps est la doc technique du projet : une erreur de message ne se corrige pas apres coup. Cette decision remplace la precedente (commit sans confirmation, juge reversible) | Committer sans confirmation, recapituler apres |
| — | — | Le decoupage groupe par unite logique, pas par nature de fichier | Un commit `tests` ne se lit pas seul : il decrit un contrat dont le comportement est ailleurs | Separer code, tests et documentation |
| — | — | La description d'une PR est reecrite en etat complet | Une description qui accumule des mentions de nouveaute devient un journal illisible, alors qu'un commentaire d'iteration porte deja le delta | Ajouter les nouveautes en tete |
| — | — | Le referentiel de conventions est retire des deux catalogues | Il n'est jamais invoque, seulement charge par chemin : sa description etait payee dans chaque session pour rien | Le laisser invocable |
| — | — | La description de PR perd ses sections fichiers, commits, tests et points de review | Les listes de fichiers et de commits sont deja dans les onglets de la plateforme et vieillissent a chaque commit ; la CI dit deja si les tests passent ; les points de review recopiaient les corps de commit. Seul reste ce que rien ne couvre automatiquement : les verifications manuelles | Garder un body exhaustif |
| — | — | La description de PR porte un bloc Changelog au format du CHANGELOG | L'entree CHANGELOG etait reconstruite a la release, des semaines apres, en repartant des commits : filtrer, classer, reformuler, fusionner. Ecrite dans la PR, elle l'est quand le contexte est frais, et la release n'a plus qu'a agreger. La PR y gagne la seule section qui dit ce qui change pour l'utilisateur | Une liste de commits dans la PR, derivation complete a la release |
| — | — | Aucune signature automatique dans une PR, comme dans un commit | Un pied de page d'outillage n'apporte rien au lecteur et l'instruction runtime qui le demande n'est pas une convention du projet | Laisser l'outil signer |

## Points d'entree

| Fichier | Role |
|---------|------|
| `skills/git-conventions/SKILL.md` | Formats de branche, de commit et de Pull Request — referentiel unique |
| `skills/git-conventions/reference.md` | Templates de corps de PR et de commentaire d'iteration |
| `skills/pipe-commit/SKILL.md` | Decoupage de fin de cycle et commit ponctuel |
| `skills/pipe-pr/SKILL.md` | Push, contexte, description, iteration, fin de cycle |

## Pieges et zones sensibles

- **Les sauts de ligne des corps envoyes a la plateforme doivent etre reels** : des sequences d'echappement litterales s'affichent en dur dans le markdown publie
- **La suppression du pilotage est le dernier geste du cycle** : l'oublier laisse un cycle qui parait ouvert, et la reprise repartira dessus
- Un fichier qui melange deux changesets est rattache au principal et documente dans son corps : la granularite du staging est le fichier, pas la ligne
