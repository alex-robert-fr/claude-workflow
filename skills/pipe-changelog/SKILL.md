---
name: pipe-changelog
description: Generer ou mettre a jour CHANGELOG.md (consommateur) et TECHNICAL_CHANGES.md (contributeur) depuis les commits/tags. Analyse les changements depuis la derniere version et respecte Keep a Changelog + SemVer. Utiliser apres /pipe-test et avant /pipe-pr.
model: sonnet
argument-hint: [version a tagger ou rien pour Unreleased]
---

## Contexte

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/../_workflow-persona/SKILL.md` avant de commencer.

---

## Etape 0 — Verifications

- [ ] Le repo a un remote `origin` configure
- [ ] La branche courante n'est pas la branche par defaut
- [ ] Il y a au moins un commit d'avance sur la branche par defaut

Si une verification echoue, signale-le clairement et arrete-toi.

## Etape 1 — Detecter le contexte de versioning

Recupere les informations necessaires :

1. **Dernier tag de version** — via `git tag --sort=-version:refSort -l 'v*' | head -1`. Si aucun tag, c'est la premiere version.
2. **URL du remote** — via `git remote get-url origin`, transforme en URL HTTPS pour les liens de comparaison (ex: `git@github.com:org/repo.git` → `https://github.com/org/repo`).
3. **Phase de versioning** — si le dernier tag est `0.x.y`, on est en pre-v1.0.0. Sinon, post-v1.0.0.
4. **Version cible** — si un argument est fourni (ex: `1.3.0`), c'est la version a publier. Sinon, on met a jour la section `[Unreleased]`.
5. **Tags existants** — pour chaque version presente dans CHANGELOG.md ou TECHNICAL_CHANGES.md (hors `[Unreleased]`) et pour la version cible, verifier si le tag existe :
   - `git tag --list "v${version}"` → si resultat non vide, le tag `v${version}` existe
   - `git tag --list "${version}"` → fallback sans prefixe `v`
   - Construire un map `{ version → nom du tag tel que matche (ex: "v1.3.2") | null }` utilise a l'etape 3 pour generer les en-tetes de version

Affiche le contexte detecte :

```
Contexte de versioning :
- Dernier tag : [tag ou "aucun"]
- Remote : [URL HTTPS]
- Phase : [pre-v1.0.0 / post-v1.0.0]
- Cible : [version ou "Unreleased"]
```

## Etape 2 — Collecter les changements

Utilise Read pour charger `reference.md` (referentiel de conventions et mapping des types).

1. **Lister les commits** — `git log <dernier-tag>..HEAD --format="%h %s"` (ou `git log --format="%h %s"` si aucun tag). Le `%h` donne le SHA court de chaque commit.
2. **Filtrer les exclusions** — supprimer les commits exclus des deux fichiers selon la section "Exclusions" du referentiel (merges, fixups, typos purs, reverts annules). CI/CD, bumps de deps et docs internes ne sont pas exclus — ils vont dans TECHNICAL.
3. **Detecter les changesets** — si `.changeset/` existe et contient des fichiers `.md`, les utiliser comme source primaire au lieu des commits (uniquement pour CHANGELOG.md — les changesets ne couvrent pas le contenu technique).
4. **Classer dans le bon fichier** — pour chaque commit retenu, utiliser le mapping "prefixe → fichier + type" du referentiel :
   - `feat`, `fix`, `perf` → CHANGELOG
   - `refactor`, `docs`, `chore`, `test` → TECHNICAL par defaut ; CHANGELOG si impact consommateur avere (API publique modifiee, doc user-facing, config publique)
   - En cas de doute entre les deux fichiers, privilegier TECHNICAL et demander confirmation
5. **Enrichir avec les references** — pour chaque commit retenu, trouver la PR associee :
   - Utiliser `gh pr list --state merged --search "SHA" --json number --jq '.[0].number'` pour trouver la PR qui a merge ce commit.
   - Si une PR est trouvee, c'est la reference de l'entree. Si pas de PR (commit direct), utiliser le SHA court en fallback.
   - Si `gh` echoue ou est indisponible, utiliser le SHA seul — ne pas bloquer la generation.
6. **Reformuler** —
   - Pour CHANGELOG : appliquer les principes de la section "Rediger pour le consommateur" de `reference.md` (effet observable, valeurs concretes, fusion des entrees liees, impact client).
   - Pour TECHNICAL : entree concise orientee contributeur (ce qui a change dans le repo), meme regle d'une seule ligne et meme reference tracable.
   - **Une entree = une seule information user-facing distincte** : si un changement couvre plusieurs aspects (nouveau champ + nouveau filtre + nouvel endpoint), decouper en autant d'entrees separees (voir principe #3 dans `reference.md`).
   - Chaque entree tient sur **une seule ligne** et se termine par la reference entre parentheses avec un lien Markdown explicite (voir section "References dans les entrees" de `reference.md`). L'URL de base du remote est detectee a l'etape 1.

Affiche les entrees classees avant de continuer, en deux blocs distincts :

```
Changements detectes :

=== CHANGELOG.md (consommateur) ===

### Added
- [entree reformulee] ([#15](url/pull/15))

### Fixed
- [entree reformulee] ([`9a8b7c6`](url/commit/9a8b7c6))

=== TECHNICAL_CHANGES.md (contributeur) ===

### Refactor
- [entree technique] ([#12](url/pull/12))

### Dependencies
- [entree technique] ([`a1b2c3d`](url/commit/a1b2c3d))

[N] commits exclus (merges, fixups, typos...)
```

