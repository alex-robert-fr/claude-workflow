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

## En une phrase

Ce que la feature fait, du point de vue de celui qui l'utilise. Une phrase — c'est elle qui remonte dans l'index.

## Intention

Le probleme resolu et a quoi on reconnait que c'est reussi. **3-5 lignes.**
Pas d'histoire du projet, pas de justification du besoin : le probleme, point.

## Philosophie

Le principe qui tranche les arbitrages futurs : « ici on privilegie X sur Y ». **2-3 lignes.**
Si rien ne s'impose, supprimer la section — c'est le cas le plus frequent.

## Comportement attendu

Les garanties observables, **une ligne chacune**. Regles metier, cas limites, comportement en erreur.
- Ce que la feature garantit, formule comme une regle

## Hors scope

Ce que la feature ne fait **pas**, avec la raison. **Une ligne par exclusion.**
Elle evite qu'une session future « complete » la feature dans une direction ecartee volontairement.
- Ce qui est exclu — pourquoi

## Fonctionnement technique

Flux principal, ou vit l'etat, ce qui declenche quoi. **5-10 lignes.**
Assez pour comprendre sans ouvrir le code, jamais au niveau de la ligne de code.

## Dependances

- **Internes** : autres features dont celle-ci depend → lien vers leur spec
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
| `chemin/reel.ts` | Ce qu'on y trouve, en quelques mots |

## Pieges et zones sensibles

Uniquement le **non-devinable** : ce sur quoi on se casse les dents en modifiant la feature.
Un couplage invisible, un invariant a maintenir ailleurs. Pas de conseil general.
```

## Regles de redaction

- **Budget : 40-80 lignes.** Une spec qui gonfle contient du plan, du code ou du bavardage. Couper.
- **Une info, un seul endroit.** Ne pas reformuler dans le hors-scope ce que le comportement dit deja, ni re-expliquer dans le fonctionnement technique ce qui est dans l'intention. La redondance entre sections est le premier facteur de verbosite.
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

Point d'entree unique : c'est le seul fichier a charger pour savoir quelles features existent et laquelle ouvrir.

```markdown
# Specs

Une spec par feature : ce qu'elle est, ce qu'on en attend, son perimetre et ses points
d'entree techniques. A lire avant de modifier une feature — c'est le contexte de reference.

Ecrites et maintenues par `/pipe-spec`, verifiees a chaque `/pipe-review`.

| Feature | Spec | En une phrase |
|---------|------|---------------|
| Export CSV | [`export-csv.md`](export-csv.md) | Resume issu de la section « En une phrase » |
```

Regles :

- Trie les lignes par ordre alphabetique de feature
- La colonne « En une phrase » reprend mot pour mot la section correspondante de la spec
- Une spec `depreciee` reste dans l'index, avec la mention dans sa colonne feature

## Inventaire des features non specifiees

Methode du mode inventaire de `/pipe-spec` (appel sans argument), pour amorcer un projet dont les features existent deja.

### 1. Reperer les features candidates

Croise trois sources, dans cet ordre :

- **La structure du code** : les repertoires de premier et second niveau sous la racine de code (`src/`, `app/`, `packages/`...). Un module = souvent une feature
- **Les points d'entree utilisateur** : routes, commandes CLI, ecrans, handlers, jobs — ce que le produit expose
- **Le CLAUDE.md et le README** : ils nomment deja les features importantes, dans le vocabulaire du projet

Retiens le **vocabulaire metier**, pas les noms techniques : la feature s'appelle « export CSV », pas `CsvExportService`.

### 2. Prioriser par valeur

Le critere : **une spec rapporte proportionnellement au nombre de fois ou on rouvrira la feature**. Le passe le predit — les zones les plus modifiees sont celles qu'on relira le plus.

```bash
git log --since="12 months ago" --name-only --pretty=format: -- <racine-de-code> \
  | grep -v '^$' \
  | awk -F/ '{print $1"/"$2}' \
  | sort | uniq -c | sort -rn | head -20
```

Adapter la profondeur de l'`awk` a l'arborescence (`$1"/"$2"/"$3` sur un monorepo). Restreindre le pathspec a la racine de code : sans cela, `CHANGELOG.md`, les manifestes et les fichiers de config saturent le haut du classement sans etre des features.

Trois signaux ponderent ce classement :

- **Volume de code** : une feature d'un seul fichier trivial ne merite pas de spec
- **Complexite du metier** : les regles implicites, les cas limites nombreux, les arbitrages passes — c'est la que la spec fait gagner le plus
- **Ce que l'utilisateur sait encore** : une feature ecrite il y a deux ans dont personne ne se rappelle le pourquoi produira une spec creuse ; preferer celles dont l'intention est encore fraiche

### 3. Presenter le classement

| # | Feature | Repertoire | Modifs (12 mois) | Pourquoi maintenant |
|---|---------|------------|------------------|---------------------|
| 1 | Export CSV | `src/export/` | 38 | Zone la plus retouchee, regles metier implicites |

Exclure les features deja presentes dans `docs/specs/README.md`. Si toutes le sont, le dire en une ligne : le rattrapage est termine.

Terminer par le compte : combien de features reperees, combien deja specifiees, combien restent.

## Verification de fraicheur (utilisee par `/pipe-review`)

Une spec qui ment est pire que pas de spec. A chaque review, pour chaque spec dont un point d'entree apparait dans le diff :

1. Le **comportement attendu** decrit-il ce que le code fait maintenant ?
2. Le **hors scope** est-il toujours exact — n'a-t-on pas implemente ce qui en etait exclu ?
3. Les **points d'entree** couvrent-ils les nouveaux fichiers structurants de la feature ?
4. Une **decision** structurante a-t-elle ete prise pendant le dev sans etre consignee ?

Tout ecart se corrige dans la spec avant de committer — la spec fait partie du changeset.
