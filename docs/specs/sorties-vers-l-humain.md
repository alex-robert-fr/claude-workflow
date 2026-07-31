# Sorties vers l'humain

> **Statut** : active
> **Tickets** : —

## En une phrase

Tout ce qu'un skill affiche — recap, rapport, question — obeit a une grammaire commune : telegraphique pour les faits acquis, developpe des qu'une decision est attendue.

## Intention

Une sortie de skill est une interface, relue a chaque invocation : la densite y a une vraie valeur. Mais compressee au-dela du point d'intelligibilite, elle coute plus cher qu'elle ne rapporte — l'utilisateur relit, redemande, ou tranche a l'aveugle. On reconnait une sortie reussie a ce qu'elle permet d'agir sans rouvrir le code ni demander de precision.

## Philosophie

On parle metier, pas fichiers : un chemin ou un nom de symbole illustre, il ne remplace jamais l'enonce du comportement en jeu. L'arbitrage densite/intelligibilite ne se rejoue pas a chaque sortie — c'est le type de sortie qui tranche.

## Comportement attendu

- Deux regimes, et le critere est unique : une sortie qui **constate** est telegraphique, une sortie qui **sollicite une decision** porte le contexte necessaire pour trancher
- Un constat tient un fait par ligne, libelle en gras puis tiret cadratin, tableau des trois colonnes de faits
- Une sollicitation enonce **une seule** decision : deux decisions cousues par un « et » font deux sollicitations
- Chaque option d'une sollicitation nomme le choix par le comportement qu'il produit, jamais par le fichier ou la couche qui l'heberge
- Chaque option enonce sa consequence — ce qui change concretement si on la retient
- Tout terme technique introduit par une sollicitation est defini a son premier usage, ou remplace par un terme metier
- Un extrait de code ou une arborescence **illustre** une sollicitation sans la porter : retire, la question reste comprehensible
- Aucune sortie ne reaffiche ce que l'utilisateur a deja sous les yeux — sortie de commande, fichier montre, recap d'une etape precedente
- Aucune phrase d'introduction ni de transition, dans les deux regimes
- Une fin d'etape tient sur une ligne : le geste suivant et la commande

## Hors scope

- Le style conversationnel hors sortie de skill — la grammaire couvre ce que les skills affichent, pas la longueur des reponses en general
- Le contenu des artefacts produits (spec, plan, commits, PR) — chacun porte son propre budget dans son skill
- Les moyens de mise en oeuvre : outil de choix multiple, gabarits imposes, script de verification relevent du plan, pas du cadrage

## Fonctionnement technique

La grammaire ne s'applique pas a l'execution mais a **l'ecriture des skills** : elle vit dans la doctrine locale du repo, et chaque skill en herite au moment ou il decrit ce qu'il affiche. Elle n'est donc pas distribuee dans le plugin — la faire porter par le prompt de chaque session reviendrait a payer une regle de conception a chaque invocation.

Les maquettes de rendu reellement variables — celles qu'un skill n'affiche que dans certains cas — vivent dans un fichier charge a la demande plutot que dans le corps du skill.

## Dependances

- **Dependants** : [`review-de-fin-de-cycle.md`](review-de-fin-de-cycle.md) et [`plan-technique-d-un-ticket.md`](plan-technique-d-un-ticket.md), dont les pauses humaines sont des sollicitations

## Decisions

| Version | Ticket | Decision | Raison | Alternative ecartee |
|---------|--------|----------|--------|---------------------|
| 1.6.3 | — | Deux regimes : constat dense, sollicitation developpee | Une densite uniforme a produit des questions cryptiques : options telegraphiques, jargon non defini, consequences absentes | Garder la densite prioritaire partout et ne corriger que les abus — le fond serait revenu |
| 1.6.3 | — | Les options d'une sollicitation se formulent en comportement | Un libelle qui nomme un fichier oblige a connaitre le code pour repondre, ce qui deplace la charge sur l'humain | Nommer la couche ou le module concerne |
| 1.6.3 | — | La spec ne prescrit aucun moyen de mise en oeuvre | Frontiere spec/plan : un outil ou un script d'apprentissage se choisit au plan et peut changer sans que la regle bouge | Engager des le cadrage un garde-fou outille |

## Points d'entree

| Fichier | Role |
|---------|------|
| `.claude/skills/create-skill/guide.md` | Section « Grammaire de sortie » : la regle, appliquee a l'ecriture de chaque skill |
| `skills/pipe-review/rendu.md` | Maquettes de constat et de sollicitation de la review |
