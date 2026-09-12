---
name: pipe-tag
description: Creer et pousser le tag git annote d'une release, apres merge de la PR et deploiement.
disable-model-invocation: true
argument-hint: "[v1.2.3]"
---

## Contexte

- Branche courante : !`git branch --show-current`
- Dernier tag : !`git describe --tags --abbrev=0`
- Statut repo : !`git status --short`

---

## Étape 0 — Verifications

Utilise Read pour charger `.claude/skills/workflow-config/SKILL.md` si le fichier existe, pour identifier la branche a tagger : champ "Branche de production" s'il est rempli, sinon "Branche par defaut" (si le fichier est absent, essaie `.claude/skills/tech-stack/SKILL.md` — config legacy ; sinon utiliser `main`).

Avant de continuer, verifie :

- [ ] Le repo a un remote `origin` configure (`git remote get-url origin`)
- [ ] La branche courante est la branche identifiee ci-dessus — on ne tague jamais une feature branch ni la branche d'integration
- [ ] Il n'y a pas de changements non commites (`git status --short` vide)

Si une verification echoue, signale-le clairement et arrete-toi.

Puis mets a jour la branche locale avant toute detection de version — on ne tague jamais un HEAD local en retard sur le remote :

```
git pull --ff-only origin <branche-par-defaut>
```

Si le pull echoue (divergence), signale-le et arrete-toi.

## Étape 1 — Determiner la version cible

Format attendu : `vMAJOR.MINOR.PATCH` — trois composants numeriques (`v1.2.0`, jamais `v1.2`), prefixe `v` obligatoire, minuscules, sans espace ni slash. Pre-release : `vX.Y.Z-alpha.1`, `-beta.2`, `-rc.1`. Tag toujours annote (`git tag -a`), jamais leger.

Ne charger `${CLAUDE_SKILL_DIR}/reference.md` que si le cas sort de ce cadre — pre-release a arbitrer, tag existant a supprimer, doute sur le bump SemVer — ou si l'utilisateur demande le detail.

**Si un argument est fourni** (ex: `v1.2.3` ou `1.2.3`) : utiliser cet argument comme version cible. Si le prefixe `v` est absent, l'ajouter automatiquement et en informer l'utilisateur.

**Si aucun argument** : détecter depuis `CHANGELOG.md` sans le lire en entier —
- Extraire le premier titre de section versionnee, qui est la dernière version publiee :
  ```
  grep -m1 -oE '^## \[[0-9]+\.[0-9]+\.[0-9]+\]' CHANGELOG.md
  ```
  Le motif exclut `[Unreleased]` de fait, et tolere un titre linke (`## [1.4.8](url/releases/tag/v1.4.8) - date`).
- Retirer les crochets et ajouter le prefixe `v` pour obtenir `vX.Y.Z`
- Si la commande ne renvoie rien (pas de CHANGELOG, ou aucune version publiee), demander la version a l'utilisateur et s'arreter s'il n'en fournit pas
- Proposer cette version comme cible

Afficher :

```
Version cible **vX.Y.Z** · dernier tag [tag ou "aucun"]
```

Vérifier que le tag `vX.Y.Z` n'existe pas déjà (`git tag -l "vX.Y.Z"`). Si le tag existe déjà, signaler l'erreur et s'arreter.

## Étape 2 — Extraire les notes de release

Extraire la seule section de la version cible, sans charger `CHANGELOG.md` en entier :

```
sed -n '/^## \[1\.2\.3\]/,/^## \[/{/^## \[/d;/^\[[^]]*\]: /d;p;}' CHANGELOG.md
```

- Remplacer `1\.2\.3` par la version cible **sans prefixe `v`, points echappes**
- `/^## \[/d` retire l'en-tete de la section et celui de la section suivante ; `/^\[[^]]*\]: /d` retire le bloc de liens de comparaison en bas de fichier, qui serait ramasse si la version cible est la plus ancienne section
- Sortie vide = section absente : les notes de release sont vides, le message du tag se limite a `Release vX.Y.Z` et le recap de l'étape 3 affiche `(aucune note)`

## Étape 3 — Confirmer avant de tagger

Si le tracker configuré (`.claude/skills/workflow-config/SKILL.md`, champ "Issue tracker") est Jira ou Linear et qu'un "Statut ticket à la release" y est renseigné, calculer aussi la liste des tickets qui seront synchronisés — même motif qu'à l'étape 5, sur la plage `<dernier-tag>..HEAD` (tout l'historique si aucun tag précédent) :

```bash
git log <dernier-tag>..HEAD --format=%B | grep -oE '[A-Z][A-Z0-9]+-[0-9]+' | sort -u
```

Afficher le recapitulatif :

```
**Tag vX.Y.Z** — annote, message `Release vX.Y.Z`

[notes extraites du CHANGELOG, ou "(aucune note)" si section absente]

[si tracker Jira/Linear + statut configuré] Tickets qui passeront à l'état [statut configuré] : PROJ-42, PROJ-45 (ou "(aucun ticket détecté)")

Je crée et pousse ce tag ?
```

Attendre la confirmation explicite avant de continuer.

## Étape 4 — Creer et pousser le tag

1. Creer le tag annote avec les notes extraites a l'étape 2 comme corps du message. Si des notes sont disponibles, utiliser le format multi-ligne :
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

## Étape 5 — Synchroniser le tracker

Ne s'exécute que si le tracker configuré (`.claude/skills/workflow-config/SKILL.md`, champ "Issue tracker") est Jira ou Linear ET qu'un "Statut ticket à la release" y est renseigné. Sinon, passer directement à l'étape suivante sans rien signaler.

Extraire les tickets référencés entre l'ancien tag et le nouveau, même motif qu'à l'étape 3 :

```bash
git log <ancien-tag>..vX.Y.Z --format=%B | grep -oE '[A-Z][A-Z0-9]+-[0-9]+' | sort -u
```

Pour chaque ticket trouvé, appeler le MCP du tracker configuré (`mcp__atlassian__` pour Jira, `mcp__linear__` pour Linear) pour poser son statut sur la valeur configurée.

Si un appel échoue pour un ticket, signaler l'échec et continuer avec les suivants — ne bloque ni les autres tickets ni la suite du skill.

## Étape 6 — Proposer la suite

```
Tag vX.Y.Z créé et poussé sur origin. Pipeline termine.
```

---

## Input utilisateur

$ARGUMENTS
