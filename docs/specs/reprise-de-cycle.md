# Reprise de cycle

> **Statut** : active
> **Tickets** : —

## En une phrase

Une seule commande qui lit ou en est un ticket, execute la phase courante et deroule jusqu'a la prochaine pause humaine.

## Intention

Le cycle traverse plusieurs sessions et sept phases. Retenir laquelle vient ensuite, et laquelle exige un contexte neuf, est une charge inutile — et se tromper coute une session entiere de contexte gaspille.

Reussi quand reprendre un ticket ne demande de se rappeler ni la phase, ni la commande, ni la branche.

## Philosophie

**Aucune logique propre.** Ce skill localise, identifie et delegue : toute regle metier qu'il porterait existerait en double avec le skill de la phase, et l'une des deux copies serait fausse.

## Comportement attendu

- Sans argument, un cycle unique est pris automatiquement ; plusieurs cycles ouverts declenchent une question
- Aucun cycle en cours propose de demarrer par le cadrage, et s'arrete la
- La phase courante est la premiere etape non validee du pilotage, jamais une deduction depuis l'etat du code
- La phase est annoncee avant d'etre executee : ticket, branche, ce qui va se passer
- Les phases s'enchainent tant qu'aucune frontiere de session n'est franchie
- Une phase exigeant un contexte neuf n'est pas enchainee : le geste a faire est affiche a la place
- Lancee en debut de session, la phase courante s'execute quelle qu'elle soit
- Les pauses humaines restent gerees par les phases elles-memes, une validation dans la session permet de continuer
- En enchainement, les propositions de suite des phases sont ignorees : la suite est pilotee ici
- Un cycle dont toutes les etapes sont validees est signale comme termine, avec proposition de nettoyer son pilotage
- Chaque tour se termine par une ligne : ou on en est, et le prochain geste

## Hors scope

- Executer une phase a la place du skill concerne — les phases restent invocables directement
- Deviner une phase depuis le code ou l'historique git : l'etat declare du pilotage fait autorite
- Franchir une frontiere de session, meme si tout est pret : c'est precisement ce que la frontiere protege
- Valider a la place de l'humain : une pause reste une pause

## Fonctionnement technique

Le pilotage est localise, sa section d'etat lue, et la premiere etape non validee sert de cle dans une table qui associe chaque etape a un skill et a une exigence de session. Le skill correspondant est charge par chemin qualifie et applique en entier, puis la table est reconsultee.

Deux phases exigent un contexte neuf : l'implementation et la review. La frontiere ne se declenche que si une autre phase a deja tourne dans la conversation — sinon la session est neuve par construction.

## Dependances

- **Internes** : [`fichier-de-pilotage.md`](fichier-de-pilotage.md), dont la section d'etat est la seule source de verite ; toutes les specs de phases, chargees a la demande
- **Dependants** : aucune — c'est un point d'entree

## Decisions

| Version | Ticket | Decision | Raison | Alternative ecartee |
|---------|--------|----------|--------|---------------------|
| — | — | La phase se lit dans le pilotage, pas dans l'etat du repo | Une branche poussee ou une suite verte ne disent pas si un humain a valide : seule une case cochee le dit | Deduire la phase du code et de git |
| — | — | Aucune logique metier ici | Une regle dupliquee entre ce skill et celui de la phase divergerait au premier changement, et le doublon silencieux serait le pire cas | Recopier les verifications de chaque phase |
| — | — | La frontiere de session ne s'applique qu'en enchainement | Bloquer aussi un lancement en debut de session rendrait la reprise impossible precisement quand elle est legitime | Bloquer inconditionnellement |

## Points d'entree

| Fichier | Role |
|---------|------|
| `skills/pipe-ship/SKILL.md` | Localisation, detection de phase, table etat → skill, frontieres de session |
| `shared/pilotage-template.md` | Ordre des etapes de la section d'etat |

## Pieges et zones sensibles

- **La table etat → skill est couplee a l'ordre des cases du pilotage** : ajouter une phase sans toucher les deux rend la nouvelle etape inatteignable, sans erreur visible
- **Une case cochee en avance saute definitivement sa phase** : rien ne revient en arriere, la reprise fait confiance a l'etat declare
- Le pilotage doit avoir ete supprime a la creation de la Pull Request : sinon la reprise repart sur un cycle deja livre
