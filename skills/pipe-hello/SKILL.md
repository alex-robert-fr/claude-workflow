---
name: pipe-hello
description: Briefing de debut de session. Affiche le contexte projet, le travail en cours et l'etat du repo. Utiliser en debut de session de travail.
model: haiku
allowed-tools: Bash(git *), Bash(gh *), Bash(find *)
---

## Contexte

- Branche : !`git branch --show-current`
- Status : !`git status --short`
- Dernier commit : !`git log -1 --oneline`
- Branches locales : !`git branch`
- Plans : !`find .claude/plans -name "*.md" -type f`
- PRs ouvertes : !`gh pr list --state open --limit 10`

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/../_workflow-persona/SKILL.md` avant de commencer.

---

## Etape 1 — Contexte projet

Utilise Read pour charger `.claude/skills/tech-stack/SKILL.md` si disponible pour identifier le projet et sa stack.

Si le fichier n'existe pas, detecte le projet a partir de `package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`, ou tout autre marqueur present.

## Etape 2 — Briefing

A partir **uniquement** du contexte pre-charge ci-dessus et du contexte projet, synthetise un briefing. Ne lance aucune commande supplementaire — toutes les donnees sont deja disponibles.

```
## [Nom du projet] — [stack courte]

**Branche** : [branche] ([propre | N fichiers modifies])
**Dernier commit** : [hash message]

### En cours
- [branche locale] → [PR associee si presente]
- [plan existant] → lancer `/pipe-code [numero]`

---
Qu'est-ce qu'on attaque ?
```

Si rien en cours, affiche simplement l'etat du repo et demande ce qu'on fait.

---

## Input utilisateur

$ARGUMENTS
