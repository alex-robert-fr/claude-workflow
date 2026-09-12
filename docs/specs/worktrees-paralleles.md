# Worktrees paralleles

> **Statut** : active
> **Tickets** : —

## En une phrase

Ouvrir plusieurs branches cote a cote sur le disque, et y basculer le contexte de travail, sans jamais changer la branche du depot principal.

## Intention

Le cycle impose des sessions dediees au dev et a la review. Traiter deux tickets en parallele par des changements de branche successifs oblige a remiser du travail en cours, et une remise oubliee finit par être perdue ou committee au mauvais endroit.

Reussi quand deux tickets avancent en parallele sans qu'aucun n'ait a être remise.

## Philosophie

**Un emplacement previsible plutot qu'un emplacement choisi.** La convention se calcule depuis le nom de branche : n'importe quelle session retrouve le repertoire sans avoir a le demander.

## Comportement attendu

- Les emplacements se deduisent du nom du depot et du nom de branche, dans un repertoire frere du depot principal
- Les barres du nom de branche deviennent des tirets pour former le nom de repertoire
- Sans action precisee, l'inventaire est affiche — c'est le seul comportement par defaut
- Une action inconnue affiche les actions disponibles et s'arrete
- La creation refuse un emplacement déjà pris, et crée la branche si elle n'existe pas encore
- La bascule remet le contexte de travail dans l'emplacement demande, sans deplacer le depot principal
- La suppression exige une confirmation explicite, et refuse de s'executer depuis l'emplacement vise
- Une suppression est suivie du nettoyage des references devenues mortes
- L'inventaire vide est annonce comme tel, avec le geste pour en créer un

## Hors scope

- Creer une branche pour elle-meme — la branche d'un cycle est créée a l'ecriture des tests, pas ici
- Synchroniser ou nettoyer automatiquement les emplacements obsoletes : la suppression reste un geste demande
- Gerer les depots distants ou les sous-modules — le perimetre est le depot local courant
- Executer autre chose que des commandes de gestion d'emplacement : les capacites sont restreintes a la lecture et a `git`

## Fonctionnement technique

L'etat courant — emplacements actifs, branche courante, racine du depot — est injecte au demarrage par des commandes pre-executees, avant tout raisonnement : le routage n'a donc jamais a decouvrir l'etat lui-meme.

Le premier argument route vers l'une des quatre actions, le second porte le nom de branche. La bascule de contexte passe par la capacite native prévue a cet effet, pas par un changement de repertoire — un changement de repertoire ne survivrait pas a l'appel suivant.

## Dependances

- **Externes** : `git` et sa gestion d'emplacements de travail ; la capacite native de bascule et de sortie de contexte
- **Dependants** : [`developpement-guide-par-les-tests.md`](developpement-guide-par-les-tests.md), dont les sessions dediees peuvent s'executer dans un emplacement separe

## Decisions

| Version | Ticket | Decision | Raison | Alternative ecartee |
|---------|--------|----------|--------|---------------------|
| — | — | L'emplacement est calcule, jamais choisi | Un chemin déductible du nom de branche se retrouve depuis n'importe quelle session, sans etat a conserver | Demander le chemin a chaque fois |
| — | — | Les emplacements vivent dans un repertoire frere du depot | Les imbriquer dans le depot les expose au versionnement et aux commandes de nettoyage | Un repertoire a l'interieur du depot |
| — | — | L'inventaire est l'action par defaut | C'est la seule action sans effet, donc la seule sans risque quand l'intention est ambigue | Exiger une action explicite |
| — | — | La suppression est confirmee, la creation non | Elle detruit du travail non committe sans recours, alors qu'un emplacement créé en trop se supprime | Confirmer les deux |
| — | — | Les capacites sont restreintes a la lecture et a `git` | Un skill qui ne fait que manipuler des emplacements n'a besoin de rien d'autre, et la restriction rend l'ecart impossible plutot qu'interdit | Laisser les capacites ouvertes |

## Points d'entrée

| Fichier | Rôle |
|---------|------|
| `skills/worktree/SKILL.md` | Convention d'emplacement, routage des quatre actions, contexte pre-execute |

## Pieges et zones sensibles

- **La bascule ne peut pas se faire par changement de repertoire** : seul l'outil natif deplace reellement le contexte, un `cd` serait perdu des l'appel suivant
- **Supprimer un emplacement depuis l'interieur laisse le contexte sur un chemin disparu** : d'ou le refus, qui n'est pas une precaution de confort
- Le calcul du nom de repertoire est ambigu par construction : deux branches ne differant que par une barre ou un tiret produisent le meme emplacement
