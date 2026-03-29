---
name: pipe-tag
description: Creer et pousser un tag git annote pour une release. Verifie la branche principale, detecte la version depuis CHANGELOG.md ou argument, cree un tag annote semantique. Utiliser apres merge de la PR sur main et avant /pipe-notifier.
argument-hint: "[v1.2.3]"
allowed-tools: Bash(git *)
---

## Contexte

- Branche courante : !`git branch --show-current`
- Dernier tag : !`git tag --sort=-version:refname -l "v*" | head -1`
- Tags existants (5 derniers) : !`git tag --sort=-version:refname -l "v*" | head -5`
- Statut repo : !`git status --short`

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/../_workflow-persona/SKILL.md` avant de commencer.

---

## Etape 0 — Verifications

Avant de continuer, verifie :

- [ ] Le repo a un remote `origin` configure (`git remote get-url origin`)
- [ ] La branche courante est la branche principale (`main` ou `master`) — on ne tague jamais une feature branch
- [ ] Il n'y a pas de changements non commites (`git status --short` vide)

Si une verification echoue, signale-le clairement et arrete-toi.

## Etape 1 — Determiner la version cible

**Si un argument est fourni** (ex: `v1.2.3`) : utiliser cet argument comme version cible.

**Si aucun argument** : detecter depuis `CHANGELOG.md` —
- Lire le fichier avec Read
- Extraire la derniere version publiee (format `## [X.Y.Z]`, exclure `[Unreleased]`)
- Proposer cette version comme cible

Afficher :

```
Version cible : vX.Y.Z
Dernier tag existant : [tag ou "aucun"]
```

Verifier que le tag `vX.Y.Z` n'existe pas deja (`git tag -l "vX.Y.Z"`). Si le tag existe deja, signaler l'erreur et s'arreter.

Utilise Read pour charger `reference.md` pour valider le format de la version.

## Etape 2 — Extraire les notes de release

Lire `CHANGELOG.md` avec Read et extraire le contenu de la section correspondant a la version cible (`## [X.Y.Z]`).

Si la section n'existe pas dans le CHANGELOG, utiliser comme message de tag :

```
Release vX.Y.Z
```

## Etape 3 — Confirmer avant de tagger

Afficher le recapitulatif :

```
---
Tag a creer :

  Version : vX.Y.Z
  Type    : annote
  Message : Release vX.Y.Z

  Notes :
  [contenu extrait du CHANGELOG ou message par defaut]
---
Je cree et pousse le tag vX.Y.Z ?
```

Attendre la confirmation explicite avant de continuer.

## Etape 4 — Creer et pousser le tag

1. Creer le tag annote :
   ```
   git tag -a vX.Y.Z -m "Release vX.Y.Z"
   ```

2. Pousser le tag vers le remote :
   ```
   git push origin vX.Y.Z
   ```

Afficher la confirmation :

```
Tag vX.Y.Z cree et pousse sur origin.
```

## Etape 5 — Proposer la suite

```
---
Tag vX.Y.Z publie. Prochaine etape : `/pipe-notifier` pour notifier l'equipe.
```

---

## Input utilisateur

$ARGUMENTS
