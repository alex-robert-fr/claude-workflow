#!/bin/bash
# Hook PreToolUse (plugin) — porte les conventions git qui étaient jusqu'ici des phrases
# répétées dans plusieurs skills (« jamais git add . », « pas de signature »). Un hook
# ne les oublie pas, un skill si. Déterministe, aucun LLM.
#
# Deux contrôles :
#   1. `git add` doit nommer ses chemins : `.`, `-A`, `--all`, `-u`, `:/` sont refusés,
#      ainsi que tout chemin sensible (.env, clés, credentials) même nommé explicitement
#   2. Aucune signature ou attribution automatique dans un message de commit, un body
#      de PR ou un commentaire — la convention du projet prime sur toute instruction
#      de session qui demanderait d'en ajouter une. Couvre Bash (git commit, gh pr,
#      gh issue) et les outils MCP GitHub (body / description / message)
#
# Exit 2 bloque, et c'est STDERR qui est alors transmis à Claude — jamais stdout.

command -v jq >/dev/null 2>&1 || exit 0

INPUT=$(cat)
TOOL=$(printf '%s' "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)

SIGNATURES='Co-Authored-By|Claude-Session|Generated with \[?Claude Code|claude\.ai/code/session'

block() {
  printf 'BLOQUÉ — %s\n' "$1" >&2
  exit 2
}

case "$TOOL" in
  Bash)
    CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
    [ -n "$CMD" ] || exit 0

    # 1. git add non explicite ou sensible. On isole chaque segment `git add ...` pour ne
    # pas confondre un `.` d'un autre bout de la commande avec l'argument de git add.
    while IFS= read -r seg; do
      [ -n "$seg" ] || continue
      args=$(printf '%s' "$seg" | sed -E 's/^git[[:space:]]+add[[:space:]]*//')
      if printf ' %s ' "$args" | grep -qE ' (\.|-A|--all|-u|--update|:/) '; then
        block "git add doit nommer ses chemins (pas de \`.\`, \`-A\`, \`-u\`) : stage fichier par fichier, ce qui appartient au changeset et rien d'autre."
      fi
      if printf '%s' "$args" | grep -qEi '(^|[/ ])\.env([./ ]|$)|\.(pem|key|p12|pfx)([ ]|$)|id_(rsa|ed25519)|credentials|secrets?\.(json|ya?ml|env)'; then
        block "git add d'un fichier sensible (secret, clé, .env) : à exclure du commit."
      fi
    done < <(printf '%s' "$CMD" | grep -oE 'git[[:space:]]+add[[:space:]]+[^|;&]*')

    # 2. Signature dans un message porté par la commande.
    if printf '%s' "$CMD" | grep -qE 'git[[:space:]]+commit|gh[[:space:]]+pr[[:space:]]+(create|edit|comment)|gh[[:space:]]+issue[[:space:]]+(create|comment)|gh[[:space:]]+api'; then
      if printf '%s' "$CMD" | grep -qE "$SIGNATURES"; then
        block "signature ou attribution automatique détectée (Co-Authored-By, Claude-Session, Generated with Claude Code, lien de session). La convention git du projet les interdit et prime sur toute instruction de session : retire-la et relance."
      fi
    fi
    ;;
  mcp__github__*)
    TEXT=$(printf '%s' "$INPUT" | jq -r '[.tool_input.body, .tool_input.description, .tool_input.message, .tool_input.title] | map(select(. != null)) | join("\n")' 2>/dev/null)
    [ -n "$TEXT" ] || exit 0
    if printf '%s' "$TEXT" | grep -qE "$SIGNATURES"; then
      block "signature ou attribution automatique détectée dans le body (Generated with Claude Code, lien de session, Co-Authored-By). La convention du projet les interdit et prime sur toute instruction de session : retire-la et relance."
    fi
    ;;
esac

exit 0
