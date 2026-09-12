# CHANGELOG et release

> **Statut** : active
> **Tickets** : —

## En une phrase

Le CHANGELOG parle a qui consomme le projet, et la chaine de release le publie : version, PR vers la production, puis tag annote.

## Intention

Deux lecteurs sont confondus par defaut : celui qui consomme le projet veut savoir ce qui change pour lui, celui qui le developpe veut le detail technique. Un journal qui sert les deux ne sert ni l'un ni l'autre.

C'est reussi quand une entrée se comprend sans ouvrir le code, et que le detail reste atteignable en un clic.

## Philosophie

L'impact consommateur tranche ; le prefixe du commit n'est qu'un indice. Un `refactor` qui modifie une API publique entre, un `feat` purement interne n'entre pas. Au moindre doute, exclure **et** signaler l'ambiguite plutot que de decider seul.

## Comportement attendu

- Une entrée tient sur une ligne, decrit un effet observable, et pointe vers sa PR ou son commit
- Les blocs Changelog des Pull Requests mergees sont la source primaire des entrées, repris tels quels avec la PR pour reference ; la derivation depuis les commits ne s'applique qu'aux changements sans bloc
- Plusieurs commits qui composent le meme changement vu du consommateur donnent une seule entrée
- Un artefact ajoute puis retire dans la meme release ne produit aucune entrée : seul l'etat final est decrit
- Un changement sans impact consommateur n'apparait pas — sa trace est le corps de son commit
- Une entrée dont la reference est posterieure au tag de sa section est signalee comme mal placee : le deplacement est propose, jamais applique d'office
- La version est proposee puis confirmee par un humain ; le tag est toujours annote
- Une decision de spec notee `(a venir)` perd cette mention quand sa version est livree
- Le CHANGELOG n'est jamais charge en entier : il grossit a chaque release, et seuls son en-tete et la section visee sont utiles
- Quand le tracker configuré est Jira ou Linear, le tag de production synchronise aussi le statut des tickets couverts sur le tracker — jamais avant, le code n'est livré qu'à ce moment-là

## Hors scope

- La publication automatique — créer une release sur la plateforme ou pousser un artefact appartient au CI
- Deduire la version des commits — un bump majeur ne doit pas dependre d'un prefixe mal choisi
- Un fichier de changements techniques separe — l'historique git joue ce rôle sans risque de derive

## Fonctionnement technique

Trois temps, deux branches. Depuis la branche d'integration : rédaction du CHANGELOG, puis PR vers la branche de production. Le merge et la mise en production sont humains et **interrompent la chaine** — le tag annote ne vient qu'apres, pose sur la production, avec la section du CHANGELOG pour corps de message.

La version du plugin se resout par ordre de priorité : le champ de `plugin.json`, puis celui de l'entrée marketplace, puis le SHA du commit. Une seule declaration fait donc autorite, et c'est elle qui sert de cle de cache aux mises a jour.

## Dependances

- **Internes** : la configuration du projet fournit les branches d'integration et de production ; [`livraison-git.md`](livraison-git.md) fournit les blocs Changelog des Pull Requests
- **Externes** : `git` et ses tags ; l'API de la plateforme pour associer les commits a leurs PRs, en un seul appel groupe
- **Dependants** : les journaux de decisions de `docs/specs/`, dont les mentions de version sont figees au moment de la release

## Decisions

| Version | Ticket | Decision | Raison | Alternative ecartee |
|---------|--------|----------|--------|---------------------|
| 1.6.0 | — | Une seule declaration de version fait autorite | Deux des quatre declarations d'origine n'etaient jamais lues : l'entrée marketplace est masquee par `plugin.json`, et le champ sous `metadata` n'existe que par compatibilite ascendante | Synchroniser les quatre par script |
| 1.6.0 | — | Le bump de version reste un geste local | La mecanique de publication d'un plugin est propre a ce repo ; un skill distribue ne peut pas la porter | Integrer le bump a la chaine de release distribuee |
| 1.6.0 | — | L'audit de cohérence ne tourne qu'a la publication | En mode brouillon il coutait plusieurs appels reseau par exécution, pour un historique qui n'avait pas bouge | Auditer a chaque passage |
| 1.6.0 | — | Le CHANGELOG est lu par bornes | Un fichier qui grossit a chaque release finit par couter plus cher que la seule section utile | Le charger puis en extraire la section |
| — | — | Les blocs Changelog des PRs sont la source primaire | L'entrée est ecrite par celui qui a fait le changement, quand le contexte est frais ; la release agrege au lieu de re-deriver. Les commits restent le repli pour tout ce qui n'a pas de bloc, dont l'historique anterieur | Tout re-deriver des commits a chaque release |
| 1.8.0 (a venir) | — | La synchronisation du statut des tickets a lieu au tag, pas à la PR de release | Le tag marque le déploiement réellement confirmé ; la PR de release ne fait encore que proposer un contenu, pas livré | Synchroniser dès la création de la PR de release |

## Points d'entrée

| Fichier | Rôle |
|---------|------|
| `skills/pipe-changelog/SKILL.md` | Collecte, filtrage, classement et rédaction des entrées |
| `skills/pipe-changelog/reference.md` | Conventions, mapping des types, exclusions |
| `skills/pipe-release/SKILL.md` | Version, contenu de la release, PR vers la production |
| `skills/pipe-tag/SKILL.md` | Tag annote, notes extraites du CHANGELOG |
| `.claude/scripts/bump-version.sh` | Version du plugin de ce repo — local, non distribue |

## Pieges et zones sensibles

- **Ne pas bumper la version est une panne totale et silencieuse.** Elle sert de cle de cache : pousser des commits ne suffit pas, la mise a jour repond que tout est déjà a jour et personne ne recoit rien. Aucun test, aucun lint et aucune review ne rattrapent cet oubli
- **Aucun skill ne declenche le bump** : la chaine de release l'ignore, il reste a lancer a la main
- **Ni l'entrée marketplace ni le champ de compatibilite ascendante ne doivent revenir** : ils ne cassent rien, ils mentent — une version affichee qui n'est jamais celle qui s'applique
- **La cible d'installation du marketplace doit suivre le remote** : `repo`, `homepage` et `repository` pointent vers le depot reel, sinon l'installation vise un autre depot que celui publie
