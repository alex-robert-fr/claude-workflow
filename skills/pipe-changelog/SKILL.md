---
name: pipe-changelog
description: Generer ou mettre a jour CHANGELOG.md depuis les commits/tags. Entrees courtes orientees metier — le detail technique vit dans les corps de commits et les PRs, le CHANGELOG pointe vers eux. Respecte Keep a Changelog + SemVer. Utilise au moment d'une release par /pipe-release, ou seul.
argument-hint: [version a tagger ou rien pour Unreleased]
---

## Philosophie

Chaque information vit a l'endroit ou elle vieillit le mieux :

- **CHANGELOG.md** — court et non technique. Il parle a celui qui utilise le projet (dev qui consomme l'API, utilisateur de l'app, ops qui deploie), jamais a celui qui ecrit le code.
- **Corps des commits** — le journal technique. Chaque entree du CHANGELOG pointe vers son commit ou sa PR, qui documente le detail d'implementation.
- **Pas de fichier technique separe** (`TECHNICAL_CHANGES.md` ou equivalent) : l'historique git joue ce role, sans risque de derive.

Les changements purement techniques (refactors internes, tests, CI, dependances, docs contributeur) n'apparaissent pas dans le CHANGELOG — sauf s'ils ont un impact consommateur ou deploiement.

## Etape 0 — Verifications

- [ ] Le repo a un remote `origin` configure
- [ ] Il y a des changements a documenter : commits depuis le dernier tag (`git log <dernier-tag>..HEAD`), ou section `[Unreleased]` non vide a publier

Si une verification echoue, signale-le clairement et arrete-toi.

Contexte nominal : ce skill est applique par `/pipe-release` depuis la branche d'integration, avec une version en argument. Il reste invocable seul (mode `[Unreleased]` sans argument).

**Migration** : si un fichier `TECHNICAL_CHANGES.md` existe a la racine du projet, signaler qu'il est obsolete et proposer sa suppression — son contenu reste accessible dans l'historique git du fichier et dans les commits.

## Etape 1 — Detecter le contexte de versioning

Recupere les informations necessaires :

