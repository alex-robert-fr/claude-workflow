#!/bin/bash
# Diagnostic de /setup, exécuté depuis le plugin dans le projet courant : une ligne
# `ok <chemin>` ou `KO <chemin> (motif)` par élément attendu, exit 1 dès qu'un KO existe.
# Le skill n'a plus qu'à présenter ces lignes et à confirmer la liste des actions.
#
# Les hooks sont contrôlés un par un depuis settings.json : un hook dont le script est
# absent ou non exécutable se déclenche en silence et ne protège rien — c'est le cas
# qu'aucune relecture du fichier ne détecte.

ROOT="${1:-.}"
status=0
ko() { echo "KO $1 ($2)"; status=1; }

[ -f "$ROOT/CLAUDE.md" ] && echo "ok CLAUDE.md" || ko "CLAUDE.md" "absent"

CFG="$ROOT/.claude/skills/workflow-config/SKILL.md"
if [ ! -f "$CFG" ]; then ko ".claude/skills/workflow-config/SKILL.md" "absent"
elif grep -q '<!--' "$CFG"; then ko ".claude/skills/workflow-config/SKILL.md" "placeholders restants"
else echo "ok .claude/skills/workflow-config/SKILL.md"; fi

SETTINGS="$ROOT/.claude/settings.json"
if [ ! -f "$SETTINGS" ]; then
  ko ".claude/settings.json" "absent"
elif ! command -v jq >/dev/null 2>&1; then
  ko ".claude/settings.json" "jq absent, hooks non vérifiables"
else
  for event in SessionStart PreToolUse PostToolUse Stop; do
    cmds=$(jq -r --arg e "$event" '.hooks[$e][]?.hooks[]?.command // empty' "$SETTINGS" 2>/dev/null)
    [ -n "$cmds" ] || { ko "hook $event" "non déclaré"; continue; }
    while IFS= read -r cmd; do
      script=$(printf '%s' "$cmd" | awk '{print ($1 == "bash" || $1 == "sh") ? $2 : $1}')
      [ -x "$ROOT/$script" ] && echo "ok hook $event → $script" || ko "hook $event → $script" "script absent ou non exécutable"
    done <<< "$cmds"
  done
fi

[ -x "$ROOT/.claude/scripts/check-specs.sh" ] && echo "ok .claude/scripts/check-specs.sh" || ko ".claude/scripts/check-specs.sh" "absent ou non exécutable"
[ -d "$ROOT/.claude/plans" ] && echo "ok .claude/plans/" || ko ".claude/plans/" "absent"
[ -d "$ROOT/docs/specs" ] && echo "ok docs/specs/" || ko "docs/specs/" "absent"
[ -f "$ROOT/docs/specs/README.md" ] && echo "ok docs/specs/README.md" || ko "docs/specs/README.md" "absent"

exit $status
