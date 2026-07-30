#!/bin/bash
# Hook PreToolUse — bloque les commandes Bash aux degats irreversibles.
# Recoit l'input de l'outil sur stdin en JSON.
#
# Exit 2 bloque l'appel, et STDERR est le seul canal transmis a Claude — un
# diagnostic sur stdout produit un blocage muet (« No stderr output »), et Claude
# reessaie alors la meme commande sans savoir ce qui lui est reproche.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

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
    echo "BLOCKED: commande dangereuse detectee — $COMMAND" >&2
    exit 2
  fi
done

exit 0
