# Pipe Spec — References

## La frontiere spec / plan

C'est la distinction qui fait toute la valeur de la spec. Une spec qui derive en plan devient obsolete au premier commit et personne ne la relit.

| | Spec (`docs/specs/`) | Plan (`.claude/plans/`) |
|---|---|---|
| **Question** | Qu'est-ce que cette feature ? Pourquoi ? | Qu'est-ce qu'on fait, dans quel ordre ? |
| **Temps** | Present — decrit ce qui est | Futur — decrit ce qu'on va ecrire |
| **Duree de vie** | Durable, versionnee dans le repo | Ephemere, gitignore, supprimee a la PR |
| **Portee** | Une feature, alimentee par N tickets | Un ticket |
| **Lecteur** | La prochaine session (humaine ou IA) qui touche la feature | La session courante |
| **Contient** | Intention, règles métier, hors-scope, decisions, points d'entrée | Étapes, fichiers a créer/modifier, signatures |

Test simple : **si une phrase devient fausse une fois le ticket merge, elle n'a rien a faire dans la spec.**

Interdits dans une spec :

- Étapes d'implementation, listes de fichiers a créer ou modifier
- Blocs de code, signatures detaillees, extraits de diff
- TODO, estimations, references au sprint ou au ticket en cours dans le corps
- Toute formulation au futur (« on va ajouter », « il faudra »)

## Template de spec

```markdown
# <Nom de la feature>

> **Statut** : active | experimentale | depreciee
> **Retrait** : 2.1.0 — raison en une ligne _(uniquement si depreciee)_

## En une phrase

Ce que la feature fait, du point de vue de celui qui l'utilise. Une phrase — c'est elle qui remonte dans l'index.

## Intention

Le problème resolu et a quoi on reconnait que c'est reussi. **3-5 lignes, en puces.**
Pas d'histoire du projet, pas de justification du besoin : le problème, point.
- Le problème que la feature resout
- Ce qui prouve que c'est reussi

## Philosophie

Le principe qui tranche les arbitrages futurs, en une puce : « ici on privilegie X sur Y ».
Si rien ne s'impose, supprimer la section — c'est le cas le plus fréquent.

## Comportement attendu

Les garanties observables, **une ligne chacune, en langage simple**. Règles métier, cas limites, comportement en erreur.
- Ce que la feature garantit, formule comme une règle

Exception au format en puces : une feature qui expose plusieurs endpoints de forme parallele (meme triptyque route / reponse / cas d'echec) se documente mieux dans un tableau `Endpoint | Reponse | Cas d'echec` — plus scannable que N puces quasi identiques. Les règles transverses aux endpoints (auth, quota) restent en puces sous le tableau.

## Hors scope

Ce que la feature ne fait **pas**, avec la raison. **Une ligne par exclusion.**
Elle evite qu'une session future « complète » la feature dans une direction ecartee volontairement.
- Ce qui est exclu — pourquoi

## Fonctionnement technique

**Le mécanisme reel**, en prose dense — jargon du projet autorise, contrairement au reste de la spec : c'est la seule section ecrite pour quelqu'un qui va toucher le code, pas pour un lecteur hors dev. **5-15 lignes.**

Alternative a la prose, quand le mécanisme est un enchainement de decisions binaires paralleles (plusieurs endpoints independants, chacun avec sa propre bifurcation) : un diagramme Mermaid (` ```mermaid flowchart TD ``` `) le montre souvent plus directement qu'un paragraphe. Si diagramme :
- Un diagramme par mécanisme independant — jamais deux branches paralleles cote a cote dans le meme diagramme, ca force un rendu large qui scroll horizontalement dans la plupart des lecteurs markdown. Enchainer les noeuds verticalement a la place
- Ne diagrammer que ce qui bifurque reellement (un code retour qui varie, par exemple) — un endpoint qui repond toujours la meme chose ne merite pas de diagramme, une phrase suffit
- Ne jamais reproduire ce que le tableau Comportement attendu dit déjà : le diagramme montre le *mécanisme* qui produit le resultat, pas le resultat lui-meme

_Les fichiers ne figurent jamais dans cette section : mentionnes en italique ou en note, discretement — liste complète dans Points d'entrée._

