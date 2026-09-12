# Pipe Changelog — Referentiel de conventions

## Standard de reference

**[Keep a Changelog](https://keepachangelog.com/en/1.1.0/)** + **[Semantic Versioning](https://semver.org/spec/v2.0.0.html)**

## Repartition CHANGELOG / commits

Le CHANGELOG et l'historique git se partagent le travail :

| Question du lecteur | Ou est la reponse |
|---|---|
| Qu'est-ce qui change pour moi ? | CHANGELOG — une phrase courte par changement |
| Dois-je adapter mon code / mon deploiement ? | CHANGELOG — `**BREAKING**`, notes de deploiement |
| Comment c'est implemente, et pourquoi comme ca ? | Corps du commit ou de la PR, via la reference en fin d'entrée |
| Qu'est-ce qui a change en interne (refactor, tests, CI, deps) ? | Historique git uniquement — pas d'entrée CHANGELOG |

Conséquence : **pas de fichier technique separe** (`TECHNICAL_CHANGES.md` ou equivalent). Un tel fichier duplique l'historique git, coute de la maintenance et derive. Si un projet en possède un, proposer sa suppression.

Ce partage ne fonctionne que si les corps de commits sont reellement rediges — voir `git-conventions` (section Body) : tout commit non trivial documente ses decisions techniques dans son corps.

## Structure globale du CHANGELOG

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Les details techniques de chaque changement sont documentes dans les commits et pull requests lies.

## [Unreleased]

## [1.2.0](https://github.com/org/repo/releases/tag/v1.2.0) - 2026-03-29
## [1.1.0](https://github.com/org/repo/releases/tag/v1.1.0) - 2026-02-14
## [1.0.0](https://github.com/org/repo/releases/tag/v1.0.0) - 2026-01-01

[Unreleased]: https://github.com/org/repo/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/org/repo/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/org/repo/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/org/repo/releases/tag/v1.0.0
```

## Types d'entrées (ordre impose)

Les types doivent toujours apparaitre dans cet ordre. Ne pas inclure les types sans entrées.

| Type | Usage |
|---|---|
| `Added` | Nouvelle fonctionnalité |
| `Changed` | Modification de comportement existant |
| `Deprecated` | Fonctionnalité vouee a être supprimee |
| `Removed` | Suppression definitive |
| `Fixed` | Correction de bug |
| `Security` | Patch de sécurité |

Pas de types custom (`Improved`, `Refactored`, `Chore`, etc.).

## Mapping prefixe de commit → type

| Prefixe commit | Defaut | Exception |
|---|---|---|
| `feat` | `Added` | `Removed` si suppression explicite, `Deprecated` si deprecation |
| `fix` | `Fixed` | `Security` si patch de sécurité |
| `perf` | `Changed` | — |
| `refactor` | **exclu** | `Changed` si l'API publique change |
| `docs` | **exclu** | `Added`/`Changed` si doc user-facing (README public, doc d'API consommee) |
| `chore` | **exclu** | `Changed` si config publique ou variable d'environnement requise (note de deploiement) |
| `test` | **exclu** | — |

Un commit exclu n'est pas perdu : il reste dans l'historique git, avec son corps comme documentation. En cas de doute entre exclure et inclure, exclure et demander confirmation.

Cas speciaux (detectes par le contenu du commit, pas par le prefixe seul) :
- Suppression explicite d'une fonctionnalité → `Removed`
- Deprecation explicite → `Deprecated`
- Patch de sécurité → `Security`
- Breaking change → prefixer l'entrée par `**BREAKING**`

## Règles de contenu

- Une entrée = **une phrase courte** decrivant un effet observable. Pas de detail d'implementation — le lecteur qui veut le detail suit la reference vers le commit ou la PR.
- Redigee pour le lecteur qui consomme le projet, pas pour le dev qui l'a ecrit
- Chaque entrée tient sur **une seule ligne** — pas de retour a la ligne manuel au milieu d'une phrase. Les editeurs gerent le wrap, pas l'auteur.
- Chaque entrée inclut ses references tracables en fin de ligne (voir section "References dans les entrées")
- Breaking changes marques : `**BREAKING**` en prefixe de l'entrée
- Ne jamais copier les messages de commit verbatim — reformuler pour le consommateur

## Rediger pour le consommateur

### Règles de rédaction

Checklist a appliquer a chaque entrée avant de la valider :

1. **Ecrire pour le consommateur, pas pour le dev** — decrire l'effet observable cote utilisateur (endpoint, option, comportement), pas l'implementation interne (decorateur, hook, refactor).
2. **Verbe a la voix active, au present** — `Ajoute`, `Corrige`, `Supprime`, `Renvoie`, `Inclut`. Pas `a ete ajoute`, pas `ajout de`, pas de formulation nominale.
3. **Court** — une phrase. Si l'entrée depasse deux lignes affichees, elle porte du detail qui appartient au corps du commit.
4. **Preciser la feature publique impactee** — nom de l'endpoint, du parametre, de l'option ou du fichier de config concerne, entre backticks. Les valeurs actionnables restent explicites ("minimum 12 caracteres", pas "politique renforcee") tant que la phrase reste courte.
5. **Marquer explicitement les breaking changes** — prefixe `**BREAKING**` en debut d'entrée, avec mention de la migration requise.

### Template mental

```
[Verbe actif present] [feature publique] [effet visible utilisateur]
```

Exemple d'application :

> Ajoute le filtre `?type=base|composed` sur `GET /recipes` pour limiter les resultats par catégorie.

### Principes

1. **Fusionner les entrées liees** — les commits/PRs qui composent **le meme événement vu du consommateur** donnent une seule entrée, avec plusieurs references si nécessaire :
   - ✅ **Fusion OK** : page de connexion + protection des routes + redirection a l'expiration de session → un seul événement "authentification", une entrée.
   - ❌ **Fusion abusive** : nouveau champ obligatoire + nouveau filtre + nouvel endpoint → autant d'informations user-facing distinctes, chacune sa propre entrée. La règle : si le lecteur peut consommer un aspect sans connaitre les autres, il merite sa propre ligne.
2. **Indiquer l'impact client quand il existe** — si le consommateur doit adapter son code (headers, options fetch, configuration), le dire explicitement dans l'entrée.

### Avant / apres

```
❌ Ajout du decorateur @Public() et desactivation du guard JWT sur les GET
✅ Expose les endpoints `GET` des ressources métier publiquement, sans authentification requise

❌ Ajoute le champ optionnel `source_url` sur `POST /recipes` et `PATCH /recipes/:id` — un lien `http`/`https` cliquable pour la source, expose dans `GET /recipes/:id` ; il exige un libelle `source` non vide, sinon `400 Bad Request`
✅ Ajoute un lien de source optionnel (`source_url`) sur les recettes
   (les contraintes de validation vivent dans le corps du commit lie)

❌ Refactor de find_by_email pour masquer l'existence des comptes
✅ Renvoie 404 au lieu de 403 lors de la consultation d'une recette privee sans autorisation, pour ne pas divulguer son existence
```

#### Decoupage : plusieurs aspects user-facing distincts

```
❌ Ajout du champ `type` obligatoire sur POST, nouveau filtre `?type=` sur GET, nouvel endpoint `PATCH /pricing` et inclusion de `pricing` dans `GET /:id` (1 entrée fourre-tout)

✅ 3 entrées distinctes :
   - **BREAKING** — Rend le champ `type` obligatoire sur `POST /recipes` (`'base'` ou `'composed'`)
   - Ajoute le filtre `?type=base|composed` sur `GET /recipes`
   - Pricing des recettes : consultation dans le detail et mise a jour dediee ([#108], [#110])
```

### Consolider en etat final

Quand plusieurs commits successifs touchent le **meme artefact** (fichier, endpoint, fonction publique, option de config...) **au sein de la meme release**, n'ecrire qu'une seule entrée decrivant l'**etat final** du point de vue du consommateur. Les etats intermediaires n'ont jamais ete livres, ils ne doivent pas apparaitre.

Le scope est la release en cours (`[Unreleased]` ou la section en preparation), jamais entre deux versions déjà taggees.

Cas typiques :

- **Ajout puis suppression** dans la meme release → ne rien ecrire (l'artefact n'a jamais existe pour le consommateur)
- **Ajout puis renommage/deplacement** dans la meme release → une seule entrée avec le nom final
- **Modification puis re-modification** successive → une seule entrée decrivant le comportement final

Distinction avec le principe #1 (fusion vs decoupage) : le principe #1 traite les **aspects distincts simultanes** (a decouper si independants). La consolidation traite les **successions sur le meme artefact** (a fusionner sur l'etat final). Les deux sont compatibles.

En cas de doute sur la detection d'une succession (chemin renomme, identifiant ambigu), demander confirmation a l'utilisateur plutot que de consolider silencieusement.

### Heuristique rapide

Si l'entrée reformulee ne permet **pas** a un consommateur de repondre a l'une de ces questions, elle manque de contenu :

- Qu'est-ce qui change concretement pour moi ?
- Est-ce que je dois adapter mon code ?

Et dans l'autre sens : si l'entrée explique **comment** le changement est implemente, elle en dit trop — ce detail appartient au corps du commit.

## Notes de deploiement

Le CHANGELOG est court, mais tout ce qui est **actionnable au deploiement** doit y rester — celui qui deploie ne fouille pas les commits pour decouvrir que son deploiement va casser :

- **Breaking change de release** : si la release entiere impose une migration (changement de contrat d'API, format de donnees), la remonter en blockquote juste sous l'en-tete de version, avant les sections de types :

  ```markdown
  ## [0.3.0] - 2026-07-07

  > **BREAKING** : le format des recettes change — le tableau `ingredients` devient `lines`. Les clients doivent adapter leurs requetes ([`77e733e`](url/commit/77e733e))
  ```

- **Variable d'environnement requise** : une entrée `Changed` ou `Security` qui nomme la variable et la conséquence ("`CORS_ORIGIN` est obligatoire au demarrage").
- **Dependance inter-services** : quand une version consomme un nouveau contrat d'un service partenaire, une blockquote sous l'en-tete de version du type `> Requiert [backend-index](url) ≥ 0.3.2 (colonne \`source_url\` dans l'import CSV)`.

## Cohérence versions/dates

Une entrée placee sous une section versionnee `[X.Y.Z] - YYYY-MM-DD` doit correspondre a un commit (ou a une PR) **mergee avant la date du tag**. Un changement introduit apres la date de release appartient a `[Unreleased]`, jamais a une version déjà publiee.

### Verification

Lors de la generation ou de l'audit d'un CHANGELOG existant :

1. Récupérer la date de chaque tag versionne : `git log -1 --format=%aI v<X.Y.Z>`.
2. Pour chaque PR referencee dans une section versionnee, comparer sa date de merge avec la date du tag : `gh pr view <N> --json mergedAt --jq .mergedAt`.
3. Pour les entrées referencees par SHA, utiliser la date du commit : `git log -1 --format=%aI <sha>`.
4. Si la reference est **posterieure** a la date du tag, deplacer l'entrée vers `[Unreleased]`.

Cas typique : un CHANGELOG créé tardivement apres un premier tag, qui a absorbe par erreur des changements merges plus tard. Le declenchement de cet audit est decide par le skill (étape 2.5), pas ici.

## References dans les entrées

Chaque entrée de changelog inclut une reference tracable entre parentheses en fin de ligne. C'est le pont vers le detail technique : le corps du commit ou la PR documente l'implementation que le CHANGELOG ne porte plus.

### Règle

- **Si une PR existe** : lier la PR. C'est la reference principale — elle contient le contexte, les commits et les issues liees.
- **Si pas de PR** (commit direct) : lier le SHA court en fallback.
- Une entrée fusionnee (plusieurs commits pour le meme événement consommateur) peut porter plusieurs references, séparées par des virgules.

### Format

```
- Texte reformule ([#N](url))
- Texte d'une entrée fusionnee ([#N](url), [`abc1234`](url/commit/abc1234))
```

**Important** : GitHub n'auto-link pas les references dans les fichiers `.md` du depot. Il faut systematiquement utiliser des liens Markdown explicites `[texte](url)`. L'URL du remote est detectee a l'étape 1 du skill.

### Exemples

```markdown
- Ajoute le support multi-langue ([#15](https://github.com/org/repo/pull/15))
```
PR #15 — le lecteur y trouvera les commits, l'issue liee et le contexte.

```markdown
- Corrige le parsing des dates ([`def5678`](https://github.com/org/repo/commit/def5678))
```
Commit direct, pas de PR — SHA court en fallback.

## Versioning

- Format strict dans les titres de section : `[MAJOR.MINOR.PATCH]` — jamais `v1.2.0`
- `[Unreleased]` toujours present en tete, meme si vide
- Date au format ISO 8601 : `YYYY-MM-DD`
- Les tags git utilisent le prefixe `v` : `v1.2.0`

## Versioning pre-v1.0.0

Plage `0.y.z` — semantique SemVer adaptee pour phase dev :

| Bump | Quand |
|---|---|
| `0.y` → `0.y+1.0` | Breaking change ou ajout significatif |
| `0.y.z` → `0.y.z+1` | Fix, ajout mineur |

En `0.x`, le MAJOR est implicitement instable — le MINOR joue le rôle du MAJOR.

## En-tetes de version

Le numéro de version dans l'en-tete de section est un lien inline vers le tag git **si et seulement si ce tag existe**.

Verification : `git tag --list "v${version}"` (puis `git tag --list "${version}"` en fallback sans prefixe `v`).

Format :
- Tag existant : `## [1.3.2](https://github.com/org/repo/releases/tag/v1.3.2) - 2026-03-29`
- Tag absent  : `## [1.4.0] - 2026-03-29`

L'URL suit le pattern : `https://github.com/{owner}/{repo}/releases/tag/{tag}` (avec le prefixe `v` qui a matche).

`[Unreleased]` n'est jamais linke — aucun tag ne correspond.

## Liens de comparaison

Toujours generes en bas du fichier CHANGELOG :

- `[Unreleased]` pointe vers `compare/vX.Y.Z...HEAD` (dernier tag vs HEAD)
- Chaque version pointe vers `compare/vPRECEDENT...vCOURANT`
- La première version pointe vers `releases/tag/vX.Y.Z`

Format :
```markdown
[Unreleased]: https://github.com/org/repo/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/org/repo/compare/v1.1.0...v1.2.0
[1.0.0]: https://github.com/org/repo/releases/tag/v1.0.0
```

## Exclusions

Exclus du CHANGELOG :

- Les commits purement techniques sans impact consommateur ni deploiement : refactors internes, tests, CI/CD, bumps de dependances, docs contributeur, config interne. Ils restent documentes par l'historique git et les corps de commits.
- Les merges (`Merge branch...`, `Merge pull request...`)
- Les rebases et fixups (`fixup!`, `squash!`)
- Les typos purs (commentaires, fautes de frappe dans la doc)
- Les commits de revert immédiatement suivis du recommit
- Le contenu des commits verbatim (toujours reformuler)

## Bloc Changelog d'une PR

Chaque PR créée par `/pipe-pr` porte une section `## Changelog` dans son body, au format de ce referentiel (memes types, memes règles de rédaction, references vers les commits). C'est l'entrée CHANGELOG ecrite au moment ou le contexte est frais, par celui qui a fait le changement — voir `git-conventions/reference.md`.

A la release, ces blocs sont la **source primaire** : leurs entrées sont reprises telles quelles, la reference devenant la PR. La derivation depuis les commits (filtrage, classement, reformulation) ne s'applique qu'au reste : PRs anterieures a cette convention, PRs sans bloc, commits directs.

Ce que le bloc ne dispense pas de faire a la release :

- **Consolider en etat final entre PRs** : deux PRs de la meme release qui touchent le meme artefact donnent une seule entrée
- **Notes de deploiement et `**BREAKING**`** : le bloc peut les porter, la release les remonte en blockquote sous l'en-tete de version si elles concernent toute la release
- **Audit de cohérence** : un bloc n'est qu'une source, la date de merge de la PR reste ce qui place l'entrée dans une section

## Changesets (Turborepo) — optionnel

Si le projet utilise Changesets :

- Un fichier `.changeset/*.md` par PR avec le bon bump (`major` / `minor` / `patch`)
- Le summary dans le changeset = ce qui apparaitra dans le CHANGELOG → rédige court, pour le consommateur
- Ne pas editer manuellement le CHANGELOG génère — editer les changesets en amont
- Si des changesets existent, les utiliser comme source primaire au lieu des commits
