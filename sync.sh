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

changed=0

# Sync des commandes partagées (récursif)
while IFS= read -r -d '' file; do
  rel="${file#"$SCRIPT_DIR/.claude/commands/"}"
  target_file="$TARGET_CLAUDE/commands/$rel"
  mkdir -p "$(dirname "$target_file")"
  if ! cmp -s "$file" "$target_file" 2>/dev/null; then
    cp "$file" "$target_file"
    echo "  ↳ commands/$rel"
    changed=$((changed + 1))
  fi
done < <(find "$SCRIPT_DIR/.claude/commands" -name '*.md' -print0)

# Sync des skills partagés (récursif)
while IFS= read -r -d '' file; do
  rel="${file#"$SCRIPT_DIR/.claude/skills/"}"
  target_file="$TARGET_CLAUDE/skills/$rel"
  mkdir -p "$(dirname "$target_file")"
  if ! cmp -s "$file" "$target_file" 2>/dev/null; then
    cp "$file" "$target_file"
    echo "  ↳ skills/$rel"
    changed=$((changed + 1))
  fi
done < <(find "$SCRIPT_DIR/.claude/skills" -name '*.md' -print0)

# Créer les fichiers projet-specific s'ils n'existent pas encore
for file in "$SCRIPT_DIR/templates/"*.md; do
  [ -f "$file" ] || continue
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
