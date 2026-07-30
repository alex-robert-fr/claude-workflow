---
name: setup
description: Configurer un projet pour le workflow AI-Driven Development. Scaffolde CLAUDE.md, workflow-config, hooks, plans et rules en une seule passe, et remplit les placeholders des templates projet. Utiliser sur un nouveau projet ou pour completer une config existante.
disable-model-invocation: true
---

## Etape 0 — Diagnostic

Analyse l'etat actuel du projet et identifie ce qui manque :

- [ ] `CLAUDE.md` existe a la racine
- [ ] `.claude/skills/workflow-config/SKILL.md` est rempli (pas de placeholders `<!-- -->`)
- [ ] `.claude/settings.json` existe avec des hooks configures — verifie chaque type separement (SessionStart, PreToolUse, PostToolUse, Stop) : un projet configure par une version anterieure a les trois derniers mais pas le premier
- [ ] `.claude/plans/` existe
- [ ] `docs/specs/` existe avec son index `README.md`
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
- Section **Specs** : le pointeur qui rend la doc de features decouvrable — sans lui, personne ne va la lire

```markdown
## Specs

Chaque feature a une spec dans `docs/specs/` : intention, comportement attendu, hors-scope,
decisions et points d'entree techniques. **Avant de modifier une feature, lire sa spec**
(index : `docs/specs/README.md`) plutot que de parcourir le code.
Les specs sont ecrites et maintenues par `/pipe-spec`.
```

Si `CLAUDE.md` existe deja, verifie qu'il contient ces deux sections (Git et Specs). Si l'une manque, propose de l'ajouter.

## Etape 2 — workflow-config

Si `.claude/skills/workflow-config/SKILL.md` n'existe pas, utilise Read pour charger `${CLAUDE_SKILL_DIR}/workflow-config-template.md` comme squelette. Si le fichier existe mais contient des placeholders, pose les questions pour le remplir :

1. **Plateforme Git** : GitHub, GitLab ou Gitea ? (detecte depuis `git remote -v`)
2. **Issue tracker** : GitHub Issues, Jira, Linear ? (detecte depuis les MCP configures)
3. **Branche par defaut** (base des features) : main, develop, master ? (detecte depuis `git symbolic-ref refs/remotes/origin/HEAD`) — et **branche de production** (cible des releases) si le projet en a une distincte (ex: develop → main)
4. **Commande lint** : biome check, eslint, etc. ? (detecte depuis package.json scripts)
5. **Commande format** : biome format --write, prettier --write, etc. ?
6. **Commande test** : vitest, jest, npm test, etc. ?
7. **Commande build** : tsc --noEmit, npm run build, etc. ?
8. **Notification** : canal Slack, aucun ?

Les sections Stack technique, Architecture et Nommage du template se remplissent a partir de ce qui est detecte (package.json, structure des dossiers, configs). Propose des valeurs detectees automatiquement, demande confirmation, puis ecris le fichier.

Si le projet a encore un `.claude/skills/tech-stack/SKILL.md` (config legacy), propose de fusionner son contenu dans `workflow-config` et de le supprimer.

Meme mecanique pour tout autre fichier de `.claude/skills/` contenant des placeholders `<!-- ... -->` (detecte a l'etape 0) : proposer une valeur detectee automatiquement, poser une question courte si rien n'est detectable, confirmer, puis remplacer le placeholder. Ne jamais toucher aux champs deja remplis.

## Etape 3 — Hooks

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/hooks-reference.md` pour les templates de hooks.

Genere `.claude/settings.json` avec les hooks adaptes au projet. Utilise les commandes definies dans `workflow-config` pour les hooks PostToolUse et Stop.

La structure complete des hooks est dans `hooks-reference.md` (deja charge). Genere les 4 types :

- **SessionStart** — injecte l'index des specs (`docs/specs/README.md`) dans le contexte de chaque session
- **PreToolUse** (Bash) — bloque les commandes dangereuses
- **PostToolUse** (Write|Edit) — lint/format automatique avec la commande de `workflow-config`
- **Stop** — tests avant de terminer

Le hook SessionStart est ce qui rend les specs **effectivement** lues : sans lui, leur consultation depend de la bonne volonte du LLM. Le script est inerte tant que `docs/specs/README.md` n'existe pas — genere-le meme sur un projet qui n'a pas encore de spec. Il requiert `jq` : si l'outil est absent du systeme, signale-le et installe le hook quand meme (il sortira en erreur silencieuse).

Si un `.claude/settings.json` existe deja, merge les hooks sans ecraser les permissions ou MCP existants.

Affiche la config generee et demande confirmation avant d'ecrire.

## Etape 4 — Repertoires

Cree les repertoires manquants :

- `.claude/plans/` — pour les plans generes par `/pipe-plan`
- `.claude/rules/` — pour les rules contextuelles futures
- `docs/specs/` — pour les specs de features generees par `/pipe-spec`

Ajoute `.claude/plans/` a `.gitignore` si ce n'est pas deja fait (les plans sont des documents de travail ephemeres). `docs/specs/`, au contraire, est **versionne** : ne jamais l'ignorer.

Cree l'index `docs/specs/README.md` s'il manque, en chargeant le format depuis `${CLAUDE_SKILL_DIR}/../pipe-spec/reference.md` (section « Index »). Sur un projet existant qui a deja des features, ne les documente pas ici : les specs se remplissent au fil des cycles, ou a la demande via `/pipe-spec <nom de feature>`.

## Etape 5 — Recap final

```
## Setup termine — [nom du projet]

### Configure
- ✅ CLAUDE.md
- ✅ workflow-config (lint: [cmd], test: [cmd], ...)
- ✅ hooks (SessionStart, PreToolUse, PostToolUse, Stop)
- ✅ .claude/plans/
- ✅ .claude/rules/
- ✅ docs/specs/ (+ index)

### Pipeline disponible
Cycle : /pipe-spec → /pipe-plan → /pipe-test → [review humaine des tests] → /pipe-code (session neuve) → /pipe-review (session neuve, review humaine) → /pipe-commit → /pipe-pr
Reprise a tout moment : /pipe-ship [ticket]
Release : /pipe-release → [merge + deploiement] → /pipe-tag

### Prochaine etape
Lance `/pipe-spec [ticket]` pour demarrer un cycle par le cadrage de la feature.
```

---

## Input utilisateur

$ARGUMENTS
