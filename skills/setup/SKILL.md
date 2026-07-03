---
name: setup
description: Configurer un projet pour le workflow AI-Driven Development. Scaffolde CLAUDE.md, workflow-config, hooks, plans et rules en une seule passe, et remplit les placeholders des templates projet. Utiliser sur un nouveau projet ou pour completer une config existante.
disable-model-invocation: true
---

## Etape 0 — Diagnostic

Analyse l'etat actuel du projet et identifie ce qui manque :

- [ ] `CLAUDE.md` existe a la racine
- [ ] `.claude/skills/workflow-config/SKILL.md` est rempli (pas de placeholders `<!-- -->`)
- [ ] `.claude/settings.json` existe avec des hooks configures
- [ ] `.claude/plans/` existe
- [ ] Aucun autre fichier de `.claude/skills/` ne contient de placeholders `<!-- ... -->`

Affiche un recap :

```
## Diagnostic — [nom du projet]

✅ CLAUDE.md
❌ workflow-config (manquant)
❌ hooks (non configures)
...
```

Ne traite que ce qui manque. Confirme la liste des actions avant de commencer.

## Etape 1 — CLAUDE.md

Si `CLAUDE.md` n'existe pas, genere-le avec le strict minimum :

- Nom du projet
- Description courte (une phrase)
- Stack principale (detectee depuis package.json, Cargo.toml, go.mod, etc.)
- Regles critiques evidentes (monorepo, strict mode, etc.)
- Section **Git** : utilise Read pour charger `${CLAUDE_SKILL_DIR}/../git-conventions/SKILL.md` et inclure les regles clefs dans le CLAUDE.md (format de commit, format de branche, pas de signature `Co-Authored-By`)

Si `CLAUDE.md` existe deja, verifie qu'il contient une section Git avec les regles de `git-conventions`. Si elle manque, propose de l'ajouter.

## Etape 2 — workflow-config

Si `.claude/skills/workflow-config/SKILL.md` n'existe pas, utilise Read pour charger `${CLAUDE_SKILL_DIR}/workflow-config-template.md` comme squelette. Si le fichier existe mais contient des placeholders, pose les questions pour le remplir :

1. **Niveau de projet** : A (produit vivant, pipeline complet) ou B (script/outil, workflow leger) ?
2. **Plateforme Git** : GitHub, GitLab ou Gitea ? (detecte depuis `git remote -v`)
3. **Issue tracker** : GitHub Issues, Jira, Linear ? (detecte depuis les MCP configures)
4. **Branche par defaut** : main, develop, master ? (detecte depuis `git symbolic-ref refs/remotes/origin/HEAD`)
5. **Commande lint** : biome check, eslint, etc. ? (detecte depuis package.json scripts)
6. **Commande format** : biome format --write, prettier --write, etc. ?
7. **Commande test** : vitest, jest, npm test, etc. ?
8. **Commande build** : tsc --noEmit, npm run build, etc. ?
9. **Notification** : canal Slack, aucun ?

Les sections Stack technique, Architecture et Nommage du template se remplissent a partir de ce qui est detecte (package.json, structure des dossiers, configs). Propose des valeurs detectees automatiquement, demande confirmation, puis ecris le fichier.

Si le projet a encore un `.claude/skills/tech-stack/SKILL.md` (config legacy), propose de fusionner son contenu dans `workflow-config` et de le supprimer.

Meme mecanique pour tout autre fichier de `.claude/skills/` contenant des placeholders `<!-- ... -->` (detecte a l'etape 0) : proposer une valeur detectee automatiquement, poser une question courte si rien n'est detectable, confirmer, puis remplacer le placeholder. Ne jamais toucher aux champs deja remplis.

## Etape 3 — Hooks

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/hooks-reference.md` pour les templates de hooks.

Genere `.claude/settings.json` avec les hooks adaptes au projet. Utilise les commandes definies dans `workflow-config` pour les hooks PostToolUse et Stop.

La structure complete des hooks est dans `hooks-reference.md` (deja charge). Genere les 3 types :

- **PreToolUse** (Bash) — bloque les commandes dangereuses
- **PostToolUse** (Write|Edit) — lint/format automatique avec la commande de `workflow-config`
- **Stop** — tests avant de terminer

Si un `.claude/settings.json` existe deja, merge les hooks sans ecraser les permissions ou MCP existants.

Affiche la config generee et demande confirmation avant d'ecrire.

## Etape 4 — Repertoires

Cree les repertoires manquants :

- `.claude/plans/` — pour les plans generes par `/pipe-plan`
- `.claude/rules/` — pour les rules contextuelles futures

Ajoute `.claude/plans/` a `.gitignore` si ce n'est pas deja fait (les plans sont des documents de travail ephemeres).

## Etape 5 — Recap final

```
## Setup termine — [nom du projet]

### Configure
- ✅ CLAUDE.md
- ✅ workflow-config (lint: [cmd], test: [cmd], ...)
- ✅ hooks (PreToolUse, PostToolUse, Stop)
- ✅ .claude/plans/
- ✅ .claude/rules/

### Pipeline disponible
/pipe-plan → /pipe-code → /pipe-review → /pipe-test → /pipe-changelog → /pipe-pr → [merge] → /pipe-tag

### Prochaine etape
Lance `/pipe-plan [issue]` pour demarrer le travail.
```

---

## Input utilisateur

$ARGUMENTS
