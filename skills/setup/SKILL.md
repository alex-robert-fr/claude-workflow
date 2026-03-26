---
name: setup
description: Configurer un projet pour le workflow AI-Driven Development. Scaffolde CLAUDE.md, workflow-config, hooks, plans et rules en une seule passe. Utiliser sur un nouveau projet ou pour completer une config existante.
---

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/../_workflow-persona/SKILL.md` avant de commencer.

---

## Etape 0 — Diagnostic

Analyse l'etat actuel du projet et identifie ce qui manque :

- [ ] `CLAUDE.md` existe a la racine
- [ ] `.claude/skills/workflow-config/SKILL.md` est rempli (pas de placeholders `<!-- -->`)
- [ ] `.claude/skills/tech-stack/SKILL.md` est rempli (pas de placeholders `<!-- -->`)
- [ ] `.claude/settings.json` existe avec des hooks configures
- [ ] `.claude/plans/` existe
- [ ] `.mcp.exemple.json` existe

Affiche un recap :

```
## Diagnostic — [nom du projet]

✅ CLAUDE.md
❌ workflow-config (manquant)
❌ hooks (non configures)
⚠️ tech-stack (placeholders non remplis)
...
```

Ne traite que ce qui manque. Confirme la liste des actions avant de commencer.

## Etape 1 — CLAUDE.md

Si `CLAUDE.md` n'existe pas, genere-le avec le strict minimum :

- Nom du projet
- Description courte (une phrase)
- Stack principale (detectee depuis package.json, Cargo.toml, go.mod, etc.)
- Regles critiques evidentes (monorepo, strict mode, etc.)

Si `CLAUDE.md` existe deja, ne le modifie pas.

## Etape 2 — workflow-config

Si `.claude/skills/workflow-config/SKILL.md` n'existe pas ou contient des placeholders, pose les questions pour le remplir :

1. **Plateforme Git** : GitHub, GitLab ou Gitea ? (detecte depuis `git remote -v`)
2. **Issue tracker** : GitHub Issues, Jira, Linear ? (detecte depuis les MCP configures)
3. **Branche par defaut** : main, develop, master ? (detecte depuis `git symbolic-ref refs/remotes/origin/HEAD`)
4. **Commande lint** : biome check, eslint, etc. ? (detecte depuis package.json scripts)
5. **Commande format** : biome format --write, prettier --write, etc. ?
6. **Commande test** : vitest, jest, npm test, etc. ?
7. **Commande build** : tsc --noEmit, npm run build, etc. ?
8. **Notification** : canal Slack, aucun ?

Propose des valeurs detectees automatiquement, demande confirmation, puis ecris le fichier.

## Etape 3 — tech-stack

Si `.claude/skills/tech-stack/SKILL.md` contient des placeholders, propose de les remplir a partir de ce qui a ete detecte a l'etape 2.

## Etape 4 — Hooks

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/hooks-reference.md` pour les templates de hooks.

Genere `.claude/settings.json` avec les hooks adaptes au projet. Utilise les commandes definies dans `workflow-config` pour les hooks PostToolUse et Stop.

**Structure a generer :**

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "[script de blocage des commandes dangereuses]"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "[commande de lint/format du projet]"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "[commande de test du projet]"
          }
        ]
      }
    ]
  }
}
```

Si un `.claude/settings.json` existe deja, merge les hooks sans ecraser les permissions ou MCP existants.

Affiche la config generee et demande confirmation avant d'ecrire.

## Etape 5 — Repertoires

Cree les repertoires manquants :

- `.claude/plans/` — pour les plans generes par `/pipe-plan`
- `.claude/rules/` — pour les rules contextuelles futures

Ajoute `.claude/plans/` a `.gitignore` si ce n'est pas deja fait (les plans sont des documents de travail ephemeres).

## Etape 6 — MCP

Si `.mcp.exemple.json` n'existe pas et que des MCP sont utilises dans les skills, propose de lancer la logique de `/setup-mcp`.

## Etape 7 — Recap final

```
## Setup termine — [nom du projet]

### Configure
- ✅ CLAUDE.md
- ✅ workflow-config (lint: [cmd], test: [cmd], ...)
- ✅ hooks (PreToolUse, PostToolUse, Stop)
- ✅ .claude/plans/
- ✅ .claude/rules/

### Pipeline disponible
/pipe-hello → /pipe-plan → /pipe-code → /pipe-review → /pipe-test → /pipe-pr → /pipe-notifier

### Prochaine etape
Lance `/pipe-hello` pour commencer ta session de travail.
```

---

## Input utilisateur

$ARGUMENTS
