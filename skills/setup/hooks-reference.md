# Hooks Reference — Templates pour /setup

Ce fichier documente les hooks et checks outilles a installer dans un projet.
Ce sont des garde-fous deterministes — ils ne ratent jamais, la ou une instruction au LLM peut etre ignoree.

## Deux categories, deux traitements

| Categorie | Contenu | Comment `/setup` l'installe |
|-----------|---------|------------------------------|
| **Scripts universels** | Aucune variable projet | **Copies tels quels** depuis `${CLAUDE_SKILL_DIR}/scripts/` — jamais recopies a la main |
| **Templates par stack** | Commandes de lint, format, test | Adaptes depuis ce fichier avec les valeurs de `workflow-config` |

Un script universel n'a **qu'une** version correcte : le recopier depuis un markdown, c'est confier a un LLM un travail que `cp` fait sans erreur d'echappement. Ne jamais reecrire ces fichiers a la main — les corriger dans le plugin.

## Principe

| Hook / check | Role | Quand | Type |
|--------------|------|-------|------|
| SessionStart | Injecter l'index des specs dans le contexte | Au demarrage de chaque session | script |
| PreToolUse | Bloquer les commandes dangereuses | Avant chaque appel d'outil | script |
| PostToolUse | Auto-lint/format apres ecriture | Apres Write ou Edit | template |
| Stop | Verifier que les tests passent | Quand Claude pense avoir fini | template |
| check-specs | Coherence des specs | Appele par `/pipe-review` | script |

## Scripts universels — a copier

| Source (plugin) | Destination (projet) |
|-----------------|----------------------|
| `scripts/session-start.sh` | `.claude/hooks/session-start.sh` |
| `scripts/pre-tool-use.sh` | `.claude/hooks/pre-tool-use.sh` |
| `scripts/check-specs.sh` | `.claude/scripts/check-specs.sh` |

`cp` puis `chmod +x`. Les sections ci-dessous expliquent ce que chacun fait et pourquoi — elles ne contiennent pas leur code.

## Check outille — coherence des specs

Ce n'est **pas un hook** : c'est un script appele par `/pipe-review` dans ses checks outilles (etape 1), au meme titre que le format, le lint et les tests. Il est ici parce que `/setup` le deploie comme les hooks.

Il couvre ce qu'un agent detecte mal : une spec qui pointe vers des fichiers disparus, et une spec absente de l'index — donc jamais injectee par le hook SessionStart, donc morte.

**Script** : `scripts/check-specs.sh` → `.claude/scripts/check-specs.sh`

Points de mecanique, tous verifies par test — a connaitre avant de modifier le script :

- **Ne lire que la colonne 1 du tableau.** La colonne Role cite souvent d'autres chemins (`.gitignore`, `.claude/plans/`) qui ne sont pas des points d'entree — les extraire produirait des faux positifs a chaque spec
- **Ignorer les lignes `(a creer)`**, accents compris. Une spec est ecrite avant le dev : sans cette tolerance, tout cadrage en amont echouerait le check
- Projet sans `docs/specs/` → exit 0 silencieux
- Exit 1 des qu'un ecart est trouve : `/pipe-review` le remonte comme les autres checks, sans bloquer le cycle

## SessionStart — Index des specs

Les specs de `docs/specs/` n'ont de valeur que si elles sont **lues**. Une instruction dans le CLAUDE.md repose sur la bonne volonte du LLM ; ce hook rend l'index present dans le contexte des le demarrage, sans exception.

**Pas de matcher** — l'evenement n'en prend pas.

**Script** : `scripts/session-start.sh` → `.claude/hooks/session-start.sh`

Points de mecanique — a connaitre avant de modifier le script :