1. **Dernier tag de version** — via `git tag --sort=-version:refname -l 'v*' | head -1`. Si aucun tag, c'est la premiere version.
2. **URL du remote** — via `git remote get-url origin`, transforme en URL HTTPS pour les liens de comparaison (ex: `git@github.com:org/repo.git` → `https://github.com/org/repo`).
3. **Phase de versioning** — si le dernier tag est `0.x.y`, on est en pre-v1.0.0. Sinon, post-v1.0.0.
4. **Version cible** — si un argument est fourni (ex: `1.3.0`), c'est la version a publier. Sinon, on met a jour la section `[Unreleased]`.
5. **Tags existants** — pour chaque version presente dans CHANGELOG.md (hors `[Unreleased]`) et pour la version cible, verifier si le tag existe :
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
2. **Filtrer** — ne retenir que les commits a impact consommateur ou deploiement, selon la section "Mapping prefixe de commit → type" et la section "Exclusions" du referentiel :
   - `feat`, `fix`, `perf` → retenus
   - `refactor`, `docs`, `chore`, `test` → exclus par defaut ; retenus uniquement si impact consommateur avere (API publique modifiee, doc user-facing, config publique, variable d'environnement requise). En cas de doute, exclure et signaler l'ambiguite (marqueur `⚠️`) dans l'affichage.
   - Exclusions systematiques : merges, fixups, typos purs, reverts annules.
3. **Detecter les changesets** — si `.changeset/` existe et contient des fichiers `.md`, les utiliser comme source primaire au lieu des commits.
4. **Classer par type** — pour chaque commit retenu, determiner le type Keep a Changelog (`Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`) selon le mapping du referentiel.
5. **Enrichir avec les references** — trouver la PR associee a chaque commit en **un seul appel batch** (jamais un appel `gh` par commit) :
   - `gh pr list --state merged --limit 50 --json number,mergeCommit,headRefName` puis associer localement chaque commit a sa PR (via le merge commit ou la branche d'origine, `git log --format=%h` sur la plage concernee).
   - Si une PR est trouvee, c'est la reference de l'entree. Si pas de PR (commit direct), utiliser le SHA court en fallback.
   - Si `gh` echoue ou est indisponible, utiliser le SHA seul — ne pas bloquer la generation.
6. **Reformuler court** — appliquer la section "Rediger pour le consommateur" de `reference.md` et sa sous-section "Regles de redaction". Le **template mental** `[Verbe actif present] [feature publique] [effet visible utilisateur]` aide a structurer la formulation.
   - **Une entree = une phrase courte** : l'effet observable, sans detail d'implementation. Le lecteur qui veut le detail clique sur la reference — c'est le corps du commit qui le porte.
   - **Fusionner les entrees liees** : plusieurs commits qui composent la meme fonctionnalite vue du consommateur donnent une seule entree, avec plusieurs references si necessaire.
   - **Consolider en etat final** : quand plusieurs commits successifs touchent le meme artefact au sein de la meme release, n'ecrire qu'une seule entree decrivant l'etat final. Un fichier ajoute puis supprime dans la meme PR ne donne aucune entree. Voir sous-section "Consolider en etat final" de `reference.md`.
   - Chaque entree tient sur **une seule ligne** et se termine par sa ou ses references entre parentheses avec un lien Markdown explicite (voir section "References dans les entrees" de `reference.md`). L'URL de base du remote est detectee a l'etape 1.

Affiche les entrees classees avant de continuer :

```
Changements detectes :

### Added
- [entree courte reformulee] ([#15](url/pull/15))

### Fixed
- [entree courte reformulee] ([`9a8b7c6`](url/commit/9a8b7c6))

[N] commits exclus (techniques, merges, fixups...)
```

Ne pas demander de confirmation ici — la confirmation unique a lieu a l'etape 4, sur le resultat final. Si un classement est ambigu, le signaler dans l'affichage (marqueur `⚠️`) pour que l'utilisateur puisse corriger a l'etape 4.

## Etape 2.5 — Auditer la coherence historique (releases uniquement)

**Executer cette etape uniquement si une version est publiee** (argument fourni a l'etape 1) **ou si l'utilisateur le demande explicitement.** En mode `[Unreleased]`, passer directement a l'etape 3 — l'audit systematique coutait plusieurs appels `gh` a chaque run pour un historique qui n'a pas bouge.

Verifier que le CHANGELOG existant ne contient pas d'entrees mal placees : une PR mergee apres la date d'un tag ne peut pas figurer sous la section de ce tag.

Procedure (voir `reference.md` section "Coherence versions/dates") :

1. Pour chaque section versionnee `[X.Y.Z] - YYYY-MM-DD` du fichier, recuperer la date du tag correspondant via `git log -1 --format=%aI v<X.Y.Z>` (fallback sans prefixe `v`). Si le tag n'existe pas, passer la section — pas d'audit possible.
2. Pour chaque entree sous cette section, extraire la reference (PR ou SHA) et recuperer sa date :
   - PR : `gh pr view <N> --json mergedAt --jq .mergedAt`
   - SHA : `git log -1 --format=%aI <sha>`
3. Si la date de la reference est **posterieure** a la date du tag, l'entree doit etre deplacee vers `[Unreleased]`.

Si des entrees mal placees sont detectees, les lister clairement :

```
Entrees mal placees (a deplacer vers [Unreleased]) :

- Section [0.1.0] (tag du YYYY-MM-DD) :
  - PR #N (mergee le YYYY-MM-DD) : "texte de l'entree"
```

Integrer la reorganisation proposee au recap de l'etape 4 — pas de confirmation separee ici. Cette etape est rapide si le fichier est sain — la mentionner brievement et passer a l'etape suivante.

## Etape 3 — Generer / mettre a jour le CHANGELOG

### Cas 1 : le fichier n'existe pas

Creer le fichier complet avec :
- Le header standard (voir referentiel : "Structure globale du CHANGELOG")
- La section appropriee (`[Unreleased]` ou `[X.Y.Z] - YYYY-MM-DD`)
- Les liens de comparaison en bas

### Cas 2 : le fichier existe

Lire le contenu existant et :
- Si **version specifiee** : creer une nouvelle section `[X.Y.Z] - YYYY-MM-DD` sous `[Unreleased]`, y deplacer les entrees, vider `[Unreleased]`
- Si **pas de version** : inserer/mettre a jour les entrees dans `[Unreleased]`
- Mettre a jour les liens de comparaison en bas du fichier

### Regles

- Respecter l'ordre impose des types : `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`
- Ne pas inclure les types sans entrees
- Breaking changes prefixes par `**BREAKING**` ; si la release entiere impose une migration, la remonter en blockquote sous l'en-tete de version (voir referentiel : "Notes de deploiement")
- Les notes de deploiement (variables d'environnement requises, migrations, version minimale d'un service partenaire) restent dans le CHANGELOG — voir referentiel : "Notes de deploiement"
- Format de version `[MAJOR.MINOR.PATCH]` sans prefixe `v` dans les titres de section
- En-tete de version : si le tag existe (map de l'etape 1), utiliser le lien inline `## [X.Y.Z](https://github.com/{owner}/{repo}/releases/tag/{tagRef}) - YYYY-MM-DD`. Si le tag n'existe pas, texte brut `## [X.Y.Z] - YYYY-MM-DD`. `[Unreleased]` n'est jamais linke.
- Dates au format ISO 8601 (`YYYY-MM-DD`)

## Etape 4 — Afficher le resultat et confirmer

Affiche le contenu complet du fichier genere (ou le diff si mise a jour).

Demande confirmation avant d'ecrire :

```
Voici le CHANGELOG genere. Je l'ecris ?
- CHANGELOG.md : [cree / mis a jour]
```

Une fois confirme :
- Ecrire le fichier
- Commit avec le format : `📝 docs: mettre a jour le CHANGELOG` (ou `📝 docs: creer le CHANGELOG` si premiere creation)

## Etape 5 — Proposer la suite

```
---
CHANGELOG mis a jour. En contexte release : retour a `/pipe-release` (PR vers la branche de production).
```

---

## Input utilisateur

$ARGUMENTS
