#!/bin/bash
# Liste les clés de tickets Jira ou Linear (forme ABC-123) citées dans les messages de
# commit d'une plage git — une par ligne, dédoublonnées, triées. Remplace le grep recopié
# dans pipe-release et pipe-tag ; les clés citées seulement dans les corps de PR viennent
# du MCP de la plateforme, et l'existence de chaque clé se vérifie sur le tracker.
#
# Usage : list-tickets.sh <plage>     ex. origin/main..develop, v1.2.0..HEAD
# Sans argument → exit 2. Plage invalide → exit 1. Aucune clé → rien sur stdout, exit 0.
# Exécuté depuis le plugin (${CLAUDE_SKILL_DIR}/../../shared/scripts/), jamais copié.
#
# Les sigles techniques de même forme (UTF-8, SHA-256, RFC-7231, CVE-2024…) sont exclus :
# sans cette liste, un commit qui cite un encodage ferait interroger le tracker pour rien.

ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

[ -n "$1" ] || { echo "Usage : list-tickets.sh <plage>" >&2; exit 2; }

BODIES=$(git -C "$ROOT" log "$1" --format=%B 2>/dev/null) || exit 1

printf '%s\n' "$BODIES" \
  | grep -oE '(^|[^A-Za-z0-9_/-])[A-Z][A-Z0-9]+-[0-9]+([^A-Za-z0-9_-]|$)' \
  | grep -oE '[A-Z][A-Z0-9]+-[0-9]+' \
  | grep -vE '^(UTF|ISO|SHA|MD|RFC|CVE|ES|HTTP|TLS|SSL|AES|RSA|HMAC|IPV|IEEE|X|OAUTH|PBKDF|ECMA|POSIX|EN|NF)-' \
  | sort -u
