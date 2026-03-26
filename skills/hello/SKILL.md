---
name: hello
description: Briefing de debut de session. Affiche le contexte projet, le travail en cours et l'etat du repo. Utiliser en debut de session de travail.
---

## Etape 1 — Etat du repo

Analyse rapidement :

- Branche courante et son statut (ahead/behind remote)
- Changements non commites (fichiers modifies, stages, non-trackes)
- Dernier commit (message + date relative)

## Etape 2 — Contexte projet

Utilise Read pour charger `.claude/skills/tech-stack/SKILL.md` si disponible pour identifier le projet et sa stack.

Si le fichier n'existe pas, detecte le projet a partir de `package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`, ou tout autre marqueur present.

## Etape 3 — Travail en cours

Detecte :

- **Plans existants** dans `.claude/plans/` (issues en cours de traitement)
- **Branches locales** autres que la branche par defaut (travail en cours)
- **PRs ouvertes** sur le repo (via MCP GitHub, GitLab ou Gitea selon la plateforme)

## Etape 4 — Briefing

Affiche un briefing concis et actionnable :

```
## [Nom du projet] — [stack courte]

**Branche** : main (propre / N changements non commites)
**Dernier commit** : emoji type(scope): description — il y a Xh

### En cours
- feat/42-add-oauth → PR #43 ouverte
- Plan #44 pret → lancer `/code 44`

### Issues ouvertes
- #45 — [titre] (label)
- #46 — [titre] (label)

---
Qu'est-ce qu'on attaque ?
```

Si rien en cours et pas d'issues, affiche simplement l'etat du repo et demande ce qu'on fait.

---

## Input utilisateur

$ARGUMENTS
