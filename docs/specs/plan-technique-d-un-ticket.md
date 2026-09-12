# Plan technique d'un ticket

> **Statut** : active
> **Tickets** : —

## En une phrase

Transformer un ticket en feuille de route actionnable, co-construite par questions/reponses et calibree a la taille reelle du travail.

## Intention

Un ticket dit un besoin, jamais un decoupage. Sans étape intermediaire, l'implementation invente l'architecture au fil de l'ecriture, et les arbitrages structurants se decouvrent a la review — quand ils coutent le plus cher a defaire.

Reussi quand l'ecriture des tests puis du code n'a plus a decider ou vit la logique.

## Philosophie

**Le plan se construit a deux, et seulement sur ce que le cadrage n'a pas déjà tranche.** Intention et perimetre sont acquis ; ce qui reste a decider est le decoupage. Une question qui rejoue la spec fait payer deux fois le meme arbitrage.

## Comportement attendu

- Un ticket est identifiable depuis un numéro, une cle, une URL ou du texte libre, sur la plateforme git ou un tracker externe
- La plateforme est detectee depuis le remote, et la configuration du projet a priorité sur la detection
- Le plan ne demarre pas avant que la feature soit specifiee : spec absente ou perimee, le cadrage est lance ; ticket sans feature, c'est note comme tel
- Un projet sans repertoire de specs ne bloque pas : le cadrage est propose, refuse il n'empeche pas de continuer
- Chaque ticket est classifie technique, métier ou mixte, et la classification est annoncee
- Un ticket sans comportement a tester est reoriente vers la voie rapide, et le pilotage eventuellement ouvert est supprime
- Un ticket trop large est decoupe en sous-tickets créés sur le tracker, dont seul le premier est planifie en detail
- Les questions ne portent que sur le métier non couvert par la spec et sur l'architecture, jamais sur le nommage ni le bas niveau
- Aucune vraie question a poser est un resultat valide, et c'est dit
- Le plan cite des chemins reels, marque explicitement ce qui n'existe pas encore, et ne contient aucun bloc de code
- Il tient dans un budget borne et se termine par un recapitulatif des fichiers scannable
- Le plan n'est valide qu'apres accord explicite de l'utilisateur

## Hors scope

- Ecrire le code ou les tests — le plan les rend possibles, il ne les anticipe pas ligne a ligne
- Trancher le pourquoi ou le perimetre de la feature — c'est le cadrage, en amont
- Recopier le contenu de la spec dans le pilotage — seul son chemin y figure
- Planifier tous les sous-tickets d'un decoupage : chacun sera planifie au moment de l'implementer

## Fonctionnement technique

La detection de l'environnement et la recuperation du ticket sont mutualisees avec le cadrage : meme section, meme fichier de references. Sur un tracker hierarchise, la remontee des parents fournit la version cible et l'epic, relues sur le tracker par le journal des specs et la Pull Request — le pilotage ne porte que l'identifiant du ticket.

Le plan est ecrit dans le pilotage, jamais dans un document a part. S'il a ete ouvert par le cadrage, il est complété sans rien ecraser ; sinon il est créé. La section des tests du plan est celle que l'ecriture des tests transforme directement en cas de test, ce qui en fait la plus sensible.

## Dependances

- **Internes** : [`cycle-de-vie-d-une-spec.md`](cycle-de-vie-d-une-spec.md), dont l'index conditionne le demarrage ; [`fichier-de-pilotage.md`](fichier-de-pilotage.md), ou le plan est ecrit ; la configuration du projet pour la plateforme et les branches
- **Externes** : les MCP de plateforme et de tracker pour lire un ticket et créer des sous-tickets
- **Dependants** : [`developpement-guide-par-les-tests.md`](developpement-guide-par-les-tests.md), qui consomme le plan et sa section de tests

## Decisions

| Version | Ticket | Decision | Raison | Alternative ecartee |
|---------|--------|----------|--------|---------------------|
| — | — | Le plan est conditionne a l'existence d'une spec | Planifier le comment avant que le quoi soit pose produit un plan qu'il faut refaire des que le perimetre se précise | Planifier puis specifier apres coup |
| — | — | Le registre métier des questions est reduit aux cas limites | Ce que la spec tranche est acquis ; rejouer le cadrage fait payer deux fois le meme arbitrage et lasse l'utilisateur | Rejouer le perimetre a chaque ticket |
| — | — | Aucun bloc de code dans le plan | Du code dans un plan est du code non teste, non formate et déjà perime — et il gonfle le document au point qu'il n'est plus relu | Donner les signatures complètes |
| — | — | Un ticket sans comportement a tester quitte le cycle | Le cycle complet coute plusieurs sessions : l'imposer a une correction de libelle discredite le workflow entier | Faire passer tout ticket par le cycle |
| — | — | La detection de l'environnement est partagee avec le cadrage | Deux copies de la meme table de plateformes divergent des qu'une seule est corrigee | Dupliquer la section |

## Points d'entrée

| Fichier | Rôle |
|---------|------|
| `skills/pipe-plan/SKILL.md` | Recuperation du ticket, classification, taille, exploration, Q/R, rédaction |
| `skills/pipe-plan/reference.md` | Detection d'environnement, template de plan, critères de classification et de decoupage |
| `shared/pilotage-template.md` | Structure du document ou le plan est ecrit |

## Pieges et zones sensibles

- **La section des tests du plan compte double** : c'est la seule que l'ecriture des tests transforme en contrat, un cas limite oublie la n'existera nulle part ailleurs
- **Le pilotage a pu être ouvert par le cadrage** : le recreer ecraserait l'en-tete et les cases déjà cochees
- La detection d'environnement est lue par deux skills : la modifier engage aussi le cadrage
- Basculer en voie rapide sans supprimer le pilotage laisse un cycle fantome que la reprise relancera
