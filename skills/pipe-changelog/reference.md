# Pipe Changelog — Referentiel de conventions

## Standard de reference

**[Keep a Changelog](https://keepachangelog.com/en/1.1.0/)** + **[Semantic Versioning](https://semver.org/spec/v2.0.0.html)**

## Structure globale du CHANGELOG

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.0](https://github.com/org/repo/releases/tag/v1.2.0) - 2026-03-29
## [1.1.0](https://github.com/org/repo/releases/tag/v1.1.0) - 2026-02-14
## [1.0.0](https://github.com/org/repo/releases/tag/v1.0.0) - 2026-01-01

[Unreleased]: https://github.com/org/repo/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/org/repo/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/org/repo/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/org/repo/releases/tag/v1.0.0
```

## Types d'entrees (ordre impose)

Les types doivent toujours apparaitre dans cet ordre. Ne pas inclure les types sans entrees.

| Type | Usage |
|---|---|
| `Added` | Nouvelle fonctionnalite |
| `Changed` | Modification de comportement existant |
| `Deprecated` | Fonctionnalite vouee a etre supprimee |
| `Removed` | Suppression definitive |
| `Fixed` | Correction de bug |
| `Security` | Patch de securite |

Pas de types custom (`Improved`, `Refactored`, `Chore`, etc.).

## Mapping prefixe de commit → fichier + type

Le classement se fait en deux fichiers : `CHANGELOG.md` (consommateur) et `TECHNICAL_CHANGES.md` (contributeur). Chaque commit retenu va dans **un seul** des deux.

| Prefixe commit | Defaut | Exception (impact consommateur) |
|---|---|---|
| `feat` | CHANGELOG → `Added` | — |
| `fix` | CHANGELOG → `Fixed` | — |
| `perf` | CHANGELOG → `Changed` | — |
| `refactor` | TECHNICAL → `Refactor` | CHANGELOG → `Changed` si l'API publique change |
| `docs` | TECHNICAL → `Docs` | CHANGELOG → `Added`/`Changed` si doc user-facing (README public, doc API consommee) |
| `chore` | TECHNICAL → `Chore`, `Dependencies` ou `CI` (voir ci-dessous) | CHANGELOG → `Changed` si config publique (`.mcp.json` exemple, manifest consomme) |
| `test` | TECHNICAL → `Tests` | — |

Sous-classement des `chore` dans TECHNICAL :
- Bump de dependance → `Dependencies`
- Modification d'un workflow CI, d'un hook git, d'un script de build → `CI`
- Tout le reste (config interne, meta, scripts divers) → `Chore`

Cas speciaux CHANGELOG (detectes par le contenu du commit, pas par le prefixe seul) :
- Suppression explicite d'une fonctionnalite → `Removed`
- Deprecation explicite → `Deprecated`
- Patch de securite → `Security`
- Breaking change → prefixer l'entree par `**BREAKING**`

## Regles de contenu

- Une entree = **une seule information user-facing distincte**. Si un changement couvre plusieurs aspects distincts (nouveau champ + nouveau filtre + nouvel endpoint), decouper en autant d'entrees separees plutot que de tout fusionner sur une ligne.
- Redigee pour le lecteur, pas pour le dev — pas de detail d'implementation interne
- Chaque entree tient sur **une seule ligne** — pas de retour a la ligne manuel au milieu d'une phrase. Les editeurs gerent le wrap, pas l'auteur.
- Chaque entree inclut ses references tracables en fin de ligne (voir section "References dans les entrees")
- Breaking changes marques : `**BREAKING**` en prefixe de l'entree
- Ne jamais copier les messages de commit verbatim — reformuler pour le consommateur

## Rediger pour le consommateur

Une entree de CHANGELOG parle au lecteur qui consomme le projet (dev qui appelle l'API, utilisateur de la lib, ops qui deploie), pas au contributeur qui a ecrit le code. Elle decrit un effet observable, pas une modification interne.

### Principes

1. **Exposer l'effet observable** — codes HTTP, parametres accessibles, exigences cote client, comportement visible. Pas les noms de fonctions internes, decorateurs, hooks, ou refactors qui ne changent rien a l'usage.
2. **Expliciter les valeurs concretes** — remplacer les formulations vagues par les contraintes reelles. "politique renforcee" → "minimum 12 caracteres avec majuscule, chiffre et symbole". "nouveau filtre" → "filtre `category_id` sur `GET /api/recipes`".
3. **Fusionner les entrees liees, mais decouper les aspects distincts** — la regle : si le lecteur peut consommer un aspect sans connaitre les autres, c'est qu'il merite sa propre ligne. La fusion ne s'applique qu'aux commits/PRs qui decrivent **le meme evenement vu du consommateur** :
   - ✅ **Fusion OK** : ajout du cookie HttpOnly + marquage BREAKING + CORS credentials → un seul evenement auth, donc une seule entree.
   - ❌ **Fusion abusive** : nouveau champ obligatoire + nouveau filtre + nouvel endpoint + inclusion dans un GET → ce sont autant d'informations user-facing distinctes, chacune doit etre sa propre entree.
4. **Indiquer l'impact client quand il existe** — si le consommateur doit adapter son code (headers, options fetch, configuration), le dire explicitement dans l'entree.

### Avant / apres

```
❌ Ajout du decorateur @Public() et desactivation du guard JWT sur les GET
✅ Les endpoints `GET` des ressources metier sont desormais accessibles publiquement sans authentification

❌ Refactor de find_by_email pour masquer l'existence des comptes
✅ Consultation d'une recette privee par un utilisateur non autorise : retour `404 Not Found` au lieu de `403 Forbidden` pour ne pas divulguer l'existence de la ressource

❌ Ajout du cookie HttpOnly, BREAKING, CORS credentials (3 entrees)
✅ **BREAKING — Authentification par cookie HttpOnly** : les endpoints `POST /auth/register` et `POST /auth/login` ne retournent plus le JWT dans le corps JSON. Le token est desormais pose dans un cookie `HttpOnly`, `SameSite=strict`, `Secure` en production. Les clients doivent utiliser `credentials: 'include'` sur leurs requetes HTTP. (1 entree fusionnee)

❌ Politique de mot de passe renforcee a l'inscription
✅ Politique de mot de passe renforcee a l'inscription : minimum 12 caracteres avec au moins une majuscule, un chiffre et un symbole
```

#### Decoupage : plusieurs aspects user-facing distincts

```
❌ Ajout du champ `type` obligatoire sur POST, nouveau filtre `?type=` sur GET, nouvel endpoint `PATCH /pricing` et inclusion de `pricing` dans `GET /:id` (1 entree fourre-tout)

✅ 4 entrees distinctes :
   - **BREAKING** — `POST /recipes` : le champ `type` est desormais obligatoire (`'base'` ou `'composed'`)
   - Nouveau filtre `?type=base|composed` sur `GET /recipes`
   - `GET /recipes/:id` inclut un objet `pricing` quand les informations tarifaires sont renseignees
   - Nouvel endpoint `PATCH /recipes/:id/pricing` (admin) pour creer ou mettre a jour le pricing
```

### Heuristique rapide

Si l'entree reformulee ne permet **pas** a un consommateur de repondre a l'une de ces questions, elle manque probablement de contenu :

- Qu'est-ce qui change concretement pour moi ?
- Est-ce que je dois adapter mon code ?
- Quelle est la nouvelle valeur / le nouveau comportement ?

## TECHNICAL_CHANGES.md — journal technique

`TECHNICAL_CHANGES.md` est le pendant de `CHANGELOG.md` pour les contributeurs. Il capture les changements internes qui n'affectent pas le consommateur mais qui interessent un developpeur qui ouvre le repo : refactors, docs internes, tests, CI, bumps de deps, maintenance.

### Symetrie avec CHANGELOG.md

- Meme format Keep a Changelog + SemVer
- Memes versions et memes dates (un tag git = une release, une seule date)
- Meme mecanisme de liens de comparaison en bas de fichier
- Meme regle de liens inline sur les en-tetes `## [X.Y.Z](tag-url) - YYYY-MM-DD` quand le tag existe

### Types d'entrees (ordre impose)

| Type | Usage |
|---|---|
| `Refactor` | Restructuration de code sans impact utilisateur (renommages internes, extraction de services, reorganisation de modules) |
| `Docs` | Documentation interne (ADR, CONTRIBUTING, commentaires, README contributeur) |
| `Tests` | Ajout, modification ou suppression de tests |
| `CI` | Workflows, hooks git, pipelines de build, scripts d'automatisation |
| `Dependencies` | Bumps de dependances (dev et runtime) |
| `Chore` | Maintenance et config interne ne relevant d'aucune autre categorie |

Pas de types custom hors de cette liste. Ne pas inclure les types sans entrees.

### Structure globale

```markdown
# Technical Changes

All notable technical changes targeted at contributors will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.0](https://github.com/org/repo/releases/tag/v1.2.0) - 2026-03-29

### Refactor

- Extraction du service de detection de plateforme git dans `platform-detector` ([#18](https://github.com/org/repo/pull/18))

### Dependencies

- Bump `typescript` 5.3.0 → 5.4.2 ([`a1b2c3d`](https://github.com/org/repo/commit/a1b2c3d))

[Unreleased]: https://github.com/org/repo/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/org/repo/compare/v1.1.0...v1.2.0
```

### Regles de contenu

- Une entree = un changement technique notable **pour un contributeur** (pas pour l'utilisateur final)
- Redigee de facon concise, orientee "ce qui a change dans le repo"
- Chaque entree tient sur **une seule ligne** et inclut sa reference tracable (meme regle que CHANGELOG)
- Ne jamais dupliquer une entree du CHANGELOG dans le TECHNICAL_CHANGES : un changement va **dans un seul** des deux fichiers
- Les bumps de deps peuvent etre groupes : `Bump des dependances dev (typescript, vitest, biome) ([#N](url))` si la PR couvre plusieurs bumps liees

### Cas limites

- **Commit refactor qui prepare une feature user-facing** : l'entree va dans le CHANGELOG uniquement quand la feature est livree. Le refactor intermediaire, s'il est livre seul sans impact visible, va dans TECHNICAL.
- **Docs qui impactent le consommateur** (ex: nouveau guide d'utilisation publique, doc d'API) : CHANGELOG, pas TECHNICAL.
- **Update de doc contributeur** (CONTRIBUTING, ADR, README interne) : TECHNICAL, pas CHANGELOG.

## Coherence versions/dates

Une entree placee sous une section versionnee `[X.Y.Z] - YYYY-MM-DD` doit correspondre a un commit (ou a une PR) **mergee avant la date du tag**. Un changement introduit apres la date de release appartient a `[Unreleased]`, jamais a une version deja publiee.

### Verification

Lors de la generation ou de l'audit d'un CHANGELOG existant :

1. Recuperer la date de chaque tag versionne : `git log -1 --format=%aI v<X.Y.Z>`.
2. Pour chaque PR referencee dans une section versionnee, comparer sa date de merge avec la date du tag : `gh pr view <N> --json mergedAt --jq .mergedAt`.
3. Pour les entrees referencees par SHA, utiliser la date du commit : `git log -1 --format=%aI <sha>`.
4. Si la reference est **posterieure** a la date du tag, deplacer l'entree vers `[Unreleased]`.

Cas typique : un CHANGELOG cree tardivement apres un premier tag, qui a absorbe par erreur des changements mergees plus tard. L'audit doit etre systematique a chaque passage de `/pipe-changelog`.

Le meme audit s'applique a `TECHNICAL_CHANGES.md` : chaque entree sous une section versionnee doit referencer un commit/PR mergee avant la date du tag. Les deux fichiers sont audites a chaque passage du skill.

## References dans les entrees

Chaque entree de changelog inclut une reference tracable entre parentheses en fin de ligne. Cela permet de remonter a l'origine d'un changement.

### Regle

- **Si une PR existe** : lier la PR. C'est la reference principale — elle contient le contexte, les commits et les issues liees.
- **Si pas de PR** (commit direct) : lier le SHA court en fallback.

Une seule reference par entree. Pas besoin de doublonner PR + SHA + issue.

### Format

```
- Texte reformule ([#N](url))
```

**Important** : GitHub n'auto-link pas les references dans les fichiers `.md` du depot. Il faut systematiquement utiliser des liens Markdown explicites `[texte](url)`. L'URL du remote est detectee a l'etape 1 du skill.

### Exemples

```markdown
- Ajouter le support multi-langue ([#15](https://github.com/org/repo/pull/15))
```
PR #15 — le lecteur y trouvera les commits, l'issue liee et le contexte.

```markdown
- Corriger le parsing des dates ([`def5678`](https://github.com/org/repo/commit/def5678))
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

En `0.x`, le MAJOR est implicitement instable — le MINOR joue le role du MAJOR.

## En-tetes de version

Le numero de version dans l'en-tete de section est un lien inline vers le tag git **si et seulement si ce tag existe**.

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
- La premiere version pointe vers `releases/tag/vX.Y.Z`

Format :
```markdown
[Unreleased]: https://github.com/org/repo/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/org/repo/compare/v1.1.0...v1.2.0
[1.0.0]: https://github.com/org/repo/releases/tag/v1.0.0
```

## Exclusions

Exclus des deux fichiers (CHANGELOG et TECHNICAL) :

- Les merges (`Merge branch...`, `Merge pull request...`)
- Les rebases et fixups (`fixup!`, `squash!`)
- Les typos purs (commentaires, fautes de frappe dans la doc)
- Les commits de revert immediatement suivis du recommit
- Le contenu des commits verbatim (toujours reformuler)

Les changements CI/CD, les bumps de deps et les docs internes ne sont **pas** exclus : ils vont dans `TECHNICAL_CHANGES.md` (sections `CI`, `Dependencies`, `Docs`).

## Changesets (Turborepo) — optionnel

Si le projet utilise Changesets :

- Un fichier `.changeset/*.md` par PR avec le bon bump (`major` / `minor` / `patch`)
- Le summary dans le changeset = ce qui apparaitra dans le CHANGELOG → redige pour le consommateur
- Ne pas editer manuellement le CHANGELOG genere — editer les changesets en amont
- Si des changesets existent, les utiliser comme source primaire au lieu des commits
