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
# Templates fichiers plats (ex: templates/foo.md → skills/foo.md)
for file in "$SCRIPT_DIR/templates/"*.md; do
  [ -f "$file" ] || continue
  filename="$(basename "$file")"
  # CLAUDE-skills-index va dans CLAUDE.md, pas dans skills/
  [ "$filename" = "CLAUDE-skills-index.md" ] && continue
  if [ ! -f "$TARGET_CLAUDE/skills/$filename" ]; then
    cp "$file" "$TARGET_CLAUDE/skills/$filename"
    echo "  ↳ skills/$filename (template, à personnaliser)"
    changed=$((changed + 1))
  fi
done
# Templates répertoires (ex: templates/foo/SKILL.md → skills/foo/SKILL.md)
for dir in "$SCRIPT_DIR/templates/"*/; do
  [ -d "$dir" ] || continue
  dirname="$(basename "$dir")"
  target_dir="$TARGET_CLAUDE/skills/$dirname"
  if [ ! -d "$target_dir" ]; then
    cp -r "$dir" "$target_dir"
    echo "  ↳ skills/$dirname/ (template, à personnaliser)"
    changed=$((changed + 1))
  fi
done

# Synchroniser l'index des skills dans CLAUDE.md
SKILLS_INDEX="$SCRIPT_DIR/templates/CLAUDE-skills-index.md"
TARGET_CLAUDE_MD="$TARGET/CLAUDE.md"
if [ -f "$SKILLS_INDEX" ]; then
  if [ ! -f "$TARGET_CLAUDE_MD" ]; then
    # CLAUDE.md n'existe pas → le créer avec un header minimal + index
    project_name="$(basename "$(cd "$TARGET" && pwd)")"
    printf '# %s\n\n' "$project_name" > "$TARGET_CLAUDE_MD"
    cat "$SKILLS_INDEX" >> "$TARGET_CLAUDE_MD"
    echo "  ↳ CLAUDE.md (créé avec index des skills)"
    changed=$((changed + 1))
  elif ! grep -q "## Skills disponibles" "$TARGET_CLAUDE_MD" 2>/dev/null; then
    # CLAUDE.md existe mais pas de section skills → l'ajouter à la fin
    printf '\n' >> "$TARGET_CLAUDE_MD"
    cat "$SKILLS_INDEX" >> "$TARGET_CLAUDE_MD"
    echo "  ↳ CLAUDE.md (ajout index des skills)"
    changed=$((changed + 1))
  else
    # CLAUDE.md existe et contient la section → vérifier si tous les skills sont présents
    # Extraire les chemins de skills du template et vérifier chacun
    missing=0
    while IFS= read -r skill_path; do
      if ! grep -qF "$skill_path" "$TARGET_CLAUDE_MD" 2>/dev/null; then
        missing=$((missing + 1))
      fi
    done < <(grep -oP '`\.claude/skills/[^`]+`' "$SKILLS_INDEX")

    if [ "$missing" -gt 0 ]; then
      # Des skills manquent → remplacer toute la section
      awk '
        /^## Skills disponibles/ { skip=1; next }
        skip && /^## / { skip=0 }
        !skip
      ' "$TARGET_CLAUDE_MD" > "$TARGET_CLAUDE_MD.tmp"
      # Nettoyer les lignes vides en fin de fichier
      while [ -s "$TARGET_CLAUDE_MD.tmp" ] && [ "$(tail -c 1 "$TARGET_CLAUDE_MD.tmp" | wc -l)" -eq 1 ] && [ -z "$(tail -1 "$TARGET_CLAUDE_MD.tmp")" ]; do
        sed -i '$ d' "$TARGET_CLAUDE_MD.tmp"
      done
      printf '\n\n' >> "$TARGET_CLAUDE_MD.tmp"
      cat "$SKILLS_INDEX" >> "$TARGET_CLAUDE_MD.tmp"
      mv "$TARGET_CLAUDE_MD.tmp" "$TARGET_CLAUDE_MD"
      echo "  ↳ CLAUDE.md (mise à jour index des skills — $missing skill(s) ajouté(s))"
      changed=$((changed + 1))
    fi
  fi
fi

if [ "$changed" -eq 0 ]; then
  echo "  Déjà à jour."
else
  echo "  $changed fichier(s) mis à jour."
fi
