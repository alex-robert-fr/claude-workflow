# Reprise de cycle

> **Statut** : active
> **Tickets** : —

## En une phrase

Une seule commande qui lit ou en est un ticket, execute la phase courante et deroule jusqu'a la prochaine pause humaine.

## Intention

Le cycle traverse plusieurs sessions et sept phases. Retenir laquelle vient ensuite, et laquelle exige un contexte neuf, est une charge inutile — et se tromper coute une session entiere de contexte gaspille.

Reussi quand reprendre un ticket ne demande de se rappeler ni la phase, ni la commande, ni la branche.

## Philosophie

**Aucune logique propre.** Ce skill localise, identifie et délègue : toute règle métier qu'il porterait existerait en double avec le skill de la phase, et l'une des deux copies serait fausse.

## Comportement attendu

- Sans argument, un cycle unique est pris automatiquement ; plusieurs cycles ouverts declenchent une question
- Aucun cycle en cours ouvre le cadrage, qui creera le pilotage : la commande est un point d'entrée autant qu'une reprise
- Demarrer un cycle exige un ticket ou un nom de feature : sans lui, il est demande avant d'enchainer
- La phase courante est la première étape non validee du pilotage, jamais une deduction depuis l'etat du code
- La phase est annoncee avant d'être exécutée : ticket, branche, ce qui va se passer
- Les phases s'enchainent tant qu'aucune frontiere de session n'est franchie
- Une phase exigeant un contexte neuf n'est pas enchainee : le geste a faire est affiche a la place
- Lancee en debut de session, la phase courante s'execute quelle qu'elle soit
- Les pauses humaines restent gerees par les phases elles-memes, une validation dans la session permet de continuer
- En enchainement, les propositions de suite des phases sont ignorees : la suite est pilotee ici
- Un cycle dont toutes les étapes sont validees est signale comme termine, avec proposition de nettoyer son pilotage
- Chaque tour se termine par une ligne : ou on en est, et le prochain geste

## Hors scope

- Executer une phase a la place du skill concerne — les phases restent invocables directement
- Deviner une phase depuis le code ou l'historique git : l'etat declare du pilotage fait autorite
- Franchir une frontiere de session, meme si tout est pret : c'est precisement ce que la frontiere protege
- Valider a la place de l'humain : une pause reste une pause

## Fonctionnement technique

Le pilotage est localise, sa section d'etat lue, et la première étape non validee sert de cle dans une table qui associe chaque étape a un skill et a une exigence de session. Le skill correspondant est charge par chemin qualifie et applique en entier, puis la table est reconsultee.

Deux phases exigent un contexte neuf : l'implementation et la review. La frontiere ne se declenche que si une autre phase a déjà tourne dans la conversation — sinon la session est neuve par construction.

## Dependances

- **Internes** : [`fichier-de-pilotage.md`](fichier-de-pilotage.md), dont la section d'etat est la seule source de vérité ; toutes les specs de phases, chargées a la demande
- **Dependants** : aucune — c'est un point d'entrée

## Decisions

| Version | Ticket | Decision | Raison | Alternative ecartee |
|---------|--------|----------|--------|---------------------|
| — | — | La phase se lit dans le pilotage, pas dans l'etat du repo | Une branche poussee ou une suite verte ne disent pas si un humain a valide : seule une case cochee le dit | Deduire la phase du code et de git |
| — | — | Aucune logique métier ici | Une règle dupliquee entre ce skill et celui de la phase divergerait au premier changement, et le doublon silencieux serait le pire cas | Recopier les verifications de chaque phase |
| — | — | Un cycle absent est ouvert plutot qu'annonce | La commande est censee être le seul geste a retenir : renvoyer vers une autre commande pour la seule phase de depart en fait une exception a memoriser | Proposer le cadrage et rendre la main |
| — | — | La frontiere de session ne s'applique qu'en enchainement | Bloquer aussi un lancement en debut de session rendrait la reprise impossible precisement quand elle est legitime | Bloquer inconditionnellement |

## Points d'entrée

| Fichier | Rôle |
|---------|------|
| `skills/pipe-ship/SKILL.md` | Localisation, detection de phase, table etat → skill, frontieres de session |
| `shared/pilotage-template.md` | Ordre des étapes de la section d'etat |

## Pieges et zones sensibles

- **La table etat → skill est couplee a l'ordre des cases du pilotage** : ajouter une phase sans toucher les deux rend la nouvelle étape inatteignable, sans erreur visible
- **Le cadrage sans argument ne demarre pas un cycle mais l'inventaire des specs existantes** : d'ou le ticket exige avant d'y router
- **Une case cochee en avance saute definitivement sa phase** : rien ne revient en arriere, la reprise fait confiance a l'etat declare
- Le pilotage doit avoir ete supprime a la creation de la Pull Request : sinon la reprise repart sur un cycle déjà livre
