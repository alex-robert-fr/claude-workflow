# Creation d'issues

> **Statut** : active
> **Tickets** : —

## En une phrase

Transformer une demande formulee librement en issues structurees, decoupees par domaine et porteuses de criteres d'acceptance.

## Intention

Une demande orale melange souvent plusieurs sujets, et l'issue qui en resulte devient un fourre-tout impossible a estimer, a assigner ou a fermer. Le decoupage a la creation est le seul moment ou il coute encore peu.

Reussi quand chaque issue creee peut etre prise seule par quelqu'un qui n'a pas assiste a la conversation.

## Philosophie

**En cas de doute, decouper.** Une issue trop petite se referme sans dommage ; une issue fourre-tout pollue le tracker jusqu'a ce que quelqu'un la reecrive.

## Comportement attendu

- Une demande couvrant plusieurs domaines fonctionnels, ou melant un bug et une evolution, produit plusieurs issues
- Un element fortement couple aux autres reste dans une issue unique
- Le titre porte le type entre crochets et une description concise
- Le corps expose le contexte, la description precise, des criteres d'acceptance cochables, et les contraintes techniques si elles existent
- Le type du titre determine le label, cree sur le depot s'il n'existe pas encore
- Une dependance entre issues est mentionnee dans le contexte de celle qui depend
- Le recapitulatif complet est presente et confirme avant toute creation
- Les issues sont creees dans l'ordre des dependances, et leurs adresses affichees

## Hors scope

- Planifier ou estimer — une issue dit le besoin, le plan technique vient au moment de la prendre
- Assigner, jalonner, prioriser : ce sont des decisions d'equipe, pas des consequences de la redaction
- Ouvrir un cycle de developpement : creer l'issue et la traiter sont deux gestes distincts
- Alimenter un tracker externe — le perimetre est le depot detecte depuis le remote

## Fonctionnement technique

Le depot cible est deduit du remote, jamais demande. Les regles de decoupage, le template de corps et la table des labels vivent dans un fichier de references charge seulement quand la demande justifie un decoupage — une demande manifestement unique n'en paie pas le cout.

## Dependances

- **Externes** : le MCP de la plateforme pour identifier le depot, creer les issues et leurs labels
- **Dependants** : [`plan-technique-d-un-ticket.md`](plan-technique-d-un-ticket.md), qui consomme ces issues comme point de depart d'un cycle

## Decisions

| Version | Ticket | Decision | Raison | Alternative ecartee |
|---------|--------|----------|--------|---------------------|
| — | — | Le doute tranche en faveur du decoupage | Les deux erreurs ne coutent pas pareil : une issue de trop se ferme, une issue fourre-tout se subit jusqu'a reecriture | Regrouper puis affiner plus tard |
| — | — | Les criteres d'acceptance sont obligatoires | Sans eux, personne ne peut affirmer qu'une issue est terminee, et la fermeture devient une opinion | Une description libre suffit |
| — | — | La creation est confirmee, contrairement a un commit | Une issue creee est publique et visible de l'equipe : l'annuler laisse une trace, ce qui n'est pas le cas d'un commit local | Creer directement |
| — | — | Un label absent est cree | Poser un label inexistant echoue silencieusement et l'issue sort non categorisee | Se limiter aux labels existants |

## Points d'entree

| Fichier | Role |
|---------|------|
| `skills/create-issue/SKILL.md` | Detection du depot, analyse de la demande, redaction, creation |
| `skills/create-issue/reference.md` | Regles de decoupage, template de corps, table des labels |

## Pieges et zones sensibles

- **Le decoupage n'est pas rejouable** : des issues creees separement ne se refusionnent pas proprement, contrairement a une issue qu'on scinde plus tard
- Le type du titre est le seul porteur du label : le changer apres coup ne met pas le label a jour
