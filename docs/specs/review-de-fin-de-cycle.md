# Review de fin de cycle

> **Statut** : active
> **Tickets** : —

## En une phrase

Le dernier filtre avant le commit : outils mecaniques, agent isole, relecture humaine, puis fraicheur de la spec.

## Intention

Un diff relu par celui qui vient de l'ecrire ne rencontre que ses propres angles morts. Et une relecture humaine qui commence par des ecarts de formatage s'epuise avant d'atteindre le fond.

Reussi quand rien de bloquant n'atteint la PR, et que l'humain n'arbitre que ce qui merite un arbitrage.

## Philosophie

**Quatre filtres de nature differente, jamais interchangeables.** Ce qu'un outil tranche, un agent ne le discute pas ; ce qu'un agent constate, seul l'humain le decide. Confondre les niveaux produit du bruit a un bout et des trous a l'autre.

## Comportement attendu

- Rien a reviewer (aucune avance sur la branche par defaut, working tree propre) → arret annonce
- Le formatage s'applique, le lint et les tests passent, avant toute review de fond
- Un test valide n'est jamais modifie pour faire passer une suite : le suspecter arrete la review
- Trois tentatives de correction au plus sur un echec outille, puis arret avec le detail de ce qui a ete tente
- Une commande absente de la configuration est signalee en une ligne et ne bloque pas
- La review de fond s'execute dans un contexte isole et ne remonte que ses constats
- Un rapport sans constat est un resultat valide, pas un echec de la review
- Chaque constat porte de quoi decider sans ouvrir le code : situation, conséquence observable, cause, correction
- Aucune correction n'est appliquee sans validation explicite, un constat bloquant ignore est signale comme tel
- Les specs concernees sont verifiees une fois le code fige, et corrigees dans le meme changeset
- Une feature dont tous les points d'entrée ont disparu est proposee a la depreciation, jamais depreciee d'office

## Hors scope

- Le style et le formatage — les outils tranchent, un avis d'agent dessus est du bruit
- La review de la Pull Request sur la plateforme — celle-ci la precede, elle ne la remplace pas
- Bloquer sur un ecart de spec — il se corrige a l'étape prévue, pas au controle outille
- Reviewer un travail déjà merge — le perimetre est la branche courante face a la branche par defaut

## Fonctionnement technique

Le contexte principal reste volontairement leger : il doit encore porter la relecture humaine, la fraicheur des specs, puis le decoupage en commits et la Pull Request dans la meme session. Il ne collecte donc que le diff et la liste des fichiers, jamais leur contenu.

Le sous-agent, lui, lit chaque fichier modifie en entier dans son propre contexte, et rend des constats a champs fixes. Son protocole vit dans un fichier que le principal ne charge jamais. Les maquettes d'affichage sont chargées a la demande, seulement si au moins un constat existe.

Les specs concernees sont identifiees en croisant quatre sources : points d'entrée presents dans le diff, points d'entrée partageant un repertoire avec un fichier du diff, spec liee au pilotage, et ecarts remontes par le controle outille.

## Dependances

- **Internes** : [`fichier-de-pilotage.md`](fichier-de-pilotage.md) pour la phase, la branche et le plan ; [`cycle-de-vie-d-une-spec.md`](cycle-de-vie-d-une-spec.md) pour la verification de fraicheur et la depreciation ; [`garde-fous-outilles.md`](garde-fous-outilles.md) pour le controle de cohérence des specs ; la configuration du projet pour les commandes
- **Externes** : les outils de formatage, de lint et de test du projet ; un sous-agent de type generaliste
- **Dependants** : [`livraison-git.md`](livraison-git.md), qui ne decoupe qu'un code valide

## Decisions

| Version | Ticket | Decision | Raison | Alternative ecartee |
|---------|--------|----------|--------|---------------------|
| — | — | La review de fond tourne en sous-agent | Lire chaque fichier modifie en entier saturerait le contexte qui doit encore porter la relecture humaine, les specs, les commits et la PR | Reviewer dans le contexte principal |
| — | — | Trois champs d'un constat s'ecrivent sans nom de symbole | Un constat qu'il faut lire le code pour comprendre ne permet pas de decider s'il vaut une correction | Un rapport technique unique |
| — | — | La fraicheur de la spec passe apres le figeage du code | La vérifier avant, c'est vérifier un etat qui va encore changer pendant la relecture humaine | En debut de review |
| — | — | Les specs concernees sont croisees par repertoire, pas seulement par point d'entrée | Un fichier neuf ne figure dans aucune liste de points d'entrée — precisement le cas ou la spec devient fausse | Correspondance exacte des chemins |

## Points d'entrée

| Fichier | Rôle |
|---------|------|
| `skills/pipe-review/SKILL.md` | Enchainement des quatre filtres, collecte du contexte, fraicheur |
| `skills/pipe-review/reference.md` | Protocole du reviewer — charge par le sous-agent seul |
| `skills/pipe-review/rendu.md` | Maquettes du rapport et du Question/Reponse — charge s'il y a un constat |
| `skills/setup/scripts/check-specs.sh` | Controle mecanique de cohérence des specs |

## Pieges et zones sensibles

- **Le protocole du reviewer ne doit jamais être charge dans le contexte principal** : c'est sa taille qui justifie le sous-agent, l'y ramener annule le gain
- **Un statut sans constat n'a pas besoin des maquettes** : les charger quand meme paie un cout pour rien
- **Le croisement par repertoire est le seul filet des fichiers ajoutes** : le retirer rend la verification de fraicheur aveugle aux creations
- Au-dela de trois tentatives sur un echec de test, la faute est plus souvent dans le test que dans le code — insister revient a modifier le contrat
