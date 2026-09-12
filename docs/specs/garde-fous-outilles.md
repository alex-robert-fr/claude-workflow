# Garde-fous outilles

> **Statut** : active
> **Tickets** : —

## En une phrase

Des scripts deterministes, deployes par `/setup`, qui font respecter les règles du workflow a la place d'instructions adressees au LLM.

## Intention

Une règle ecrite dans un CLAUDE.md ou un skill depend de la bonne volonte du modele : elle est suivie souvent, jamais toujours, et l'ecart ne se voit pas. Un script s'execute a chaque fois, ou echoue de facon visible.

C'est reussi quand aucune règle mecaniquement verifiable du workflow ne repose sur une instruction au LLM.

## Philosophie

Bloquer ce qui est irreversible ou faux, signaler le reste. Un garde-fou ressenti comme un frein finit desactive : la friction est un cout a arbitrer, pas une preuve de rigueur.

## Comportement attendu

- L'index des specs est present dans le contexte des le demarrage de chaque session, sans intervention
- Une commande aux degats irreversibles est refusee avant exécution, et son motif parvient a son demandeur
- Une tache declaree terminee alors que les tests echouent ne peut pas se conclure
- Un fichier ecrit est formate par l'outil du projet, jamais par le LLM
- Un ecart de cohérence des specs est signale sans interrompre le cycle
- Un garde-fou dont la dependance manque reste inerte et muet : il ne casse jamais une session
- Un garde-fou ne se declenche jamais en boucle : une relance qu'il a lui-meme provoquee le desarme
- Ce qui varie d'un projet a l'autre passe en argument — un script n'a qu'une version correcte

## Hors scope

- Le jugement de qualité — il appartient au sub-agent de `/pipe-review`, interruptible et qui rend un rapport, pas a un script qui bloque
- Tout appel reseau — une coupure ou un service lent ne doit jamais empecher de travailler
- Toute modification du code au-dela du formatage — la frontiere est ce qu'un outil deterministe reproduit a l'identique a chaque passage
- Les verifications de plus de quelques secondes — leur cout est paye a chaque ecriture ou chaque fin de tache
- La depreciation d'une spec — le script la signale, l'humain la prononce

## Fonctionnement technique

Quatre garde-fous sont declenches par un événement du harness ; un cinquieme est appele par `/pipe-review`, sans événement. Les cinq sont copies tels quels par `/setup` : leur seule variabilite passe par les arguments declares dans `settings.json`, eux-memes issus de `workflow-config`.

Le code de sortie porte tout le contrat. **Seul `exit 2` bloque**, et c'est alors **stderr** — jamais stdout — que le harness transmet a Claude. Tout autre code non nul est une erreur non bloquante : propager le code brut d'une commande de test rend donc le garde-fou inerte, une suite rouge sortant en 1.

L'injection de contexte passe par `hookSpecificOutput.additionalContext`, seul canal garanti ; un affichage en texte brut n'atteint pas le contexte.

## Dependances

- **Internes** : l'index `docs/specs/README.md`, dont dependent a la fois l'injection de contexte et le controle de cohérence
- **Externes** : `jq` ; le formateur et la commande de test du projet, quand il en a
- **Dependants** : `/setup` les deploie et verifie leurs cibles, `/pipe-review` appelle le controle de cohérence

## Decisions

| Version | Ticket | Decision | Raison | Alternative ecartee |
|---------|--------|----------|--------|---------------------|
| 1.6.0 | — | Un script est un fichier, copie a l'installation | Faire recopier du code deterministe par le LLM ajoute un risque d'echappement sans contrepartie | Blocs bash dans un markdown, recopies a chaque installation |
| 1.6.0 | — | Bloquer l'irreversible et le faux, signaler le reste | Un garde-fou ressenti comme un frein finit desactive | Bloquer a chaque ecart ; ne jamais bloquer |
| 1.6.0 | — | Dependance absente : inerte et muet, `exit 0` | Une session ne doit pas casser parce qu'un outil n'est pas installe | Prevenir au premier declenchement ; echouer bruyamment |
| 1.6.0 | — | Les extensions voyagent en liste, la regex est construite dans le script | Une regex dans une chaine JSON est un echappement invalide qui tue les quatre hooks d'un coup, en silence | Transporter la regex complète depuis `settings.json` |

## Points d'entrée

| Fichier | Rôle |
|---------|------|
| `skills/setup/SKILL.md` | Diagnostic, copie des scripts, cablage des hooks |
| `skills/setup/settings-template.json` | Les quatre hooks cables, avec leurs placeholders d'arguments |
| `skills/setup/hooks-reference.md` | Rôle de chaque garde-fou et semantique des codes de sortie |
| `skills/setup/scripts/` | Les cinq scripts, copies tels quels chez le projet |
| `.claude/scripts/check-specs.sh` | Copie deployee du controle de cohérence des specs |

## Pieges et zones sensibles

- **stdout est un canal mort sur un blocage.** Un motif ecrit sur stdout produit un refus muet — le harness repond `No stderr output` — et le demandeur retente la meme commande. Les deux garde-fous bloquants ont porte ce defaut, a deux moments differents
- **Le titre « Specs depreciees » est un contrat**, pas une convention de presentation : l'injection de contexte s'y arrete pour ne proposer que les features actives
- **Une classe de caracteres accentuee ne fonctionne pas sous `LC_ALL=C`** : `[eé]` y designe des octets, et `é` en occupe deux. Un test de depreciation ecrit ainsi echoue sans rien dire
- **Un garde-fou cable vers un script absent ne fait rien et ne dit rien** : c'est pourquoi l'existence de chaque cible se verifie au diagnostic comme apres ecriture
