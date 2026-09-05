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
| **Contient** | Intention, regles metier, hors-scope, decisions, points d'entree | Etapes, fichiers a creer/modifier, signatures |

Test simple : **si une phrase devient fausse une fois le ticket merge, elle n'a rien a faire dans la spec.**

Interdits dans une spec :

- Etapes d'implementation, listes de fichiers a creer ou modifier
- Blocs de code, signatures detaillees, extraits de diff
- TODO, estimations, references au sprint ou au ticket en cours dans le corps
- Toute formulation au futur (« on va ajouter », « il faudra »)

## Template de spec

```markdown
# <Nom de la feature>

> **Statut** : active | experimentale | depreciee
> **Tickets** : PROJ-42, PROJ-58
> **Retrait** : 2.1.0 — raison en une ligne _(uniquement si depreciee)_

## En une phrase

Ce que la feature fait, du point de vue de celui qui l'utilise. Une phrase — c'est elle qui remonte dans l'index.

## Intention

Le probleme resolu et a quoi on reconnait que c'est reussi. **3-5 lignes, en puces.**
Pas d'histoire du projet, pas de justification du besoin : le probleme, point.
- Le probleme que la feature resout
- Ce qui prouve que c'est reussi

## Philosophie

Le principe qui tranche les arbitrages futurs, en une puce : « ici on privilegie X sur Y ».
Si rien ne s'impose, supprimer la section — c'est le cas le plus frequent.

## Comportement attendu

Les garanties observables, **une ligne chacune, en langage simple**. Regles metier, cas limites, comportement en erreur.
- Ce que la feature garantit, formule comme une regle

## Hors scope

Ce que la feature ne fait **pas**, avec la raison. **Une ligne par exclusion.**
Elle evite qu'une session future « complete » la feature dans une direction ecartee volontairement.
- Ce qui est exclu — pourquoi

## Fonctionnement

**Un schema du mecanisme**, fait de questions oui/non enchainees, en langage naturel — comme on l'expliquerait a quelqu'un hors dev, sans jargon technique. **5-10 lignes.**

- **Question oui/non, en gras ?**
  - Oui → consequence, ou question suivante
  - Non → consequence, ou question suivante
- **Question suivante, en gras ?**
  - Oui → consequence
  - Non → consequence

_Les fichiers ne figurent jamais dans le schema : mentionnes ici en italique, discretement — liste complete dans Points d'entree._

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

## Points d'entree

| Fichier | Role |
|---------|------|
| [reel.ts](chemin/reel.ts) | Ce qu'on y trouve, en quelques mots |

## Pieges et zones sensibles

Uniquement le **non-devinable** : ce sur quoi on se casse les dents en modifiant la feature.
Un couplage invisible, un invariant a maintenir ailleurs. Pas de conseil general.
- **Idee cle en gras** — le reste de l'explication, pour se lire en balayant
```

## Regles de redaction

- **Budget : 40-80 lignes.** Une spec qui gonfle contient du plan, du code ou du bavardage. Couper.
- **Une info, un seul endroit.** Ne pas reformuler dans le hors-scope ce que le comportement dit deja, ni re-expliquer dans le fonctionnement ce qui est dans l'intention. La redondance entre sections est le premier facteur de verbosite.
- **Chaque phrase gagne sa place** : elle apporte une information qu'on ne peut pas deduire du reste de la spec ni du nom de la feature. Une phrase qui « pose le contexte » sans rien apprendre se supprime.
- **Pas de paragraphes d'introduction ni de transition.** On entre directement dans le contenu de chaque section.
- **Supprimer les sections vides ou faibles** plutot que d'ecrire « N/A » ou de les meubler. Seules « En une phrase », « Comportement attendu » et « Points d'entree » sont obligatoires.
- **Points d'entree** : uniquement des chemins reels, verifies pendant l'exploration. Un chemin faux coute plus cher que pas de chemin du tout. Marquer `(a creer)` si le fichier n'existe pas encore.
- **Pas de dates** dans le corps : git porte l'historique. Les reperes temporels utiles sont la **version** et le **ticket**, dans le journal des decisions.
- **Colonne Version du journal** : la version dans laquelle la decision est livree. Source, par ordre de priorite — la « Version cible » du pilotage, sinon la version en preparation (`Unreleased` du CHANGELOG, ou version courante du projet incrementee), notee `X.Y.Z (a venir)` tant qu'elle n'est pas publiee. Inconnue ou projet sans versioning → `—`. Ne jamais deviner une version passee : une decision heritee dont on ignore l'origine prend `—`.
- Au moment d'une release, les entrees `(a venir)` de la version livree perdent leur mention — c'est le seul cas ou l'on modifie une ligne existante du journal.
- **Nommage du fichier** : `kebab-case` du nom de la feature, sans prefixe ni numero de ticket — `docs/specs/export-csv.md`, jamais `spec-42.md`.
- **Une spec = une feature**, pas un module ni un ticket. Si deux specs se citent en permanence, elles n'en font probablement qu'une.