- L'injection passe par `hookSpecificOutput.additionalContext`, avec `hookEventName` **obligatoire** — un `echo` de texte brut n'est pas garanti d'atteindre le contexte
- `jq -Rs` echappe le markdown de l'index : ne jamais construire ce JSON a la main
- `suppressOutput: true` evite d'afficher l'index dans le transcript a chaque demarrage
- Projet sans `docs/specs/README.md` → sortie vide et exit 0 : le hook est inerte, pas en erreur
- Cout : l'index seul (une ligne par feature), pas les specs. Compter ~200 tokens pour une dizaine de features — c'est ce qui evite l'exploration a l'aveugle

## PreToolUse — Blocage des commandes dangereuses

Bloque les commandes Bash qui pourraient causer des degats irreversibles.

**Matcher** : `Bash`

**Script** : `scripts/pre-tool-use.sh` → `.claude/hooks/pre-tool-use.sh`

La liste des patterns bloques vit dans le script (`rm -rf`, `git push --force` sur une branche protegee, `DROP TABLE`, `git reset --hard`...). Pour l'etendre sur un projet, editer le fichier deploye ; pour l'etendre partout, le corriger dans le plugin.

Exit 2 bloque l'action et remonte le message a Claude.

## PostToolUse — Auto-lint/format

Formate automatiquement les fichiers apres chaque ecriture. Le lint est deterministe — ca ne doit JAMAIS etre fait par le LLM.

**Matcher** : `Write|Edit`

**Templates par stack** :

### Biome (TypeScript/JavaScript)
```bash
#!/bin/bash
INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
if [ -n "$FILE" ] && [[ "$FILE" =~ \.(ts|tsx|js|jsx|json|css)$ ]]; then
  npx biome check --write "$FILE" 2>/dev/null || true
fi
```

### ESLint + Prettier
```bash
#!/bin/bash
INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
if [ -n "$FILE" ] && [[ "$FILE" =~ \.(ts|tsx|js|jsx)$ ]]; then
  npx eslint --fix "$FILE" 2>/dev/null || true
  npx prettier --write "$FILE" 2>/dev/null || true
fi
```

### Ruff (Python)
```bash
#!/bin/bash
INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
if [ -n "$FILE" ] && [[ "$FILE" =~ \.py$ ]]; then
  ruff check --fix "$FILE" 2>/dev/null || true
  ruff format "$FILE" 2>/dev/null || true
fi
```

### rustfmt (Rust)
```bash
#!/bin/bash
INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
if [ -n "$FILE" ] && [[ "$FILE" =~ \.rs$ ]]; then
  rustfmt "$FILE" 2>/dev/null || true
fi
```

### gofmt (Go)
```bash
#!/bin/bash
INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
if [ -n "$FILE" ] && [[ "$FILE" =~ \.go$ ]]; then
  gofmt -w "$FILE" 2>/dev/null || true
fi
```

## Stop — Verification des tests

Verifie que les tests passent avant de considerer la tache comme terminee. Si le hook retourne un code non-zero, Claude continue a travailler.

**Templates par stack** :

### npm/Node.js
```bash
npm run test 2>&1
```

### Vitest
```bash
npx vitest run 2>&1
```

### Go
```bash
go test ./... 2>&1
```

### Python
```bash
pytest 2>&1
```

### Rust
```bash
cargo test 2>&1
```

## Structure settings.json complete

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/session-start.sh"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/pre-tool-use.sh"
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
            "command": "bash .claude/hooks/post-tool-use.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/stop.sh"
          }
        ]
      }
    ]
  }
}
```

## Notes

- Les hooks sont executes par le harness Claude Code, pas par le LLM — leur execution est gratuite en tokens (un hook qui injecte du contexte, comme SessionStart, coute en revanche ce qu'il injecte)
- Un hook PreToolUse qui retourne exit code 2 bloque l'action avec le message stdout
- Un hook Stop qui retourne exit code non-zero force Claude a continuer
- Les hooks PostToolUse ne bloquent pas — ils s'executent silencieusement
- Toujours `|| true` sur les commandes de lint pour ne pas bloquer l'ecriture si le linter crash
- Les scripts doivent etre dans `.claude/hooks/` et rendus executables (`chmod +x`)
