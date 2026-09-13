#!/bin/bash
# Crée la branche d'un cycle depuis la branche de base du projet, à jour.
# Remplace la séquence « checkout base → pull → checkout -b » et la règle
# « jamais hardcoder main/develop » qui vivaient dans pipe-test.
#
# Usage : new-branch.sh <type/identifiant-titre-court>
# La branche de base vient de workflow-config (« Branche par défaut »), sinon de
# origin/HEAD. Le working tree non commité suit la nouvelle branche (voulu : la
# spec écrite avant le cycle part avec).
# Exécuté depuis le plugin (${CLAUDE_SKILL_DIR}/../../shared/scripts/), jamais copié.

ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
CFG="$ROOT/.claude/skills/workflow-config/SKILL.md"

[ -n "$1" ] || { echo "Usage : new-branch.sh <branche>" >&2; exit 2; }
branch="$1"

base=""
if [ -f "$CFG" ]; then
  base=$(grep -iE '^- \*\*Branche par d[eé]faut\*\*' "$CFG" | head -1 \
    | sed -E 's/^[^:]*:[[:space:]]*//; s/<!--.*//; s/`//g; s/[[:space:]]+$//')
fi
[ -n "$base" ] || base=$(git -C "$ROOT" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##')
# origin/HEAD n'est pas posé sur tous les clones : on interroge alors le remote.
[ -n "$base" ] || base=$(git -C "$ROOT" ls-remote --symref origin HEAD 2>/dev/null | awk '/^ref:/ { sub("refs/heads/", "", $2); print $2; exit }')
if [ -z "$base" ]; then
  echo "Branche de base introuvable : renseigner « Branche par défaut » dans .claude/skills/workflow-config/SKILL.md (ou lancer /setup)." >&2
  exit 1
fi

if git -C "$ROOT" show-ref --verify --quiet "refs/heads/$branch"; then
  echo "La branche $branch existe déjà : git switch $branch" >&2
  exit 1
fi

git -C "$ROOT" switch "$base" >/dev/null || exit 1
git -C "$ROOT" pull --ff-only origin "$base" >/dev/null || { echo "pull --ff-only de $base impossible : branche locale divergente, à résoudre avant de créer $branch." >&2; exit 1; }
git -C "$ROOT" switch -c "$branch" >/dev/null || exit 1

echo "$branch (depuis $base)"
