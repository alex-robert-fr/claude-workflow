#!/bin/bash
# sync.sh — Synchronise les fichiers Claude partagés dans un projet
#
# Usage :
#   ./sync.sh                    # sync dans le répertoire courant
#   ./sync.sh /path/to/project   # sync dans un projet spécifique
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="${1:-.}"
TARGET_CLAUDE="$TARGET/.claude"

# Créer les dossiers si nécessaire
mkdir -p "$TARGET_CLAUDE/commands" "$TARGET_CLAUDE/skills"

# Sync des commandes partagées
changed=0
for file in "$SCRIPT_DIR/.claude/commands/"*.md; do
  filename="$(basename "$file")"
  if ! cmp -s "$file" "$TARGET_CLAUDE/commands/$filename" 2>/dev/null; then
    cp "$file" "$TARGET_CLAUDE/commands/$filename"
    echo "  ↳ commands/$filename"
    changed=$((changed + 1))
  fi
done

# Sync des skills partagés
for file in "$SCRIPT_DIR/.claude/skills/"*.md; do
  filename="$(basename "$file")"
  if ! cmp -s "$file" "$TARGET_CLAUDE/skills/$filename" 2>/dev/null; then
    cp "$file" "$TARGET_CLAUDE/skills/$filename"
    echo "  ↳ skills/$filename"
    changed=$((changed + 1))
  fi
done

# Créer les fichiers projet-specific s'ils n'existent pas encore
for file in "$SCRIPT_DIR/templates/"*.md; do
  filename="$(basename "$file")"
  if [ ! -f "$TARGET_CLAUDE/skills/$filename" ]; then
    cp "$file" "$TARGET_CLAUDE/skills/$filename"
    echo "  ↳ skills/$filename (template, à personnaliser)"
    changed=$((changed + 1))
  fi
done

if [ "$changed" -eq 0 ]; then
  echo "  Déjà à jour."
else
  echo "  $changed fichier(s) mis à jour."
fi
