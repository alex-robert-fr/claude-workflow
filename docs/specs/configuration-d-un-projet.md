# Configuration d'un projet

> **Statut** : active
> **Tickets** : —

## En une phrase

Rendre un projet capable de suivre le workflow : diagnostic de ce qui manque, puis installation de ce qui manque seulement.

## Intention

Le pipeline suppose partout les memes points d'appui : une configuration projet, des repertoires, des scripts executables, un index de specs. Les recreer a la main sur chaque projet garantit des variantes silencieuses — et une variante silencieuse dans un garde-fou est un garde-fou absent.

Reussi quand un projet neuf et un projet configure par une version anterieure aboutissent au meme etat, sans que rien de deja adapte soit ecrase.

## Philosophie

**Diagnostiquer, proposer, n'ecrire que le manquant.** L'installation est reprenable autant de fois que necessaire ; ce qui existe deja et differe de la source appartient au projet, pas a l'outil.

## Comportement attendu

- Le diagnostic precede toute ecriture et son resultat est presente avant confirmation
- Chaque type de garde-fou est diagnostique separement : un projet configure par une version anterieure en a certains et pas d'autres
- Un garde-fou declare mais cable vers un fichier absent ou non executable compte comme manquant
- Un fichier existant identique a la source est laisse tel quel ; different, il est signale et son ecrasement demande
- Les scripts sans variable projet sont copies, jamais reecrits — ce qui varie passe en argument
- Les valeurs de configuration sont d'abord detectees depuis le projet, proposees, puis confirmees, jamais devinees en silence
- Un champ deja rempli n'est jamais retouche ; seuls les emplacements a completer sont questionnes
- Le repertoire des documents de pilotage est ignore par git, celui des specs est versionne
- L'index des specs est cree vide : aucune spec n'est ecrite ici
- Un projet ayant deja des features livrees recoit le signal de rattrapage des specs
- Un outil systeme requis absent est signale, et l'installation se poursuit

## Hors scope

- Ecrire une spec — chacune exige un cadrage avec l'utilisateur, l'installation ne peut pas le simuler
- Installer les dependances du projet ou ses outils de qualite — la configuration les declare, elle ne les fournit pas
- Migrer le code du projet vers une convention — seule la configuration legacy connue est proposee a la fusion
- Se declencher toute seule : c'est un geste explicite, jamais une consequence d'une autre commande

## Fonctionnement technique

Cinq temps : diagnostic, instructions permanentes du projet, configuration du workflow, garde-fous, repertoires. Chaque temps ne traite que ses manques.

La configuration du workflow est la source unique : plateforme, tracker, branche par defaut, branche de production, commandes de qualite, stack. Tout le reste la lit — les garde-fous recoivent ses valeurs en arguments, les skills du pipeline la chargent au demarrage.

Le declenchement des garde-fous par evenement, leur cablage et leurs arguments sont decrits dans [`garde-fous-outilles.md`](garde-fous-outilles.md) ; ici n'est traite que leur installation.

## Dependances

- **Internes** : [`garde-fous-outilles.md`](garde-fous-outilles.md) fournit les scripts a copier ; [`cycle-de-vie-d-une-spec.md`](cycle-de-vie-d-une-spec.md) fournit le format de l'index ; [`livraison-git.md`](livraison-git.md) fournit les conventions reprises dans les instructions permanentes
- **Externes** : `git` pour la detection du remote et de la branche par defaut ; `jq` pour le controle du cablage ; les manifestes du projet pour la detection de stack
- **Dependants** : tout le pipeline, qui suppose la configuration du workflow presente

## Decisions

| Version | Ticket | Decision | Raison | Alternative ecartee |
|---------|--------|----------|--------|---------------------|
| — | — | Les scripts sont copies depuis une source unique | Faire recopier un script deterministe par le modele expose a une erreur d'echappement pour aucun gain | Les inscrire dans le markdown du skill |
| — | — | Ce qui varie par projet passe en argument, jamais dans le corps du script | Une seule version du script reste donc correcte partout, et sa mise a jour ne repasse pas par une reecriture | Generer un script par projet |
| — | — | La configuration du workflow est retiree du catalogue du modele | Sa description etait payee dans chaque session alors qu'elle n'est jamais invoquee, seulement lue | La laisser invocable |
| — | — | Un garde-fou cable vers un script absent compte comme manquant | Il ne signale rien : le declarer sans le fournir donne l'apparence d'une protection sans la protection | Ne verifier que la declaration |
| — | — | L'installation ne cree aucune spec | Une spec ecrite sans arbitrage humain est une documentation inventee, et elle sera lue comme une reference | Generer un premier jet par feature detectee |

## Points d'entree

| Fichier | Role |
|---------|------|
| `skills/setup/SKILL.md` | Diagnostic, questions, installation, recapitulatif |
| `skills/setup/workflow-config-template.md` | Squelette de la configuration projet |
| `skills/setup/settings-template.json` | Cablage des garde-fous et emplacements des arguments |
| `skills/setup/hooks-reference.md` | Semantique des evenements et valeurs par stack |

## Pieges et zones sensibles

- **Le controle de cablage est le seul filet contre une protection fantome** : un garde-fou declare mais absent echoue sans rien dire, et le formatage automatique disparait en silence
- **Le signal de rattrapage des specs n'est emis qu'ici, une seule fois** : rien d'autre dans le pipeline ne rappelle les features non specifiees
- Le garde-fou de session est inerte tant qu'aucun index de spec n'existe : il doit etre installe quand meme, sinon il faut y repenser plus tard
- Un emplacement a completer laisse dans un fichier ecrit rend ce fichier faux sans le rendre invalide : leur absence se verifie apres ecriture