Demande confirmation si le classement semble correct avant de continuer.

## Etape 2.5 — Auditer la coherence historique

Avant de toucher aux entrees, verifier que **CHANGELOG.md et TECHNICAL_CHANGES.md** ne contiennent pas d'entrees mal placees : une PR mergee apres la date d'un tag ne peut pas figurer sous la section de ce tag.

Procedure (voir `reference.md` section "Coherence versions/dates") a appliquer **sur chacun des deux fichiers** :

1. Pour chaque section versionnee `[X.Y.Z] - YYYY-MM-DD` du fichier, recuperer la date du tag correspondant via `git log -1 --format=%aI v<X.Y.Z>` (fallback sans prefixe `v`). Si le tag n'existe pas, passer la section — pas d'audit possible.
2. Pour chaque entree sous cette section, extraire la reference (PR ou SHA) et recuperer sa date :
   - PR : `gh pr view <N> --json mergedAt --jq .mergedAt`
   - SHA : `git log -1 --format=%aI <sha>`
3. Si la date de la reference est **posterieure** a la date du tag, l'entree doit etre deplacee vers le `[Unreleased]` du **meme fichier**.

Si des entrees mal placees sont detectees, les lister clairement en indiquant le fichier :

```
Entrees mal placees (a deplacer vers [Unreleased]) :

CHANGELOG.md :
- Section [0.1.0] (tag du YYYY-MM-DD) :
  - PR #N (mergee le YYYY-MM-DD) : "texte de l'entree"

TECHNICAL_CHANGES.md :
- (aucune)
```

Demander confirmation avant de reorganiser. Cette etape est rapide si les deux fichiers sont sains — la mentionner brievement et passer a l'etape suivante.

## Etape 3 — Generer / mettre a jour les deux fichiers

Traiter **CHANGELOG.md** et **TECHNICAL_CHANGES.md** en appliquant la meme logique a chacun, avec son propre bucket d'entrees issu de l'etape 2.

### Cas 1 : le fichier n'existe pas

Creer le fichier complet avec :
- Le header standard correspondant (voir referentiel : "Structure globale du CHANGELOG" pour `CHANGELOG.md`, "TECHNICAL_CHANGES.md — journal technique" pour `TECHNICAL_CHANGES.md`)
- La section appropriee (`[Unreleased]` ou `[X.Y.Z] - YYYY-MM-DD`)
- Les liens de comparaison en bas

Si aucune entree technique n'est detectee, `TECHNICAL_CHANGES.md` peut ne pas etre cree — ne pas generer un fichier vide. A l'inverse, si le fichier existe deja et qu'il n'y a aucune entree technique pour cette release, simplement ne pas y ajouter de nouvelle section.

### Cas 2 : le fichier existe

Lire le contenu existant et :
- Si **version specifiee** : creer une nouvelle section `[X.Y.Z] - YYYY-MM-DD` sous `[Unreleased]`, y deplacer les entrees, vider `[Unreleased]`
- Si **pas de version** : inserer/mettre a jour les entrees dans `[Unreleased]`
- Mettre a jour les liens de comparaison en bas du fichier

### Regles communes aux deux fichiers

- Respecter l'ordre impose des types :
  - CHANGELOG : `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`
  - TECHNICAL : `Refactor`, `Docs`, `Tests`, `CI`, `Dependencies`, `Chore`
- Ne pas inclure les types sans entrees
- Breaking changes prefixes par `**BREAKING**` (CHANGELOG uniquement — pas de BREAKING technique)
- Format de version `[MAJOR.MINOR.PATCH]` sans prefixe `v` dans les titres de section
- En-tete de version : si le tag existe (map de l'etape 1), utiliser le lien inline `## [X.Y.Z](https://github.com/{owner}/{repo}/releases/tag/{tagRef}) - YYYY-MM-DD`. Si le tag n'existe pas, texte brut `## [X.Y.Z] - YYYY-MM-DD`. `[Unreleased]` n'est jamais linke.
- Dates au format ISO 8601 (`YYYY-MM-DD`)
- Memes versions, memes dates dans les deux fichiers : un tag git = une release, pas de desynchronisation

## Etape 4 — Afficher le resultat et confirmer

Affiche le contenu complet des fichiers generes (ou les diffs si mise a jour), dans deux blocs distincts et clairement identifies (`CHANGELOG.md` puis `TECHNICAL_CHANGES.md`). Si l'un des deux n'a pas de changement, le mentionner explicitement.

Demande confirmation avant d'ecrire :

```
Voici les fichiers generes. Je les ecris ?
- CHANGELOG.md : [cree / mis a jour / inchange]
- TECHNICAL_CHANGES.md : [cree / mis a jour / inchange]
```

Une fois confirme :
- Ecrire chaque fichier modifie
- Commit unique regroupant les deux fichiers avec le format : `📝 docs: mettre a jour le CHANGELOG et le TECHNICAL_CHANGES` (ou `📝 docs: creer le CHANGELOG et le TECHNICAL_CHANGES` si premiere creation, ou `📝 docs: mettre a jour le CHANGELOG` si TECHNICAL inchange, etc. — adapter au scope reel)

## Etape 5 — Proposer la suite

```
---
CHANGELOG et TECHNICAL_CHANGES mis a jour. Prochaine etape : `/pipe-pr` pour soumettre la branche.
```

---

## Input utilisateur

$ARGUMENTS