## Index — `docs/specs/README.md`

Format du tableau, section des specs depreciees et budget de la phrase de resume : `${CLAUDE_SKILL_DIR}/index-format.md` — fichier a part, car `/setup` en a besoin sans avoir besoin du reste de ce document.

## Fin de vie d'une spec

Une spec qui survit a sa feature est le pire cas de figure : elle est lue comme une reference et decrit du code qui n'existe plus. Le statut `depreciee` sert exactement a cela — encore faut-il que quelqu'un le pose.

### Quand deprecier

- La feature est **retiree du produit** (code supprime, endpoint ferme, ecran enleve)
- Elle est **remplacee** par une autre feature — la spec qui prend le relais est mentionnee dans la raison
- Elle est **fusionnee** dans une feature plus large : la spec absorbee est depreciee, celle qui absorbe est mise a jour

Ne pas deprecier une feature simplement refactorisee : le comportement subsiste, la spec reste active et ses points d'entree sont mis a jour.

### Comment

1. Passer le statut a `depreciee` et ajouter la ligne `Retrait` : version de retrait et raison en une ligne
2. **Ne rien supprimer du corps.** L'interet d'une spec depreciee est de repondre a « pourquoi cette feature a existe, et pourquoi elle a disparu » — c'est ce qui evite de la reintroduire par erreur des mois plus tard
3. Deplacer sa ligne de l'index vers la section « Specs depreciees »
4. Ne jamais supprimer le fichier : git garderait la trace, mais plus personne ne la trouverait

### Effets automatiques

Une fois le statut pose, deux mecanismes s'ajustent sans intervention :

- Le hook `SessionStart` cesse d'injecter la feature : il s'arrete a la section des depreciees
- `check-specs.sh` cesse de controler ses points d'entree — ils ont disparu par construction, les signaler eternellement serait du bruit

### Signal de detection

`check-specs.sh` distingue deux cas, et la difference porte le diagnostic :

| Constat | Interpretation | Action |
|---------|----------------|--------|
| Quelques points d'entree morts | La spec a pris du retard | Mettre a jour les points d'entree |
| **Tous** les points d'entree morts | La feature n'existe plus | Deprecier — ne pas rafistoler |

La depreciation n'est **jamais** automatique : le script signale, l'humain tranche. Une feature peut avoir simplement demenage.

## Inventaire des features non specifiees

Deplace dans `${CLAUDE_SKILL_DIR}/inventaire.md` — charge par le seul mode
inventaire, qui n'a pas besoin du reste de ce fichier.

## Verification de fraicheur (utilisee par `/pipe-review`)

Une spec qui ment est pire que pas de spec : elle est lue comme une reference.

Deux niveaux, a ne pas confondre.

**Mecanique** — couvert par `.claude/scripts/check-specs.sh`, lance dans les checks outilles de `/pipe-review`. Un chemin mort ou une spec hors index se detectent sans jugement, donc ils ne doivent pas dependre d'un agent : points d'entree pointant vers des fichiers disparus, spec absente de l'index.

**Au jugement** — pour chaque spec concernee par le diff :

1. Le **comportement attendu** decrit-il ce que le code fait maintenant ?
2. Le **hors scope** est-il toujours exact — n'a-t-on pas implemente ce qui en etait exclu ?
3. Les **points d'entree** couvrent-ils les fichiers structurants **ajoutes** par le ticket ? C'est l'angle mort : un fichier neuf n'est dans aucune liste de points d'entree, donc aucun matching exact ne le rattrape. Matcher aussi par repertoire
4. Une **decision** structurante a-t-elle ete prise pendant le dev sans etre consignee ?

Tout ecart se corrige dans la spec avant de committer — la spec fait partie du changeset.
