#!/bin/bash
# Localise le fichier de pilotage d'un cycle — remplace l'étape 0 répétée dans
# pipe-test, pipe-code, pipe-review et pipe-ship.
#
# Usage : find-plan.sh [identifiant]
#   identifiant → .claude/plans/plan-<identifiant>.md (exit 1 s'il manque)
#   sans        → un seul pilotage : son chemin ; plusieurs : celui dont le texte
#                 cite la branche courante en backticks, sinon la liste sur stderr
#                 (exit 3, le skill demande lequel) ; aucun : exit 1
#
# Sortie : le chemin du pilotage, relatif à la racine du projet, sur stdout.
# Exécuté depuis le plugin (${CLAUDE_SKILL_DIR}/../../shared/scripts/), jamais copié.

ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
DIR="$ROOT/.claude/plans"

if [ -n "$1" ]; then
  f="$DIR/plan-$1.md"
  if [ ! -f "$f" ]; then
    echo "Aucun pilotage pour « $1 » (${f#"$ROOT"/}) : lancer /pipe-spec ou /pipe-plan d'abord." >&2
    exit 1
  fi
  echo "${f#"$ROOT"/}"
  exit 0
fi

plans=()
for f in "$DIR"/plan-*.md; do
  [ -e "$f" ] && plans+=("$f")
done

case ${#plans[@]} in
  0) echo "Aucun pilotage dans .claude/plans/ : le cycle n'a pas commencé — /pipe-spec <ticket> l'ouvre." >&2; exit 1 ;;
  1) echo "${plans[0]#"$ROOT"/}"; exit 0 ;;
esac

branch=$(git -C "$ROOT" branch --show-current 2>/dev/null)
if [ -n "$branch" ]; then
  match=()
  for p in "${plans[@]}"; do
    grep -qF "\`$branch\`" "$p" && match+=("$p")
  done
  if [ ${#match[@]} -eq 1 ]; then
    echo "${match[0]#"$ROOT"/}"
    exit 0
  fi
fi

echo "Plusieurs pilotages en cours, lequel ?" >&2
for p in "${plans[@]}"; do echo "  ${p#"$ROOT"/}" >&2; done
exit 3
