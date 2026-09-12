---
name: pipe-changelog
description: Generer ou maintenir CHANGELOG.md depuis les commits : entrées courtes orientees métier, Keep a Changelog, SemVer.
argument-hint: [version a tagger ou rien pour Unreleased]
---

## Philosophie

Repartition CHANGELOG/commits et absence de fichier technique separe : voir `${CLAUDE_SKILL_DIR}/reference.md` section "Repartition CHANGELOG / commits".

## Étape 0 — Verifications

- [ ] Le repo a un remote `origin` configure
- [ ] Il y a des changements a documenter : commits depuis le dernier tag (`git log <dernier-tag>..HEAD`), ou section `[Unreleased]` non vide a publier

Si une verification echoue, signale-le clairement et arrete-toi.

Contexte nominal : ce skill est applique par `/pipe-release` depuis la branche d'integration, avec une version en argument. Il reste invocable seul (mode `[Unreleased]` sans argument).

**Migration** : si un fichier `TECHNICAL_CHANGES.md` existe a la racine du projet, signaler qu'il est obsolete et proposer sa suppression — son contenu reste accessible dans l'historique git du fichier et dans les commits.

## Étape 1 — Détecter le contexte de versioning

Recupere les informations nécessaires :

1. **Dernier tag de version** — via `git tag --sort=-version:refname -l 'v*' | head -1`. Si aucun tag, c'est la première version.
2. **URL du remote** — via `git remote get-url origin`, transforme en URL HTTPS pour les liens de comparaison (ex: `git@github.com:org/repo.git` → `https://github.com/org/repo`).
3. **Phase de versioning** — si le dernier tag est `0.x.y`, on est en pre-v1.0.0. Sinon, post-v1.0.0.
4. **Version cible** — si un argument est fourni (ex: `1.3.0`), c'est la version a publier. Sinon, on met a jour la section `[Unreleased]`.
5. **Tags existants** — pour la version cible et pour la version de la section la plus récente (les seuls en-tetes que l'étape 3 ecrit ou reecrit ; les sections plus anciennes ne sont pas rechargees), vérifier si le tag existe :
   - `git tag --list "v${version}"` → si resultat non vide, le tag `v${version}` existe
   - `git tag --list "${version}"` → fallback sans prefixe `v`
   - Construire un map `{ version → nom du tag tel que matche (ex: "v1.3.2") | null }` utilise a l'étape 3 pour generer les en-tetes de version

Affiche le contexte detecte :

```
Versioning — dernier tag [tag ou "aucun"] · [pre-v1.0.0 / post-v1.0.0] · cible [version ou "Unreleased"]
```

Le remote sert aux liens, il n'a pas a être affiche.

## Étape 2 — Collecter les changements

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/reference.md` (referentiel de conventions et mapping des types).

1. **Lister les commits** — `git log <dernier-tag>..HEAD --format="%h %s"` (ou `git log --format="%h %s"` si aucun tag). Le `%h` donne le SHA court de chaque commit.
2. **Filtrer** — ne retenir que les commits a impact consommateur ou deploiement, selon la section "Mapping prefixe de commit → type" et la section "Exclusions" du referentiel :
   - `feat`, `fix`, `perf` → retenus
   - `refactor`, `docs`, `chore`, `test` → exclus par defaut ; retenus uniquement si impact consommateur avere (API publique modifiee, doc user-facing, config publique, variable d'environnement requise). En cas de doute, exclure et signaler l'ambiguite (marqueur `⚠️`) dans l'affichage.
   - Exclusions systematiques : merges, fixups, typos purs, reverts annules.
3. **Collecter les blocs Changelog des PRs mergees** — source primaire, voir la section "Bloc Changelog d'une PR" du referentiel. En **un seul appel batch** : `gh pr list --state merged --limit 50 --json number,body,mergeCommit,headRefName`, puis ne garder que les PRs dont le merge commit est dans la plage `<dernier-tag>..HEAD`. Pour chacune, extraire la section `## Changelog` de son body (jusqu'au `## ` suivant). Ses entrées sont déjà rédigées pour le consommateur et déjà classees : les reprendre telles quelles, en remplacant leurs references par le lien de la PR (reference principale, voir "References dans les entrées" — les SHA restent atteignables depuis la PR). Les commits couverts par une PR a bloc sortent de la liste de l'étape 1 : ils ne sont pas retraites.
4. **Détecter les changesets Turborepo** — si `.changeset/` existe et contient des fichiers `.md`, les utiliser comme source primaire pour les commits restants.
5. **Classer par type** — pour chaque commit restant (PR sans bloc, commit direct), determiner le type Keep a Changelog (`Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`) selon le mapping du referentiel.
6. **Enrichir avec les references** — associer localement chaque commit restant a sa PR avec le resultat de l'appel de l'étape 3 (via le merge commit ou la branche d'origine, `git log --format=%h` sur la plage concernee) — jamais un appel `gh` par commit :
   - Si une PR est trouvee, c'est la reference de l'entrée. Si pas de PR (commit direct), utiliser le SHA court en fallback.
   - Si `gh` echoue ou est indisponible, utiliser le SHA seul — ne pas bloquer la generation.
7. **Reformuler court** — pour les commits restants, appliquer la section "Rediger pour le consommateur" de `${CLAUDE_SKILL_DIR}/reference.md` et sa sous-section "Règles de rédaction". Les entrées issues des blocs de PR ne sont pas reformulees, mais la consolidation en etat final s'applique a l'ensemble : deux PRs de la meme release qui touchent le meme artefact donnent une seule entrée.
   - Chaque entrée tient sur **une seule ligne** et se termine par sa ou ses references entre parentheses avec un lien Markdown explicite (voir section "References dans les entrées" de `${CLAUDE_SKILL_DIR}/reference.md`). L'URL de base du remote est detectee a l'étape 1.

Affiche les entrées classees avant de continuer :

```
**Changements detectes**

### Added
- [entrée courte reformulee] ([#15](url/pull/15))

### Fixed
- [entrée courte reformulee] ([`9a8b7c6`](url/commit/9a8b7c6))

[N] commits exclus (techniques, merges, fixups...)
```

Ne pas demander de confirmation ici — la confirmation unique a lieu a l'étape 4, sur le resultat final. Si un classement est ambigu, le signaler dans l'affichage (marqueur `⚠️`) pour que l'utilisateur puisse corriger a l'étape 4.

## Étape 2.5 — Auditer la cohérence historique (releases uniquement)

**Executer cette étape uniquement si une version est publiee** (argument fourni a l'étape 1) **ou si l'utilisateur le demande explicitement.** En mode `[Unreleased]`, passer directement a l'étape 3 — l'audit systématique coutait plusieurs appels `gh` a chaque run pour un historique qui n'a pas bouge.

Vérifier que le CHANGELOG existant ne contient pas d'entrées mal placees : une PR mergee apres la date d'un tag ne peut pas figurer sous la section de ce tag.

Procédure (voir `${CLAUDE_SKILL_DIR}/reference.md` section "Cohérence versions/dates") :

1. Lister les sections versionnees sans charger le fichier — `grep -n '^## \[' CHANGELOG.md` ne renvoie que les titres et leurs numéros de ligne.
2. Pour chaque section versionnee `[X.Y.Z] - YYYY-MM-DD`, récupérer la date du tag correspondant via `git log -1 --format=%aI v<X.Y.Z>` (fallback sans prefixe `v`). Si le tag n'existe pas, passer la section — pas d'audit possible.
3. Extraire les entrées de la section a auditer, une section a la fois — jamais le fichier entier (remplacer la version, points echappes) :
   ```
   sed -n '/^## \[1\.5\.0\]/,/^## \[/{/^## \[/d;/^\[[^]]*\]: /d;p;}' CHANGELOG.md
   ```
4. Pour chaque entrée extraite, extraire la reference (PR ou SHA) et récupérer sa date :
   - PR : `gh pr view <N> --json mergedAt --jq .mergedAt`
   - SHA : `git log -1 --format=%aI <sha>`
5. Si la date de la reference est **posterieure** a la date du tag, l'entrée doit être deplacee vers `[Unreleased]`.

Si des entrées mal placees sont detectees, les lister clairement :

```
Entrées mal placees (a deplacer vers [Unreleased]) :

- Section [0.1.0] (tag du YYYY-MM-DD) :
  - PR #N (mergee le YYYY-MM-DD) : "texte de l'entrée"
```

Integrer la reorganisation proposee au recap de l'étape 4 — pas de confirmation séparée ici. Cette étape est rapide si le fichier est sain — la mentionner brievement et passer a l'étape suivante.

## Étape 3 — Generer / mettre a jour le CHANGELOG

### Cas 1 : le fichier n'existe pas

Creer le fichier complet avec :
- Le header standard (voir referentiel : "Structure globale du CHANGELOG")
- La section appropriee (`[Unreleased]` ou `[X.Y.Z] - YYYY-MM-DD`)
- Les liens de comparaison en bas

### Cas 2 : le fichier existe

**Ne jamais lire `CHANGELOG.md` en entier** — il grossit a chaque release et seuls l'en-tete (le format) et la section `[Unreleased]` (les entrées a modifier) sont nécessaires. Charger dans cet ordre :

1. **Bornes des sections** — `grep -n -m 2 '^## \[' CHANGELOG.md` : la 1re occurrence est `## [Unreleased]`, la 2e est l'en-tete de la version la plus récente.
2. **En-tete + `[Unreleased]`** — `Read` sur `CHANGELOG.md` avec `limit` = numéro de ligne de la 2e occurrence. Cette lecture bornee est aussi le préalable exige par `Edit`. Ne pas reecrire le fichier avec `Write` : ecraser le fichier imposerait de l'avoir lu integralement.
3. **Liens de comparaison** — `grep -n -m 2 -E '^\[[^]]+\]: ' CHANGELOG.md` : les deux premières definitions (`[Unreleased]` et la dernière version) donnent le pattern d'URL et la ligne a modifier.

Puis modifier avec `Edit` :
- Si **version specifiee** : créer une nouvelle section `[X.Y.Z] - YYYY-MM-DD` sous `[Unreleased]` (Edit ancre sur `## [Unreleased]`), y deplacer les entrées, vider `[Unreleased]`
- Si **pas de version** : inserer/mettre a jour les entrées dans `[Unreleased]`
- Mettre a jour les liens de comparaison en bas du fichier (Edit ancre sur la ligne `[Unreleased]: ...`, puis insertion de la nouvelle definition de version juste apres)

### Règles

- Respecter l'ordre impose des types : `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`
- Ne pas inclure les types sans entrées
- Breaking changes prefixes par `**BREAKING**` ; si la release entiere impose une migration, la remonter en blockquote sous l'en-tete de version (voir referentiel : "Notes de deploiement")
- Les notes de deploiement (variables d'environnement requises, migrations, version minimale d'un service partenaire) restent dans le CHANGELOG — voir referentiel : "Notes de deploiement"
- Format de version `[MAJOR.MINOR.PATCH]` sans prefixe `v` dans les titres de section
- En-tete de version : si le tag existe (map de l'étape 1), utiliser le lien inline `## [X.Y.Z](https://github.com/{owner}/{repo}/releases/tag/{tagRef}) - YYYY-MM-DD`. Si le tag n'existe pas, texte brut `## [X.Y.Z] - YYYY-MM-DD`. `[Unreleased]` n'est jamais linke.
- Dates au format ISO 8601 (`YYYY-MM-DD`)

## Étape 4 — Afficher le resultat et confirmer

Affiche le contenu complet du fichier en creation (Cas 1), le diff seul en mise a jour (Cas 2) — jamais l'intégralité d'un CHANGELOG existant, qui n'a d'ailleurs pas ete chargée.

Demande confirmation avant d'ecrire :

```
J'ecris `CHANGELOG.md` ([créé / mis a jour]) ?
```

Une fois confirme :
- Ecrire le fichier
- Commit avec le format : `📝 docs: mettre a jour le CHANGELOG` (ou `📝 docs: créer le CHANGELOG` si première creation)

## Étape 5 — Proposer la suite

```
---
CHANGELOG mis a jour. En contexte release : retour a `/pipe-release`.
```

---

## Input utilisateur

$ARGUMENTS
