---
name: pipe-tag
description: Creer et pousser le tag git annote d'une release, apres merge de la PR et deploiement.
disable-model-invocation: true
argument-hint: "[v1.2.3]"
---

**Un tag de release est annoté, posé sur la branche de production à jour, et porte les notes du CHANGELOG.** Hors cadre (pre-release à arbitrer, tag à supprimer, doute SemVer) : Read `${CLAUDE_SKILL_DIR}/reference.md`.

## Contexte

- Branche courante : !`git branch --show-current`
- Dernier tag : !`git describe --tags --abbrev=0`
- Statut : !`git status --short`

## Étape 0 — Vérifications

- Branche à tagger : Read `.claude/skills/workflow-config/SKILL.md` — « Branche de production », sinon « Branche par défaut » (fichier absent : `.claude/skills/tech-stack/SKILL.md`, config legacy ; sinon `main`)
- Remote `origin` ; branche courante = branche à tagger (jamais une feature branch ni l'intégration) ; `git status --short` vide. Un échec → une ligne, stop
- `git pull --ff-only origin <branche>` avant toute détection de version ; divergence → stop

## Étape 1 — Version

Format `vMAJOR.MINOR.PATCH` (trois composants, `v` minuscule, pre-release `-alpha.N` / `-beta.N` / `-rc.N`).

- Argument (`v1.2.3` ou `1.2.3`) → cible, `v` ajouté si absent en le disant
- Sans argument → `bash "${CLAUDE_SKILL_DIR}/../../shared/scripts/detect-version.sh"` (dernière version publiée du CHANGELOG) préfixée de `v` ; rien → demande la version, stop si aucune
- `git tag -l "vX.Y.Z"` non vide → stop

Affiche : `Version cible **vX.Y.Z** · dernier tag [tag ou "aucun"]`

## Étape 2 — Notes

`bash "${CLAUDE_SKILL_DIR}/../../shared/scripts/changelog-section.sh" X.Y.Z` → corps du message ; vide → message `Release vX.Y.Z` seul et `(aucune note)` au récap.

## Étape 3 — Confirmer

Tracker Jira ou Linear avec « Statut ticket à la release » renseigné :

- `bash "${CLAUDE_SKILL_DIR}/../../shared/scripts/list-tickets.sh" <dernier-tag>..HEAD` (tout l'historique sans tag), complété par les clés citées dans les corps des PR mergées de la plage (MCP de la plateforme)
- Chaque clé vérifiée sur le tracker (MCP `mcp__linear__` ou `mcp__atlassian__`) : introuvable → exclue et listée à part ; déjà au statut cible → listée comme telle, non modifiée

```
**Tag vX.Y.Z** — annoté, message `Release vX.Y.Z`

[notes, ou "(aucune note)"]

[si tracker] Tickets qui passeront à l'état [statut] : PROJ-42, PROJ-45 (ou "(aucun ticket détecté)")
[si tracker] Ignorés — introuvables : PROJ-99 · déjà [statut] : PROJ-40

Je crée et pousse ce tag ?
```

## Étape 4 — Tagger, pousser, synchroniser

1. `git tag -a vX.Y.Z -m "Release vX.Y.Z` + ligne vide + notes + `"` (sans notes : `-m "Release vX.Y.Z"` seul)
2. `git push origin vX.Y.Z`
3. Tracker configuré avec statut → pour chaque ticket retenu à l'étape 3, pose le statut via le MCP (`mcp__atlassian__` ou `mcp__linear__`) ; un échec est signalé et n'arrête ni les autres ni le skill

```
Tag vX.Y.Z créé et poussé sur origin. Pipeline terminé.
```

---

## Input utilisateur

$ARGUMENTS
