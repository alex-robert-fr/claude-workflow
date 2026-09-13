---
name: pipe-changelog
description: Generer ou maintenir CHANGELOG.md depuis les commits : entrées courtes orientees métier, Keep a Changelog, SemVer.
disable-model-invocation: true
argument-hint: [version a tagger ou rien pour Unreleased]
---

**Le CHANGELOG dit ce qui change pour celui qui consomme le projet, une phrase par effet observable** ; le détail technique vit dans les commits et les PR qu'il référence, jamais dans un fichier technique séparé.

Contexte nominal : appliqué par `/pipe-release` depuis la branche d'intégration, avec une version. Invocable seul en mode `[Unreleased]`.

## Étape 0 — Vérifications

- Remote `origin` configuré ; des changements à documenter (commits depuis le dernier tag, ou `[Unreleased]` non vide à publier). Sinon : une ligne, stop
- Un `TECHNICAL_CHANGES.md` à la racine est obsolète : propose sa suppression

## Étape 1 — Contexte de versioning

- Dernier tag : `bash "${CLAUDE_SKILL_DIR}/../../shared/scripts/detect-version.sh" --tag` (rien → première version)
- URL HTTPS du remote (`git@github.com:org/repo.git` → `https://github.com/org/repo`) pour les liens
- Phase : dernier tag `0.x.y` → pré-1.0.0
- Cible : l'argument (`1.3.0`) ou `[Unreleased]`
- Tags existants pour la cible et la version la plus récente (`git tag --list "v${version}"`, repli sans `v`) : un en-tête de version est lié ssi son tag existe

Affiche : `Versioning — dernier tag [tag ou "aucun"] · [pré/post-1.0.0] · cible [version ou "Unreleased"]`

## Étape 2 — Collecter

Read `${CLAUDE_SKILL_DIR}/entree.md` (types, mapping, rédaction, exclusions) et `${CLAUDE_SKILL_DIR}/fichier.md` (structure, sources, cohérence).

1. Commits : `git log <dernier-tag>..HEAD --format="%h %s"` ; filtre selon le mapping et les exclusions, doute → exclu + `⚠️`
2. Blocs `## Changelog` des PR mergées — source primaire : un seul `gh pr list --state merged --limit 50 --json number,body,mergeCommit,headRefName`, PR dont le merge commit est dans la plage ; entrées reprises telles quelles, référence = la PR ; leurs commits sortent de la liste
3. `.changeset/*.md` s'il en existe : source primaire pour les commits restants
4. Commits restants : type Keep a Changelog, référence PR (association locale via le résultat du point 2, jamais un `gh` par commit ; sinon SHA court ; `gh` indisponible → SHA), reformulation pour le consommateur
5. Consolidation en état final sur l'ensemble : deux PR de la même release qui touchent le même artefact → une entrée

Affiche les entrées classées par type avec leurs références, puis `[N] commits exclus`. Pas de confirmation ici.

## Étape 3 — Audit de cohérence (release seulement)

Si une version est publiée (ou sur demande) : une entrée sous `[X.Y.Z]` doit être mergée avant la date du tag. Sections par `grep -n '^## \[' CHANGELOG.md` ; date du tag par `git log -1 --format=%aI v<X.Y.Z>` (tag absent → section ignorée) ; entrées d'une section par `bash "${CLAUDE_SKILL_DIR}/../../shared/scripts/changelog-section.sh" <X.Y.Z>` ; date d'une référence par `gh pr view <N> --json mergedAt --jq .mergedAt` ou `git log -1 --format=%aI <sha>`. Référence postérieure au tag → à déplacer vers `[Unreleased]` ; liste-les, la réorganisation entre dans le récap de l'étape 4.

## Étape 4 — Écrire

Ne jamais lire `CHANGELOG.md` en entier.

- Fichier absent → création complète : en-tête standard, section cible, liens de comparaison (`fichier.md`)
- Fichier présent → `grep -n -m 2 '^## \['` (bornes de `[Unreleased]`), `Read` limité à la 2e borne, `grep -n -m 2 -E '^\[[^]]+\]: '` (liens) ; puis `Edit` seulement, jamais `Write`. Version → nouvelle section `[X.Y.Z] - AAAA-MM-JJ` sous `[Unreleased]` qui reçoit ses entrées, `[Unreleased]` vidé, lien de comparaison inséré ; sans version → entrées dans `[Unreleased]`

Affiche le fichier complet (création) ou le diff (mise à jour), puis : `J'écris CHANGELOG.md ([créé / mis à jour]) ?` Confirmé → écris, commit `📝 docs: mettre à jour le CHANGELOG` (ou `créer`).

## Étape 5 — Suite

```
CHANGELOG mis à jour. En contexte release : retour à /pipe-release.
```

---

## Input utilisateur

$ARGUMENTS
