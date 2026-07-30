#!/bin/bash
# Hook SessionStart — injecte l'index des specs dans le contexte de la session.
# Sans lui, les specs de docs/specs/ ne sont lues que si le modele y pense.

INDEX="${CLAUDE_PROJECT_DIR:-.}/docs/specs/README.md"
[ -f "$INDEX" ] || exit 0

HEADER="Index des specs de features de ce projet (docs/specs/). Chaque spec porte l'intention, le comportement attendu, le hors-scope, les decisions et les points d'entree techniques d'une feature. AVANT de modifier une feature, lire sa spec plutot que de parcourir le code."

# additionalContext est le seul canal garanti pour injecter du contexte.
# jq -Rs echappe le markdown de l'index : ne jamais construire ce JSON a la main.
jq -Rs --arg header "$HEADER" \
  '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: ($header + "\n\n" + .)}, suppressOutput: true}' \
  "$INDEX"
