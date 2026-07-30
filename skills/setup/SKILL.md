---
name: setup
description: Configurer un projet pour le workflow AI-Driven Development : CLAUDE.md, workflow-config, hooks, scripts, plans, specs.
disable-model-invocation: true
---

## Etape 0 — Diagnostic

Analyse l'etat actuel du projet et identifie ce qui manque :

- [ ] `CLAUDE.md` existe a la racine
- [ ] `.claude/skills/workflow-config/SKILL.md` est rempli (pas de placeholders `<!-- -->`)
- [ ] `.claude/settings.json` existe avec des hooks configures — verifie chaque type separement (SessionStart, PreToolUse, PostToolUse, Stop) : un projet configure par une version anterieure a les trois derniers mais pas le premier
- [ ] Chaque hook de `.claude/settings.json` pointe vers un script qui **existe et est executable** — un hook cable vers un fichier absent ne fait rien, et un PostToolUse casse tue le formatage automatique en silence :

  ```bash
  jq -r '.hooks | to_entries[] | .value[].hooks[].command' .claude/settings.json 2>/dev/null \
    | awk '{print $2}' | sort -u \
    | while read -r f; do [ -x "$f" ] && echo "ok $f" || echo "KO $f"; done
  ```

- [ ] `.claude/scripts/check-specs.sh` existe (check outille lance par `/pipe-review`)
- [ ] `.claude/plans/` existe
- [ ] `docs/specs/` existe avec son index `README.md`
- [ ] Aucun autre fichier de `.claude/skills/` ne contient de placeholders `<!-- ... -->`

Affiche un recap :

```
## Diagnostic — [nom du projet]

✅ CLAUDE.md
❌ workflow-config (manquant)
❌ hooks (non configures)
❌ hooks (PostToolUse cable sur .claude/hooks/post-tool-use.sh — script absent)
...
```

