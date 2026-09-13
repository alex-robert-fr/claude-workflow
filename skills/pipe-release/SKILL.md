---
name: pipe-release
description: Preparer une release : CHANGELOG métier, puis PR de la branche d'integration vers la production.
disable-model-invocation: true
argument-hint: "[version cible ex: 0.5.2, ou rien pour détecter]"
allowed-tools:
  - Bash(bash "${CLAUDE_SKILL_DIR}/../../shared/scripts/list-tickets.sh" *)
  - Bash(git log *)
  - Bash(git status *)
  - Bash(git tag -l *)
  - Bash(git tag --list *)
---

**Une release, c'est un CHANGELOG committé puis une PR de l'intégration vers la production, sous une seule confirmation.** Le tag vient après le merge et le déploiement (`/pipe-tag`).

## Étape 0 — Vérifications

- Read `.claude/skills/workflow-config/SKILL.md` : « Branche par défaut » = intégration, « Branche de production » = production. Pas de production distincte → le flux release ne s'applique pas (les PR de feature vont en production), stop
- Remote `origin` ; working tree propre ; `git switch <intégration>` puis `git pull --ff-only origin <intégration>` ; `git log origin/<production>..<intégration> --oneline` non vide, sinon rien à livrer. Un échec → une ligne, stop

## Étape 1 — Version

Par priorité : l'argument ; le ticket Jira de version parent des demandes livrées ; SemVer déduit des commits (breaking → MAJOR, ou MINOR en 0.x ; `feat` → MINOR ; que des `fix` → PATCH), proposé et confirmé. `git tag -l vX.Y.Z` vide, sinon stop. Affiche la version retenue.

## Étape 2 — Contenu

Depuis `git log origin/<production>..<intégration>` (merges de PR) :

```
**Release vX.Y.Z** — [intégration] → [production]

- #12 [Feat] Titre (PROJ-42)
- #15 [Fix] Titre (PROJ-45)
```

Tracker Jira ou Linear configuré :

- `bash "${CLAUDE_SKILL_DIR}/../../shared/scripts/list-tickets.sh" origin/<production>..<intégration>` (clés citées dans les commits), complété par les clés citées dans les corps des PR mergées de la plage (MCP de la plateforme)
- Chaque clé vérifiée sur le tracker (MCP `mcp__linear__` ou `mcp__atlassian__`) : titre et statut actuel récupérés ; introuvable → marquée `(introuvable)`, exclue de toute mise à jour
- Affiché en `**Tickets référencés** : PROJ-42 (titre · statut), … · introuvables : …` — informatif, le statut est posé par `/pipe-tag` une fois livré

Issues GitHub : rien, `Closes #N` les ferme au merge.

## Étape 3 — CHANGELOG et specs

- Read `${CLAUDE_SKILL_DIR}/../pipe-changelog/SKILL.md` et applique-le avec la version en argument, sans sa confirmation interne : la confirmation unique de l'étape 4 couvre tout, et un commit local reste réversible. Committe sur l'intégration
- `grep -rn "(à venir)\|(a venir)" docs/specs/` : retire la mention sur les lignes de la version livrée seulement, celles d'une version ultérieure restent. Aucune occurrence ou pas de `docs/specs/` → rien à signaler. Commit avec le CHANGELOG

## Étape 4 — PR de release

Affiche version, PR incluses, extrait du CHANGELOG ; demande une confirmation unique ; puis `git push origin <intégration>` et crée la PR `<intégration>` → `<production>` via le MCP de la plateforme : titre `[Release] vX.Y.Z`, body = section CHANGELOG de la version, PR incluses, version cible.

```
PR de release créée : [URL]
Après merge et déploiement : `/pipe-tag vX.Y.Z` sur [production].
```

---

## Input utilisateur

$ARGUMENTS
