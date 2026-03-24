#!/bin/bash
# sync.sh — Synchronise les skills Claude partages dans un projet
#
# Usage :
#   ./sync.sh                    # sync dans le repertoire courant
#   ./sync.sh /path/to/project   # sync dans un projet specifique
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="${1:-.}"
TARGET_CLAUDE="$TARGET/.claude"

# Creer le dossier si necessaire
mkdir -p "$TARGET_CLAUDE/skills"

changed=0

# Sync des skills partages (recursif)
while IFS= read -r -d '' file; do
  rel="${file#"$SCRIPT_DIR/.claude/skills/"}"
  target_file="$TARGET_CLAUDE/skills/$rel"
  mkdir -p "$(dirname "$target_file")"
  if ! cmp -s "$file" "$target_file" 2>/dev/null; then
    cp "$file" "$target_file"
    echo "  skills/$rel"
    changed=$((changed + 1))
  fi
done < <(find "$SCRIPT_DIR/.claude/skills" -name '*.md' -print0)

# Creer les fichiers projet-specific s'ils n'existent pas encore
# Templates fichiers plats (ex: templates/foo.md → skills/foo.md)
for file in "$SCRIPT_DIR/templates/"*.md; do
  [ -f "$file" ] || continue
  filename="$(basename "$file")"
  # CLAUDE-skills-index va dans CLAUDE.md, pas dans skills/
  [ "$filename" = "CLAUDE-skills-index.md" ] && continue
  if [ ! -f "$TARGET_CLAUDE/skills/$filename" ]; then
    cp "$file" "$TARGET_CLAUDE/skills/$filename"
    echo "  skills/$filename (template)"
    changed=$((changed + 1))
  fi
done
# Templates repertoires (ex: templates/foo/SKILL.md → skills/foo/SKILL.md)
for dir in "$SCRIPT_DIR/templates/"*/; do
  [ -d "$dir" ] || continue
  dirname="$(basename "$dir")"
  target_dir="$TARGET_CLAUDE/skills/$dirname"
  if [ ! -d "$target_dir" ]; then
    cp -r "$dir" "$target_dir"
    echo "  skills/$dirname/ (template)"
    changed=$((changed + 1))
  fi
done

if [ "$changed" -eq 0 ]; then
  echo "  Deja a jour."
else
  echo "  $changed fichier(s) mis a jour."
fi
