#!/bin/bash
# Hook PreToolUse (plugin) — bloque un Write/Edit/commande git-gh qui introduit un mot
# français sans son accent, avant que le contenu n'existe. Déterministe, aucun LLM :
# check-accents.sh fait toute la détection, ce script ne fait qu'extraire le bon texte
# selon l'outil et décider du blocage.
#
# Périmètre volontairement restreint pour éviter les faux positifs :
#   - Write/Edit sur *.md : la prose de ce dépôt vérifiée dans son intégralité
#   - Write/Edit sur *.sh : seules les lignes de COMMENTAIRE sont vérifiées — jamais le
#     code (regex, motifs volontairement flous comme `de*pre*ci`). Les commentaires de
#     code applicatif ne sont pas vérifiés ici pour leurs accents ; leur fond (quoi vs
#     pourquoi) est jugé par post-edit-comments.sh après écriture
#   - Bash : uniquement les commandes qui portent un message en français par convention
#     (git commit, gh pr create/edit, gh pr comment, gh issue create, gh api ...comments)
#
# Exit 2 bloque, et c'est STDERR qui est alors transmis à Claude — jamais stdout.

command -v jq >/dev/null 2>&1 || exit 0

INPUT=$(cat)
TOOL=$(printf '%s' "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)

TEXT=""
case "$TOOL" in
  Write)
    FILE=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
    CONTENT=$(printf '%s' "$INPUT" | jq -r '.tool_input.content // empty' 2>/dev/null)
    if [[ "$FILE" =~ \.md$ ]]; then
      TEXT="$CONTENT"
    elif [[ "$FILE" =~ \.sh$ ]]; then
      TEXT=$(printf '%s\n' "$CONTENT" | grep -E '^[[:space:]]*#')
    else
      exit 0
    fi
    ;;
  Edit)
    FILE=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
    NEW=$(printf '%s' "$INPUT" | jq -r '.tool_input.new_string // empty' 2>/dev/null)
    if [[ "$FILE" =~ \.md$ ]]; then
      TEXT="$NEW"
    elif [[ "$FILE" =~ \.sh$ ]]; then
      TEXT=$(printf '%s\n' "$NEW" | grep -E '^[[:space:]]*#')
    else
      exit 0
    fi
    ;;
  Bash)
    CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
    printf '%s' "$CMD" | grep -qE 'git[[:space:]]+commit|gh[[:space:]]+pr[[:space:]]+(create|edit|comment)|gh[[:space:]]+issue[[:space:]]+create|gh[[:space:]]+api[^|]*comments' || exit 0
    TEXT="$CMD"
    ;;
  *)
    exit 0
    ;;
esac

[ -n "$TEXT" ] || exit 0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HITS=$(printf '%s' "$TEXT" | "$SCRIPT_DIR/check-accents.sh")
[ -n "$HITS" ] || exit 0

{
  echo "BLOQUÉ — accent(s) français manquant(s) dans le texte à écrire :"
  printf '%s\n' "$HITS"
  echo "Corrige ces mots puis réessaie."
} >&2
exit 2