Un hook dont le script est absent ou non executable compte comme ❌, meme si `settings.json` le declare.

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

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/hooks-reference.md`.

### Scripts universels — copier, ne jamais reecrire

Ces scripts n'ont aucune variable projet : ce qui varie d'un projet a l'autre passe en **arguments** depuis `settings.json`. Une seule version est donc correcte, et `cp` ne se trompe pas d'echappement la ou une recopie manuelle le peut. Cree les repertoires puis copie :

```bash
mkdir -p .claude/hooks .claude/scripts
cp "${CLAUDE_SKILL_DIR}/scripts/session-start.sh"  .claude/hooks/
cp "${CLAUDE_SKILL_DIR}/scripts/pre-tool-use.sh"   .claude/hooks/
cp "${CLAUDE_SKILL_DIR}/scripts/post-tool-use.sh"  .claude/hooks/
cp "${CLAUDE_SKILL_DIR}/scripts/stop.sh"           .claude/hooks/
cp "${CLAUDE_SKILL_DIR}/scripts/check-specs.sh"    .claude/scripts/
chmod +x .claude/hooks/*.sh .claude/scripts/*.sh
```

Les 4 hooks de `settings.json` pointent vers ces scripts : aucun ne doit etre cable vers un fichier que cette etape ne copie pas.

Si un fichier existe deja, compare-le a la source : identique → ne rien faire ; different → signale que le projet a une version modifiee et demande avant d'ecraser (elle a pu etre adaptee volontairement).

### settings.json — copier le template, remplacer les placeholders

Ne genere pas ce JSON de tete : copie le template, puis remplace ses placeholders.

```bash
cp "${CLAUDE_SKILL_DIR}/settings-template.json" .claude/settings.json
```

Les 4 hooks y pointent deja vers les scripts copies. Ce qui varie par projet, c'est uniquement leurs **arguments** :

| Placeholder | Valeur, depuis `workflow-config` |
|-------------|-----------------------------------|
| `<EXTENSIONS>` | extensions a formater, separees par `\|`, sans point ni antislash (ex `ts\|tsx\|js`) — tableau « Valeurs par stack » de `${CLAUDE_SKILL_DIR}/hooks-reference.md` |
| `<COMMANDE_FORMAT>` | commande **Format** — sans chemin de fichier, le hook l'ajoute |
| `<COMMANDE_TEST>` | commande **Test** |

Ce que fait chaque hook :

- **SessionStart** (pas de matcher) — `session-start.sh`, sans argument : injecte l'index des specs
- **PreToolUse** (matcher `Bash`) — `pre-tool-use.sh`, sans argument : bloque les commandes dangereuses
- **PostToolUse** (matcher `Write|Edit`) — `post-tool-use.sh '<EXTENSIONS>' '<COMMANDE_FORMAT>'` : formate le fichier ecrit
- **Stop** (pas de matcher) — `stop.sh <COMMANDE_TEST>` : tests avant de considerer la tache finie

Apres ecriture, verifie qu'aucun `<...>` ne subsiste dans `.claude/settings.json` et rejoue le controle d'existence de l'etape 0 : un hook cable vers un script absent ne signale rien, le PostToolUse en particulier echoue en silence.

`check-specs.sh` n'est reference dans aucun hook : c'est `/pipe-review` qui l'appelle dans ses checks outilles.

Le hook SessionStart est ce qui rend les specs **effectivement** lues : sans lui, leur consultation depend de la bonne volonte du LLM. Il est inerte tant que `docs/specs/README.md` n'existe pas — installe-le meme sur un projet qui n'a pas encore de spec. Lui et `check-specs.sh` requierent `jq` : si l'outil est absent du systeme, signale-le et installe quand meme.

Si un `.claude/settings.json` existe deja, merge les hooks du template sans ecraser les permissions ou MCP existants.

Affiche la config generee et demande confirmation avant d'ecrire.

## Etape 4 — Repertoires

Cree les repertoires manquants :

- `.claude/plans/` — pour les plans generes par `/pipe-plan`
- `.claude/rules/` — pour les rules contextuelles futures
- `docs/specs/` — pour les specs de features generees par `/pipe-spec`

`.claude/hooks/` et `.claude/scripts/` ont deja ete crees a l'etape 3 avec les scripts.

Ajoute `.claude/plans/` a `.gitignore` si ce n'est pas deja fait (les plans sont des documents de travail ephemeres). `docs/specs/`, au contraire, est **versionne** : ne jamais l'ignorer.

Cree l'index `docs/specs/README.md` s'il manque, en chargeant le format depuis `${CLAUDE_SKILL_DIR}/../pipe-spec/index-format.md`. Laisse-le vide : n'ecris aucune spec depuis `/setup`, chacune exige un cadrage avec l'utilisateur.

Sur un projet qui a **deja des features**, signale le rattrapage — sans lui, les specs n'arriveront qu'au rythme des futurs tickets :

```
Ce projet a deja des features livrees. Pour les documenter en partant des plus
rentables : `/pipe-spec` sans argument (inventaire priorise, une feature par passe).
```

## Etape 5 — Recap final

```
## Setup termine — [nom du projet]

### Configure
- ✅ CLAUDE.md
- ✅ workflow-config (lint: [cmd], test: [cmd], ...)
- ✅ hooks (SessionStart, PreToolUse, PostToolUse, Stop) — scripts copies dans .claude/hooks/
- ✅ post-tool-use.sh (format: [cmd], extensions: [regex]) + stop.sh (test: [cmd])
- ✅ check-specs.sh (coherence des specs, lance par /pipe-review)
- ✅ .claude/plans/
- ✅ .claude/rules/
- ✅ docs/specs/ (+ index)

### Pipeline disponible
Cycle : /pipe-spec → [validation humaine de la spec] → /pipe-plan → /pipe-test → [review humaine des tests] → /pipe-code (session neuve) → /pipe-review (session neuve) → [review humaine du code] → /pipe-commit → /pipe-pr
Reprise a tout moment : /pipe-ship [ticket]
Release : /pipe-release → [merge + deploiement] → /pipe-tag

### Prochaine etape
Lance `/pipe-spec [ticket]` pour demarrer un cycle par le cadrage de la feature.
```

---

## Input utilisateur

$ARGUMENTS
