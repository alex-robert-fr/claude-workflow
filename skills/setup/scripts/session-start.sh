#!/bin/bash
# Hook SessionStart — injecte l'index des specs dans le contexte de la session.
# Sans lui, les specs de docs/specs/ ne sont lues que si le modele y pense.

INDEX="${CLAUDE_PROJECT_DIR:-.}/docs/specs/README.md"
[ -f "$INDEX" ] || exit 0

HEADER="Index des specs de features de ce projet (docs/specs/). Chaque spec porte l'intention, le comportement attendu, le hors-scope, les decisions et les points d'entree techniques d'une feature. AVANT de modifier une feature, lire sa spec plutot que de parcourir le code."

# On s'arrete a la section des specs depreciees : une feature retiree ne doit pas
# etre proposee comme contexte de reference. Pas de section → tout l'index est actif.
# Le test de depreciation ne peut pas s'ecrire `d[eé]pr[eé]ci` : sous LC_ALL=C la
# classe designe des octets, et `é` en occupe deux — le motif echoue alors sur un
# titre correctement accentue, et les specs depreciees repartent dans le contexte.
# On retire donc les octets non-ASCII avant de comparer, puis on rend les `e`
# optionnels : « depreciees » et « dprcies » (accents otes) matchent tous deux.
ACTIVE=$(awk '/^## /{ t = tolower($0); gsub(/[^ -~]/, "", t); if (t ~ /de*pre*ci/) exit } {print}' "$INDEX")
[ -n "$(printf '%s' "$ACTIVE" | tr -d '[:space:]')" ] || exit 0

# additionalContext est le seul canal garanti pour injecter du contexte.
# jq -Rs echappe le markdown de l'index : ne jamais construire ce JSON a la main.
printf '%s' "$ACTIVE" | jq -Rs --arg header "$HEADER" \
  '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: ($header + "\n\n" + .)}, suppressOutput: true}'
