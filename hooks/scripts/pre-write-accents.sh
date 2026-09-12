#!/bin/bash
# Hook PreToolUse (plugin) — bloque un Write/Edit/commande git-gh qui introduit un mot
# francais sans son accent, avant que le contenu n'existe. Deterministe, aucun LLM :
# check-accents.sh fait toute la detection, ce script ne fait qu'extraire le bon texte
# selon l'outil et decider du blocage.
#
# Perimetre volontairement restreint pour eviter les faux positifs :
#   - Write/Edit sur *.md : la prose de ce depot verifiee dans son integralite
#   - Write/Edit sur *.sh : seules les lignes de COMMENTAIRE sont verifiees — jamais le
#     code (regex, motifs volontairement flous comme `de*pre*ci`) ni les commentaires de
#     code applicatif hors scripts de ce plugin, dont la qualite est du ressort du
#     sub-agent de /pipe-review, pas d'un hook
#   - Bash : uniquement les commandes qui portent un message en francais par convention
#     (git commit, gh pr create/edit, gh pr comment, gh issue create, gh api ...comments)
#
# Exit 2 bloque, et c'est STDERR qui est alors transmis a Claude — jamais stdout.

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
  echo "BLOQUE — accent(s) francais manquant(s) dans le texte a ecrire :"
  printf '%s\n' "$HITS"
  echo "Corrige ces mots puis reessaie."
} >&2
exit 2