## Dependances

- **Internes** : autres features dont celle-ci depend → [nom-feature.md](nom-feature.md)
- **Externes** : services, APIs, librairies structurantes, schema de base
- **Dependants** : features qui reposent sur celle-ci (utile avant de la modifier)

## Decisions

Journal — on ajoute, on ne reecrit pas. Uniquement les arbitrages **non evidents**,
ceux dont on se redemandera « pourquoi comme ca ? ».

| Version | Ticket | Decision | Raison | Alternative ecartee |
|---------|--------|----------|--------|---------------------|
| 1.4.0 | PROJ-42 | ... | ... | ... |
| 1.6.0 (a venir) | PROJ-58 | ... | ... | ... |

## Points d'entrée

| Fichier | Rôle |
|---------|------|
| [reel.ts](chemin/reel.ts) | Ce qu'on y trouve, en quelques mots |

## Pieges et zones sensibles

Uniquement le **non-devinable** : ce sur quoi on se casse les dents en modifiant la feature.
Un couplage invisible, un invariant a maintenir ailleurs. Pas de conseil general.
- **Idee cle en gras** — le reste de l'explication, pour se lire en balayant
```

## Règles de rédaction

- **Budget : 40-80 lignes.** Une spec qui gonfle contient du plan, du code ou du bavardage. Couper.
- **Une info, un seul endroit.** Ne pas reformuler dans le hors-scope ce que le comportement dit déjà, ni re-expliquer dans le fonctionnement ce qui est dans l'intention. La redondance entre sections est le premier facteur de verbosite.
- **Chaque phrase gagne sa place** : elle apporte une information qu'on ne peut pas deduire du reste de la spec ni du nom de la feature. Une phrase qui « pose le contexte » sans rien apprendre se supprime.
- **Pas de paragraphes d'introduction ni de transition.** On entre directement dans le contenu de chaque section.
- **Supprimer les sections vides ou faibles** plutot que d'ecrire « N/A » ou de les meubler. Seules « En une phrase », « Comportement attendu » et « Points d'entrée » sont obligatoires.
- **Points d'entrée** : uniquement des chemins reels, vérifiés pendant l'exploration. Un chemin faux coute plus cher que pas de chemin du tout. Marquer `(a créer)` si le fichier n'existe pas encore.
- **Reference a un fichier reel** : afficher uniquement son nom, en lien markdown vers son chemin complet (`[nom.ts](../../chemin/vers/nom.ts)`) — jamais le chemin entier en texte visible, dans Points d'entrée comme ailleurs dans le corps. Le lien est relatif au fichier de la spec (`docs/specs/`), donc prefixe typiquement `../../`. Le marqueur `(a créer)` se pose juste apres le lien, jamais noye dans la colonne Rôle.
- **Pas de dates** dans le corps : git porte l'historique. Les reperes temporels utiles sont la **version** et le **ticket**, dans le journal des decisions.
- **Colonne Version du journal** : la version dans laquelle la decision est livree. Source, par ordre de priorité :
  - Le ticket parent de version lu sur le tracker, si le tracker en a
  - Sinon la version en preparation (`Unreleased` du CHANGELOG, ou version courante du projet incrementee), notee `X.Y.Z (a venir)` tant qu'elle n'est pas publiee
  - Sinon, inconnue ou projet sans versioning → `—`
  - Ne jamais deviner une version passee : une decision heritee dont on ignore l'origine prend `—`
  - Avant de reporter la version courante du projet telle quelle, vérifier qu'elle n'est pas déjà publiee (une entrée datee dans `CHANGELOG.md`, hors `[Unreleased]`) — sinon l'incrementer d'un cran
- Au moment d'une release, les entrées `(a venir)` de la version livree perdent leur mention — c'est le seul cas ou l'on modifie une ligne existante du journal.
- **Cellule Decision du journal, affirmative et sans negation** : elle dit ce qui est fait, pas ce qui ne l'est pas — l'alternative rejetee est déjà portee par la colonne Alternative ecartee. « Version lue depuis `package.json` a l'exécution » suffit ; ne pas ajouter « , pas importee comme module ».
- **Nommage du fichier** : `kebab-case` du nom de la feature, sans prefixe ni numéro de ticket — `docs/specs/export-csv.md`, jamais `spec-42.md`.
- **Une spec = une feature**, pas un module ni un ticket. Si deux specs se citent en permanence, elles n'en font probablement qu'une.
- **Dependance ajoutee entre deux specs existantes** : reporter la reference dans les deux fichiers (`Dependants` d'un cote, `Internes` ou `Dependants` de l'autre) — un couplage documente dans un seul sens se redecouvre a la dure au prochain changement de l'autre spec.

## Index — `docs/specs/README.md`

Format du tableau, section des specs depreciees et budget de la phrase de resume : `${CLAUDE_SKILL_DIR}/index-format.md` — fichier a part, car `/setup` en a besoin sans avoir besoin du reste de ce document.

## Fin de vie d'une spec

Une spec qui survit a sa feature est le pire cas de figure : elle est lue comme une reference et decrit du code qui n'existe plus. Le statut `depreciee` sert exactement a cela — encore faut-il que quelqu'un le pose.

### Quand deprecier

- La feature est **retiree du produit** (code supprime, endpoint ferme, ecran enleve)
- Elle est **remplacee** par une autre feature — la spec qui prend le relais est mentionnee dans la raison
- Elle est **fusionnee** dans une feature plus large : la spec absorbee est depreciee, celle qui absorbe est mise a jour

Ne pas deprecier une feature simplement refactorisee : le comportement subsiste, la spec reste active et ses points d'entrée sont mis a jour.

### Comment

1. Passer le statut a `depreciee` et ajouter la ligne `Retrait` : version de retrait et raison en une ligne
2. **Ne rien supprimer du corps.** L'intérêt d'une spec depreciee est de repondre a « pourquoi cette feature a existe, et pourquoi elle a disparu » — c'est ce qui evite de la reintroduire par erreur des mois plus tard
3. Deplacer sa ligne de l'index vers la section « Specs depreciees »
4. Ne jamais supprimer le fichier : git garderait la trace, mais plus personne ne la trouverait

### Effets automatiques

Une fois le statut pose, deux mécanismes s'ajustent sans intervention :

- Le hook `SessionStart` cesse d'injecter la feature : il s'arrete a la section des depreciees
- `check-specs.sh` cesse de controler ses points d'entrée — ils ont disparu par construction, les signaler eternellement serait du bruit

### Signal de detection

`check-specs.sh` distingue deux cas, et la difference porte le diagnostic :

| Constat | Interpretation | Action |
|---------|----------------|--------|
| Quelques points d'entrée morts | La spec a pris du retard | Mettre a jour les points d'entrée |
| **Tous** les points d'entrée morts | La feature n'existe plus | Deprecier — ne pas rafistoler |

La depreciation n'est **jamais** automatique : le script signale, l'humain tranche. Une feature peut avoir simplement demenage.

## Inventaire des features non specifiees

Deplace dans `${CLAUDE_SKILL_DIR}/inventaire.md` — charge par le seul mode
inventaire, qui n'a pas besoin du reste de ce fichier.

## Verification de fraicheur (utilisee par `/pipe-review`)

Deux niveaux, a ne pas confondre.

**Mecanique** — couvert par `.claude/scripts/check-specs.sh`, lance dans les checks outilles de `/pipe-review`. Un chemin mort ou une spec hors index se detectent sans jugement, donc ils ne doivent pas dependre d'un agent : points d'entrée pointant vers des fichiers disparus, spec absente de l'index.

**Au jugement** — pour chaque spec concernee par le diff :

1. Le **comportement attendu** decrit-il ce que le code fait maintenant ?
2. Le **hors scope** est-il toujours exact — n'a-t-on pas implemente ce qui en etait exclu ?
3. Les **points d'entrée** couvrent-ils les fichiers structurants **ajoutes** par le ticket ? C'est l'angle mort : un fichier neuf n'est dans aucune liste de points d'entrée, donc aucun matching exact ne le rattrape. Matcher aussi par repertoire
4. Une **decision** structurante a-t-elle ete prise pendant le dev sans être consignee ?

Tout ecart se corrige dans la spec avant de committer — la spec fait partie du changeset.
