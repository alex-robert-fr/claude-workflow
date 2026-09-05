---
name: pipe-changelog
description: Generer ou maintenir CHANGELOG.md depuis les commits : entrees courtes orientees metier, Keep a Changelog, SemVer.
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
5. **Tags existants** — pour la version cible et pour la version de la section la plus recente (les seuls en-tetes que l'etape 3 ecrit ou reecrit ; les sections plus anciennes ne sont pas rechargees), verifier si le tag existe :
   - `git tag --list "v${version}"` → si resultat non vide, le tag `v${version}` existe
   - `git tag --list "${version}"` → fallback sans prefixe `v`
   - Construire un map `{ version → nom du tag tel que matche (ex: "v1.3.2") | null }` utilise a l'etape 3 pour generer les en-tetes de version

Affiche le contexte detecte :

```
Versioning — dernier tag [tag ou "aucun"] · [pre-v1.0.0 / post-v1.0.0] · cible [version ou "Unreleased"]
```

Le remote sert aux liens, il n'a pas a etre affiche.

## Etape 2 — Collecter les changements

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/reference.md` (referentiel de conventions et mapping des types).

1. **Lister les commits** — `git log <dernier-tag>..HEAD --format="%h %s"` (ou `git log --format="%h %s"` si aucun tag). Le `%h` donne le SHA court de chaque commit.
2. **Filtrer** — ne retenir que les commits a impact consommateur ou deploiement, selon la section "Mapping prefixe de commit → type" et la section "Exclusions" du referentiel :
   - `feat`, `fix`, `perf` → retenus
   - `refactor`, `docs`, `chore`, `test` → exclus par defaut ; retenus uniquement si impact consommateur avere (API publique modifiee, doc user-facing, config publique, variable d'environnement requise). En cas de doute, exclure et signaler l'ambiguite (marqueur `⚠️`) dans l'affichage.
   - Exclusions systematiques : merges, fixups, typos purs, reverts annules.
3. **Collecter les blocs Changelog des PRs mergees** — source primaire, voir la section "Bloc Changelog d'une PR" du referentiel. En **un seul appel batch** : `gh pr list --state merged --limit 50 --json number,body,mergeCommit,headRefName`, puis ne garder que les PRs dont le merge commit est dans la plage `<dernier-tag>..HEAD`. Pour chacune, extraire la section `## Changelog` de son body (jusqu'au `## ` suivant). Ses entrees sont deja redigees pour le consommateur et deja classees : les reprendre telles quelles, en remplacant leurs references par le lien de la PR (reference principale, voir "References dans les entrees" — les SHA restent atteignables depuis la PR). Les commits couverts par une PR a bloc sortent de la liste de l'etape 1 : ils ne sont pas retraites.
4. **Detecter les changesets Turborepo** — si `.changeset/` existe et contient des fichiers `.md`, les utiliser comme source primaire pour les commits restants.
5. **Classer par type** — pour chaque commit restant (PR sans bloc, commit direct), determiner le type Keep a Changelog (`Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`) selon le mapping du referentiel.
6. **Enrichir avec les references** — associer localement chaque commit restant a sa PR avec le resultat de l'appel de l'etape 3 (via le merge commit ou la branche d'origine, `git log --format=%h` sur la plage concernee) — jamais un appel `gh` par commit :
   - Si une PR est trouvee, c'est la reference de l'entree. Si pas de PR (commit direct), utiliser le SHA court en fallback.
   - Si `gh` echoue ou est indisponible, utiliser le SHA seul — ne pas bloquer la generation.
7. **Reformuler court** — pour les commits restants, appliquer la section "Rediger pour le consommateur" de `${CLAUDE_SKILL_DIR}/reference.md` et sa sous-section "Regles de redaction". Le **template mental** `[Verbe actif present] [feature publique] [effet visible utilisateur]` aide a structurer la formulation. Les entrees issues des blocs de PR ne sont pas reformulees, mais la consolidation en etat final s'applique a l'ensemble : deux PRs de la meme release qui touchent le meme artefact donnent une seule entree.
   - **Une entree = une phrase courte** : l'effet observable, sans detail d'implementation. Le lecteur qui veut le detail clique sur la reference — c'est le corps du commit qui le porte.
   - **Fusionner les entrees liees** : plusieurs commits qui composent la meme fonctionnalite vue du consommateur donnent une seule entree, avec plusieurs references si necessaire.
   - **Consolider en etat final** : quand plusieurs commits successifs touchent le meme artefact au sein de la meme release, n'ecrire qu'une seule entree decrivant l'etat final. Un fichier ajoute puis supprime dans la meme PR ne donne aucune entree. Voir sous-section "Consolider en etat final" de `${CLAUDE_SKILL_DIR}/reference.md`.
   - Chaque entree tient sur **une seule ligne** et se termine par sa ou ses references entre parentheses avec un lien Markdown explicite (voir section "References dans les entrees" de `${CLAUDE_SKILL_DIR}/reference.md`). L'URL de base du remote est detectee a l'etape 1.

Affiche les entrees classees avant de continuer :

```
**Changements detectes**

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

Procedure (voir `${CLAUDE_SKILL_DIR}/reference.md` section "Coherence versions/dates") :

1. Lister les sections versionnees sans charger le fichier — `grep -n '^## \[' CHANGELOG.md` ne renvoie que les titres et leurs numeros de ligne.
2. Pour chaque section versionnee `[X.Y.Z] - YYYY-MM-DD`, recuperer la date du tag correspondant via `git log -1 --format=%aI v<X.Y.Z>` (fallback sans prefixe `v`). Si le tag n'existe pas, passer la section — pas d'audit possible.
3. Extraire les entrees de la section a auditer, une section a la fois — jamais le fichier entier (remplacer la version, points echappes) :
   ```
   sed -n '/^## \[1\.5\.0\]/,/^## \[/{/^## \[/d;/^\[[^]]*\]: /d;p;}' CHANGELOG.md
   ```
4. Pour chaque entree extraite, extraire la reference (PR ou SHA) et recuperer sa date :
   - PR : `gh pr view <N> --json mergedAt --jq .mergedAt`
   - SHA : `git log -1 --format=%aI <sha>`
5. Si la date de la reference est **posterieure** a la date du tag, l'entree doit etre deplacee vers `[Unreleased]`.

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

**Ne jamais lire `CHANGELOG.md` en entier** — il grossit a chaque release et seuls l'en-tete (le format) et la section `[Unreleased]` (les entrees a modifier) sont necessaires. Charger dans cet ordre :

1. **Bornes des sections** — `grep -n -m 2 '^## \[' CHANGELOG.md` : la 1re occurrence est `## [Unreleased]`, la 2e est l'en-tete de la version la plus recente.
2. **En-tete + `[Unreleased]`** — `Read` sur `CHANGELOG.md` avec `limit` = numero de ligne de la 2e occurrence. Cette lecture bornee est aussi le prealable exige par `Edit`. Ne pas reecrire le fichier avec `Write` : ecraser le fichier imposerait de l'avoir lu integralement.
3. **Liens de comparaison** — `grep -n -m 2 -E '^\[[^]]+\]: ' CHANGELOG.md` : les deux premieres definitions (`[Unreleased]` et la derniere version) donnent le pattern d'URL et la ligne a modifier.

Puis modifier avec `Edit` :
- Si **version specifiee** : creer une nouvelle section `[X.Y.Z] - YYYY-MM-DD` sous `[Unreleased]` (Edit ancre sur `## [Unreleased]`), y deplacer les entrees, vider `[Unreleased]`
- Si **pas de version** : inserer/mettre a jour les entrees dans `[Unreleased]`
- Mettre a jour les liens de comparaison en bas du fichier (Edit ancre sur la ligne `[Unreleased]: ...`, puis insertion de la nouvelle definition de version juste apres)

### Regles

- Respecter l'ordre impose des types : `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`
- Ne pas inclure les types sans entrees
- Breaking changes prefixes par `**BREAKING**` ; si la release entiere impose une migration, la remonter en blockquote sous l'en-tete de version (voir referentiel : "Notes de deploiement")
- Les notes de deploiement (variables d'environnement requises, migrations, version minimale d'un service partenaire) restent dans le CHANGELOG — voir referentiel : "Notes de deploiement"
- Format de version `[MAJOR.MINOR.PATCH]` sans prefixe `v` dans les titres de section
- En-tete de version : si le tag existe (map de l'etape 1), utiliser le lien inline `## [X.Y.Z](https://github.com/{owner}/{repo}/releases/tag/{tagRef}) - YYYY-MM-DD`. Si le tag n'existe pas, texte brut `## [X.Y.Z] - YYYY-MM-DD`. `[Unreleased]` n'est jamais linke.
- Dates au format ISO 8601 (`YYYY-MM-DD`)

## Etape 4 — Afficher le resultat et confirmer

Affiche le contenu complet du fichier en creation (Cas 1), le diff seul en mise a jour (Cas 2) — jamais l'integralite d'un CHANGELOG existant, qui n'a d'ailleurs pas ete chargee.

Demande confirmation avant d'ecrire :

```
J'ecris `CHANGELOG.md` ([cree / mis a jour]) ?
```

Une fois confirme :
- Ecrire le fichier
- Commit avec le format : `📝 docs: mettre a jour le CHANGELOG` (ou `📝 docs: creer le CHANGELOG` si premiere creation)

## Etape 5 — Proposer la suite

```
---
CHANGELOG mis a jour. En contexte release : retour a `/pipe-release`.
```

---

## Input utilisateur

$ARGUMENTS
