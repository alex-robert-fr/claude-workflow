#!/bin/bash
# Copie dans le projet courant les fichiers universels de /setup : quatre hooks vers
# .claude/hooks/, check-specs.sh vers .claude/scripts/, settings-template.json vers
# .claude/settings.json. Une ligne par fichier : `copié`, `identique` ou `différent`.
#
# Un fichier existant n'est jamais écrasé ici : `différent` est remonté au skill, qui
# demande avant de recopier (`--force` écrase tout, réservé à ce cas confirmé). Le
# settings.json existant relève du merge par le skill, pas d'une copie.

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../skills/setup" && pwd)"
ROOT="${CLAUDE_PROJECT_DIR:-.}"
FORCE=0
[ "$1" = "--force" ] && FORCE=1

mkdir -p "$ROOT/.claude/hooks" "$ROOT/.claude/scripts"

place() {
  local from="$1" to="$2"
  if [ ! -f "$to" ] || [ "$FORCE" = 1 ]; then
    cp "$from" "$to" && echo "copié     ${to#"$ROOT"/}"
  elif cmp -s "$from" "$to"; then
    echo "identique ${to#"$ROOT"/}"
  else
    echo "différent ${to#"$ROOT"/}"
  fi
}

for h in session-start pre-tool-use post-tool-use stop; do
  place "$SRC/scripts/$h.sh" "$ROOT/.claude/hooks/$h.sh"
done
place "$SRC/scripts/check-specs.sh" "$ROOT/.claude/scripts/check-specs.sh"
chmod +x "$ROOT"/.claude/hooks/*.sh "$ROOT"/.claude/scripts/*.sh

if [ ! -f "$ROOT/.claude/settings.json" ]; then
  cp "$SRC/settings-template.json" "$ROOT/.claude/settings.json" && echo "copié     .claude/settings.json (placeholders à remplir)"
else
  echo "présent   .claude/settings.json (merge des hooks par le skill)"
fi
