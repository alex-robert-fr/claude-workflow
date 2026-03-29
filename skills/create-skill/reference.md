# Reference exhaustive — Skills Claude Code

Documentation complete de tous les champs, syntaxes et patterns avances.

---

## allowed-tools — syntaxe complete

Declare les outils auto-approuves (sans prompt) pendant l'execution du skill.

| Syntaxe | Exemple | Matche |
|---------|---------|--------|
| Nom d'outil | `Read` | Toutes les utilisations de Read |
| Liste | `Read, Grep, Glob` | Plusieurs outils |
| Bash avec glob | `Bash(npm *)` | Commandes commencant par `npm` |
| Bash exact | `Bash(npm run build)` | Commande exacte |
| Bash pattern | `Bash(git * main)` | `git checkout main`, `git merge main` |
| MCP tous | `mcp__github__*` | Tous les tools du serveur github |
| MCP specifique | `mcp__github__create_issue` | Tool specifique |
| WebFetch domain | `WebFetch(domain:github.com)` | Requetes vers github.com |

### Bash patterns — details

Le word boundary compte :
- `Bash(ls *)` matche `ls -la` (espace avant `*`)
- `Bash(ls*)` matche `ls -la` ET `lsof` (pas d'espace)

Les wildcards peuvent etre n'importe ou :
- `Bash(* --version)` matche `git --version`, `node --version`

---

## context: fork — comportement detaille

Execute le skill dans un sous-agent isole avec son propre contexte.

| Aspect | Sans fork | Avec `context: fork` |
|--------|-----------|---------------------|
| Contexte | Partage avec la conversation | Isole, fenetre separee |
| Historique | Conversation complete | Depart a zero |
| Resultats | Inline dans le chat | Resumes, ajoutes au principal |
| CLAUDE.md | Charge | Charge aussi dans le sous-agent |
| Use case | Reference inline | Taches complexes isolees |

### Requirement critique

Un skill avec `context: fork` **doit** contenir des instructions de tache explicites. Des guidelines seules ne fonctionnent pas :

```yaml
# MAUVAIS — pas de tache
---
context: fork
---
Utilise ces conventions API...
```

```yaml
# BON — tache explicite
---
context: fork
agent: Explore
---
Recherche tous les endpoints API, analyse les patterns et resume les findings.
```

---

## agent — types disponibles

Specifie quel sous-agent execute le skill (requiert `context: fork`).

| Agent | Modele | Outils | Quand utiliser |
|-------|--------|--------|---------------|
| `Explore` | Haiku (rapide) | Lecture seule | Exploration, recherche rapide |
| `Plan` | Herite | Lecture seule | Planification et recherche |
| `general-purpose` | Herite | Tous | Taches complexes (defaut) |
| Custom | Configure | Configure | Agents dans `.claude/agents/` |

Si omis : `general-purpose` par defaut.

---

## model — tiers de modele

Indique le tier de modele recommande pour l'execution du skill. Permet d'optimiser les couts en adaptant la puissance du modele a la complexite de la tache.

### Valeurs possibles

| Valeur | Modele | Usage |
|--------|--------|-------|
| `opus` | Claude Opus | Raisonnement complexe, multi-etapes, generation de code |
| `sonnet` | Claude Sonnet | Taches structurees, reviews, configuration |
| `haiku` | Claude Haiku | Taches simples, affichage, reference pure |

Si omis : pas de recommandation (le modele de la session est utilise).

### Comportement

- **Skills inline** (sans `context: fork`) : le champ sert de **recommandation** pour l'utilisateur. Claude Code ne force pas le modele automatiquement — l'utilisateur choisit de switcher avant d'invoquer.
- **Skills avec `context: fork`** : le champ controle le modele du sub-agent. Note : le type d'agent (`Explore`, `Plan`) peut fixer son propre modele (ex. `Explore` utilise Haiku). Dans ce cas, le type d'agent a la precedence sur `model`.
- **Sub-agents lances par le skill** (via Agent tool) : le skill peut passer `model: "sonnet"` ou `model: "haiku"` dans l'appel Agent pour controler le cout des sous-taches.

### Criteres de choix

| Tier | Criteres | Exemples |
|------|----------|----------|
| `opus` | Raisonnement multi-etapes, generation de code, analyse d'issues, planification technique | `pipe-code`, `pipe-plan`, `create-issue`, `create-skill` |
| `sonnet` | Taches structurees, reviews, generation de texte formate, configuration, audits | `pipe-review`, `pipe-pr`, `pipe-changelog`, `pipe-test`, `setup`, `audit-*` |
| `haiku` | Affichage simple, formatage, reference pure, notifications | `pipe-hello`, `pipe-notifier`, `*-conventions` |

### Grille de categorisation (22 skills)

| Tier | Skills |
|------|--------|
| `opus` | `pipe-code`, `pipe-plan`, `create-issue`, `create-skill` |
| `sonnet` | `pipe-review`, `pipe-pr`, `pipe-changelog`, `pipe-test`, `pipe-commit`, `pipe-tag`, `setup`, `setup-templates`, `setup-ui-ux`, `setup-mcp`, `audit-skills`, `audit-lint`, `audit-naming` |
| `haiku` | `pipe-hello`, `pipe-notifier`, `git-conventions`, `frontend-code-conventions`, `_workflow-persona` |

---

## Hierarchie de decouverte des skills

Par ordre de priorite (le plus haut gagne en cas de conflit de noms) :

| Priorite | Emplacement | Portee |
|----------|-------------|--------|
| 1 | `.claude/skills/<name>/SKILL.md` | Projet courant |
| 2 | `~/.claude/skills/<name>/SKILL.md` | Tous les projets (personnel) |
| 3 | Plugin `skills/<name>/SKILL.md` | Ou le plugin est actif |
| 4 | Skills bundled | Built-in Claude Code |

### Support monorepo

Claude Code decouvre automatiquement les skills dans les sous-repertoires :

```
monorepo/
  .claude/skills/general/SKILL.md        <- charge partout
  packages/frontend/
    .claude/skills/react-utils/SKILL.md  <- charge dans packages/frontend/
```

Quand on travaille dans `packages/frontend/`, les deux skills sont disponibles.

### Repertoires additionnels

```bash
claude --add-dir ../shared-config
```

Charge les skills depuis `../shared-config/.claude/skills/`.

---

## Budget des descriptions

Les descriptions sont chargees dans le contexte pour que Claude sache quels skills existent.

- **Budget dynamique** : 2% de la fenetre de contexte
- **Minimum** : 16 000 caracteres
- **Si depasse** : les skills les moins prioritaires sont exclus

### Override

```bash
SLASH_COMMAND_TOOL_CHAR_BUDGET=50000 claude
```

### Verification

Lancer `/context` pour voir les avertissements si des skills sont exclus.

### Optimisation

- Descriptions concises (20-50 mots)
- `disable-model-invocation: true` sur les skills rarement auto-charges
- `user-invocable: false` sur les skills de reference pure

---

## Variables d'environnement

| Variable | Source | Disponible dans | Usage |
|----------|--------|-----------------|-------|
| `${CLAUDE_SKILL_DIR}` | Claude Code | Contenu du skill | Chemin absolu du repertoire du skill |
| `${CLAUDE_SESSION_ID}` | Claude Code | Contenu du skill | UUID de la session |
| Variables shell | Systeme/user | Commandes `!`...`` | `!`echo $HOME`` |
| Variables custom | `.claude/settings.json` `env` | Commandes `!`...`` | `!`echo $MY_VAR`` |

### Variables custom via settings

```json
{
  "env": {
    "MY_API_KEY": "xxx",
    "MY_SKILL_VAR": "value"
  }
}
```

---

## Error handling dans !`command`

Les commandes dynamiques peuvent echouer. Pattern de fallback :

```markdown
- Status : !`git status --short 2>/dev/null || echo "Pas un repo git"`
- PR : !`gh pr view --json title --jq '.title' 2>/dev/null || echo "Pas de PR active"`
- Version : !`node --version 2>/dev/null || echo "Node non installe"`
```

Si la commande echoue sans fallback, Claude recoit le message d'erreur et peut s'adapter.

---

## Caching et rechargement

- Skills **parses au demarrage** de la session
- Descriptions cachees en memoire, contenu charge a la demande
- **Pas de cache entre sessions** — chaque session relit les fichiers
- Modifier un `SKILL.md` pendant une session : lancer `/reload-plugins` pour prendre en compte
- Nouveaux skills crees pendant une session : visibles apres `/reload-plugins`

---

## Interaction avec CLAUDE.md

### Precedence

Skill actif > CLAUDE.md > Defauts Claude Code

Si CLAUDE.md dit "indentation 2 espaces" mais le skill dit "indentation 4 espaces", le skill gagne.

### Partage de regles

- **Regles persistantes** (toute la session) -> CLAUDE.md
- **Regles par tache** -> Skills
- **Regles par chemin** -> `.claude/rules/*.md` avec frontmatter `paths:`

---

## Frontmatter — controle d'invocation

| Config                           | `/skill` par l'user | Charge auto par Claude |
| -------------------------------- | ------------------- | ---------------------- |
| _(defaut)_                       | oui                 | oui                    |
| `user-invocable: false`          | non                 | oui                    |
| `disable-model-invocation: true` | oui                 | non                    |

## Arguments et variables

| Syntaxe                | Description                          | Exemple                                              |
| ---------------------- | ------------------------------------ | ---------------------------------------------------- |
| `$ARGUMENTS`           | Tous les arguments                   | `/skill Fix auth bug` -> `Fix auth bug`              |
| `$0`, `$1`, `$2`       | Arguments positionnels               | `/skill Button React Vue` -> `$0`=Button, `$1`=React |
| `${CLAUDE_SKILL_DIR}`  | Chemin absolu du repertoire du skill | Pour referencer les fichiers supports                |
| `${CLAUDE_SESSION_ID}` | UUID de la session courante          | Pour logs/fichiers temporaires                       |

Si `$ARGUMENTS` n'est pas dans le contenu, Claude Code l'ajoute automatiquement a la fin.

## Conventions de nommage

- **kebab-case** uniquement, minuscules, chiffres, tirets
- Max 64 caracteres
- Pas d'imbrication (`skills/utils/validators/` = interdit)
- Pas de prefixe inutile (`expert-security` -> `security`)

### Categories

| Type                   | Exemples                              | Frontmatter                      |
| ---------------------- | ------------------------------------- | -------------------------------- |
| Expertise / convention | `branch-convention`, `lint-expertise` | `user-invocable: false`          |
| Action / workflow      | `pr`, `code`, `plan`, `deploy`        | defaut (invocable)               |
| Side effects           | `deploy`, `send-email`                | `disable-model-invocation: true` |
| Contexte partage       | `shared`                              | `user-invocable: false`          |

## Anti-patterns

- Description vague -> jamais charge auto
- Skill >200 lignes sans fichiers supports -> fragmenter
- Frontmatter sans description -> routing impossible
- `context: fork` avec guidelines sans tache explicite -> sous-agent inutile
- `disable-model-invocation: true` sur un skill d'expertise -> jamais utilise
- Fichier plat `nom.md` au lieu de `nom/SKILL.md`
- Valeurs projet-specific dans un skill partage
- Oublier `$ARGUMENTS` sur un skill invocable
- Oublier `argument-hint` quand les arguments sont attendus

---

## Exemples concrets

### 1. Expertise pure — conventions de commit

```yaml
---
name: commit-convention
description: Convention de messages de commit. Utiliser lors de la creation de commits pour formater avec emoji, type et scope.
user-invocable: false
---

## Format
`emoji type(scope): description`

## Types
| Emoji | Type | Usage |
|-------|------|-------|
| feat  | Nouvelle fonctionnalite |
| fix   | Correction de bug |
...
```

### 2. Action avec side effects — deploy

```yaml
---
name: deploy
description: Deployer l'application en production.
disable-model-invocation: true
allowed-tools: Bash(npm *), Bash(git push *), Read
argument-hint: [environment]
---

## Contexte
- Branche : !`git branch --show-current`
- Tests : !`npm test 2>&1 | tail -5`

## Etapes
1. Verifier qu'on est sur main
2. Builder : `npm run build`
3. Deployer : `npm run deploy:$0`
4. Verifier : `curl https://app.com/health`

$ARGUMENTS
```

### 3. Sous-agent de recherche

```yaml
---
name: deep-research
description: Recherche approfondie dans le codebase.
context: fork
agent: Explore
allowed-tools: Read, Grep, Glob, Bash(gh *)
argument-hint: [sujet de recherche]
---

Recherche approfondie sur : $ARGUMENTS

1. Trouver les fichiers pertinents avec Glob/Grep
2. Lire et analyser le code
3. Resumer les findings avec references precises aux fichiers

Retourne un rapport structure.
```

### 4. Skill avec fichiers supports et scripts

```yaml
---
name: api-generator
description: Generer des endpoints API depuis un schema.
allowed-tools: Read, Edit, Write, Bash(npm run *)
argument-hint: [schema-file]
---

## Schema
!`cat $0 2>/dev/null || echo "Fichier schema non trouve: $0"`

## Template
Utilise le template dans [template.md](template.md).

## Validation
!`${CLAUDE_SKILL_DIR}/scripts/validate-schema.sh $0`

## Etapes
1. Parser le schema
2. Generer les endpoints selon le template
3. Valider avec le script
4. Ecrire les fichiers

$ARGUMENTS
```

### 5. Skill multi-arguments

```yaml
---
name: migrate-component
description: Migrer un composant d'un framework a un autre.
argument-hint: [component] [from-framework] [to-framework]
---

Migrer le composant `$0` de $1 vers $2.

Preserver le comportement et les tests existants.

Considerations specifiques :
- Framework source : $1
- Framework cible : $2
```

Usage : `/migrate-component SearchBar React Vue`
