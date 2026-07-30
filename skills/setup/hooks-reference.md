# Hooks Reference — Templates pour /setup

Ce fichier contient les templates de hooks a adapter pour chaque projet.
Les hooks sont des garde-fous deterministes — ils ne coutent rien en tokens et ne ratent jamais.

## Principe

| Hook | Role | Quand |
|------|------|-------|
| SessionStart | Injecter l'index des specs dans le contexte | Au demarrage de chaque session |
| PreToolUse | Bloquer les commandes dangereuses | Avant chaque appel d'outil |
| PostToolUse | Auto-lint/format apres ecriture | Apres Write ou Edit |
| Stop | Verifier que les tests passent | Quand Claude pense avoir fini |

## SessionStart — Index des specs

Les specs de `docs/specs/` n'ont de valeur que si elles sont **lues**. Une instruction dans le CLAUDE.md repose sur la bonne volonte du LLM ; ce hook rend l'index present dans le contexte des le demarrage, sans exception.

**Pas de matcher** — l'evenement n'en prend pas.

**Script template** (`.claude/hooks/session-start.sh`) :

```bash
#!/bin/bash
# Hook SessionStart — injecte l'index des specs dans le contexte de la session

INDEX="${CLAUDE_PROJECT_DIR:-.}/docs/specs/README.md"
[ -f "$INDEX" ] || exit 0

HEADER="Index des specs de features de ce projet (docs/specs/). Chaque spec porte l'intention, le comportement attendu, le hors-scope, les decisions et les points d'entree techniques d'une feature. AVANT de modifier une feature, lire sa spec plutot que de parcourir le code."

jq -Rs --arg header "$HEADER" \
  '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: ($header + "\n\n" + .)}, suppressOutput: true}' \
  "$INDEX"
```

Points de mecanique :

- L'injection passe par `hookSpecificOutput.additionalContext`, avec `hookEventName` **obligatoire** — un `echo` de texte brut n'est pas garanti d'atteindre le contexte
- `jq -Rs` echappe le markdown de l'index : ne jamais construire ce JSON a la main
- `suppressOutput: true` evite d'afficher l'index dans le transcript a chaque demarrage
- Projet sans `docs/specs/README.md` → sortie vide et exit 0 : le hook est inerte, pas en erreur
- Cout : l'index seul (une ligne par feature), pas les specs. Compter ~200 tokens pour une dizaine de features — c'est ce qui evite l'exploration a l'aveugle

## PreToolUse — Blocage des commandes dangereuses

Bloque les commandes Bash qui pourraient causer des degats irreversibles.

**Matcher** : `Bash`

**Script template** :

```bash
#!/bin/bash
# Hook PreToolUse — bloque les commandes dangereuses
# Recoit l'input de l'outil sur stdin en JSON

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Patterns dangereux a bloquer
DANGEROUS_PATTERNS=(
  'rm\s+-rf\s+/'
  'rm\s+-rf\s+\.'
  'git\s+push\s+--force\s+(origin\s+)?(main|master|develop)'
  'git\s+push\s+-f\s+(origin\s+)?(main|master|develop)'
  'DROP\s+(TABLE|DATABASE)'
  'TRUNCATE\s+TABLE'
  'git\s+reset\s+--hard'
  'git\s+checkout\s+\.\s*$'
  'git\s+clean\s+-fd'
  'chmod\s+-R\s+777'
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qEi "$pattern"; then
    echo "BLOCKED: commande dangereuse detectee — $COMMAND"
    exit 2
  fi
done
```

**Commande inline (alternative sans script)** :

```
bash -c 'CMD=$(cat | jq -r ".tool_input.command // empty"); echo "$CMD" | grep -qEi "(rm\\s+-rf\\s+[/.]|git\\s+push\\s+--force.*(main|master)|DROP\\s+(TABLE|DATABASE)|git\\s+reset\\s+--hard|git\\s+checkout\\s+\\.\\s*$)" && echo "BLOCKED: commande dangereuse" && exit 2 || true'
```

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
