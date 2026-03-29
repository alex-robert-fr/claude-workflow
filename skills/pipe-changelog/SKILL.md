---
name: pipe-changelog
description: Generer ou mettre a jour le CHANGELOG.md depuis les commits/tags. Analyse les changements depuis la derniere version et respecte Keep a Changelog + SemVer. Utiliser apres /pipe-test et avant /pipe-pr.
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
2. **Filtrer les exclusions** — supprimer selon les regles du referentiel :
   - Merges (`Merge branch...`, `Merge pull request...`)
   - Fixups/squashs (`fixup!`, `squash!`)
   - Commits CI/CD internes
   - Mises a jour de dependances mineures (sauf impact API publique)
   - Typos de commentaires ou docs internes
3. **Detecter les changesets** — si `.changeset/` existe et contient des fichiers `.md`, les utiliser comme source primaire au lieu des commits
4. **Classer par type** — utiliser le mapping prefixe → type CHANGELOG du referentiel
5. **Enrichir avec les references** — pour chaque commit retenu, trouver la PR associee :
   - Utiliser `gh pr list --state merged --search "SHA" --json number --jq '.[0].number'` pour trouver la PR qui a merge ce commit.
   - Si une PR est trouvee, c'est la reference de l'entree. Si pas de PR (commit direct), utiliser le SHA court en fallback.
   - Si `gh` echoue ou est indisponible, utiliser le SHA seul — ne pas bloquer la generation.
6. **Reformuler** — chaque entree est redigee pour le consommateur, pas copiee du message de commit. Terminer chaque entree par la reference entre parentheses avec un lien Markdown explicite selon le format defini dans `reference.md` (section "References dans les entrees"). L'URL de base du remote est detectee a l'etape 1.

Affiche les entrees classees avant de continuer :

```
Changements detectes :

### Added
- [entree reformulee] ([#15](url/pull/15))

### Changed
- [entree reformulee] ([#8](url/pull/8))

### Fixed
- [entree reformulee] ([`9a8b7c6`](url/commit/9a8b7c6))

[N] commits exclus (merges, fixups, CI...)
```

Demande confirmation si le classement semble correct avant de continuer.

## Etape 3 — Generer / mettre a jour le CHANGELOG

### Cas 1 : CHANGELOG.md n'existe pas

Creer le fichier complet avec :
- Le header standard (voir referentiel, section "Structure globale")
- La section appropriee (`[Unreleased]` ou `[X.Y.Z] - YYYY-MM-DD`)
- Les liens de comparaison en bas

### Cas 2 : CHANGELOG.md existe

Lire le contenu existant et :
- Si **version specifiee** : creer une nouvelle section `[X.Y.Z] - YYYY-MM-DD` sous `[Unreleased]`, y deplacer les entrees, vider `[Unreleased]`
- Si **pas de version** : inserer/mettre a jour les entrees dans `[Unreleased]`
- Mettre a jour les liens de comparaison en bas du fichier

### Regles communes

- Respecter l'ordre impose des types : Added, Changed, Deprecated, Removed, Fixed, Security
- Ne pas inclure les types sans entrees
- Breaking changes prefixes par `**BREAKING**`
- Format de version `[MAJOR.MINOR.PATCH]` sans prefixe `v` dans les titres de section
- En-tete de version : si le tag existe (map de l'etape 1), utiliser le lien inline `## [X.Y.Z](https://github.com/{owner}/{repo}/releases/tag/{tagRef}) - YYYY-MM-DD`. Si le tag n'existe pas, texte brut `## [X.Y.Z] - YYYY-MM-DD`. `[Unreleased]` n'est jamais linke.
- Dates au format ISO 8601 (`YYYY-MM-DD`)

## Etape 4 — Afficher le resultat et confirmer

Affiche le contenu complet du CHANGELOG genere (ou le diff si mise a jour).

Demande confirmation avant d'ecrire :

```
Voici le CHANGELOG genere. Je l'ecris dans CHANGELOG.md ?
```

Une fois confirme :
- Ecris le fichier
- Commite avec le format : `📝 docs: mettre a jour le CHANGELOG` (ou `📝 docs: creer le CHANGELOG`)

## Etape 5 — Proposer la suite

```
---
CHANGELOG mis a jour. Prochaine etape : `/pipe-pr` pour soumettre la branche.
```

---

## Input utilisateur

$ARGUMENTS
