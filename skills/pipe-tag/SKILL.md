---
name: pipe-tag
description: Creer et pousser un tag git annote pour une release. Verifie la branche principale, detecte la version depuis CHANGELOG.md ou argument, cree un tag annote semantique. Utiliser apres merge de la PR sur main.
model: sonnet
argument-hint: "[v1.2.3]"
---

## Contexte

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/../_workflow-persona/SKILL.md` avant de commencer.

- Branche courante : !`git branch --show-current`
- Dernier tag : !`git describe --tags --abbrev=0`
- Statut repo : !`git status --short`

---

## Etape 0 — Verifications

Utilise Read pour charger `.claude/skills/tech-stack/SKILL.md` si le fichier existe, pour identifier la branche par defaut du projet. Si absent, utiliser `main` comme valeur par defaut.

Avant de continuer, verifie :

- [ ] Le repo a un remote `origin` configure (`git remote get-url origin`)
- [ ] La branche courante est la branche par defaut du projet — on ne tague jamais une feature branch
- [ ] Il n'y a pas de changements non commites (`git status --short` vide)

Si une verification echoue, signale-le clairement et arrete-toi.

## Etape 1 — Determiner la version cible

Utilise Read pour charger `reference.md` avant de valider le format.

**Si un argument est fourni** (ex: `v1.2.3` ou `1.2.3`) : utiliser cet argument comme version cible. Si le prefixe `v` est absent, l'ajouter automatiquement et en informer l'utilisateur.

**Si aucun argument** : detecter depuis `CHANGELOG.md` —
- Lire le fichier avec Read
- Extraire la derniere version publiee (format `## [X.Y.Z]`, exclure `[Unreleased]`)
- Ajouter le prefixe `v` pour obtenir `vX.Y.Z`
- Proposer cette version comme cible

Afficher :

```
Version cible : vX.Y.Z
Dernier tag existant : [tag ou "aucun"]
```

Verifier que le tag `vX.Y.Z` n'existe pas deja (`git tag -l "vX.Y.Z"`). Si le tag existe deja, signaler l'erreur et s'arreter.

## Etape 2 — Extraire les notes de release

Lire `CHANGELOG.md` avec Read et extraire le contenu de la section correspondant a la version cible (`## [X.Y.Z]`).

Si la section n'existe pas dans le CHANGELOG, les notes de release seront vides — le message du tag se limitera a `Release vX.Y.Z`.

## Etape 3 — Confirmer avant de tagger

Afficher le recapitulatif :

```
---
Tag a creer :

  Version : vX.Y.Z
  Type    : annote
  Message : Release vX.Y.Z

  Notes :
  [contenu extrait du CHANGELOG ou "(aucune note)" si section absente]
---
Je cree et pousse le tag vX.Y.Z ?
```

Attendre la confirmation explicite avant de continuer.

## Etape 4 — Creer et pousser le tag

1. Creer le tag annote avec les notes extraites a l'etape 2 comme corps du message. Si des notes sont disponibles, utiliser le format multi-ligne :
   ```
   git tag -a vX.Y.Z -m "Release vX.Y.Z

   [notes de release extraites du CHANGELOG]"
   ```
   Si aucune note, utiliser simplement :
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
Tag vX.Y.Z publie. Pipeline termine.
```

---

## Input utilisateur

$ARGUMENTS
