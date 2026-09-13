#!/bin/bash
# Détecte les versions du projet sans charger CHANGELOG.md — remplace les grep
# recopiés dans pipe-tag, pipe-release et pipe-changelog.
#
# Usage : detect-version.sh          → dernière version publiée du CHANGELOG (X.Y.Z, sans v)
#         detect-version.sh --tag    → dernier tag git vX.Y.Z
#         detect-version.sh --next   → version publiée en préparation : celle de la
#                                      section [Unreleased] si le projet en note une,
#                                      sinon la dernière publiée incrémentée en PATCH
# Rien trouvé → exit 1, rien sur stdout.
# Exécuté depuis le plugin (${CLAUDE_SKILL_DIR}/../../shared/scripts/), jamais copié.

ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
FILE="${CHANGELOG_FILE:-$ROOT/CHANGELOG.md}"

published() {
  [ -f "$FILE" ] || return 1
  # Le motif exclut [Unreleased] et tolère un titre lié.
  grep -m1 -oE '^## \[[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?\]' "$FILE" | sed 's/^## \[//; s/\]$//'
}

case "$1" in
  --tag)
    t=$(git -C "$ROOT" tag --sort=-version:refname -l 'v*' 2>/dev/null | head -1)
    [ -n "$t" ] && echo "$t" || exit 1
    ;;
  --next)
    v=$(published) || exit 1
    [ -n "$v" ] || exit 1
    IFS=. read -r maj min pat <<< "${v%%-*}"
    echo "$maj.$min.$((pat + 1))"
    ;;
  "")
    v=$(published)
    [ -n "$v" ] && echo "$v" || exit 1
    ;;
  *)
    echo "Usage : detect-version.sh [--tag|--next]" >&2; exit 2
    ;;
esac
