#!/bin/bash
# Hook PreToolUse (plugin) — protège les tests validés pendant le dev et la review.
# Remplace la phrase « les tests validés sont le contrat, interdiction de les modifier »
# qui vivait dans trois skills : ici, elle ne peut plus être oubliée.
#
# Un fichier est protégé s'il figure dans la section `## Tests` d'un pilotage
# (.claude/plans/plan-*.md) dont l'état porte `[x] Tests valides` et `[ ] Code valide`.
# Format attendu dans `## Tests` : un fichier par ligne, en backticks — c'est le contrat
# fixé par shared/pilotage-template.md.
#
# Levée du verrou = décision humaine : décocher `Tests valides` dans le pilotage (le test
# est faux, on le réécrit et on le revalide), ou cocher `Code valide` (la review a tranché).
#
# Exit 2 bloque, et c'est STDERR qui est alors transmis à Claude — jamais stdout.

command -v jq >/dev/null 2>&1 || exit 0

INPUT=$(cat)
FILE=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // .tool_input.notebook_path // empty' 2>/dev/null)
[ -n "$FILE" ] || exit 0

ROOT="${CLAUDE_PROJECT_DIR:-$(printf '%s' "$INPUT" | jq -r '.cwd // empty' 2>/dev/null)}"
[ -n "$ROOT" ] || ROOT=$(pwd)
[ -d "$ROOT/.claude/plans" ] || exit 0

# Chemin édité, relatif à la racine du projet quand c'est possible.
case "$FILE" in
  "$ROOT"/*) REL="${FILE#"$ROOT"/}" ;;
  *) REL="$FILE" ;;
esac

for plan in "$ROOT"/.claude/plans/plan-*.md; do
  [ -f "$plan" ] || continue
  grep -qE '^- \[x\] Tests valides' "$plan" || continue
  grep -qE '^- \[ \] Code valide' "$plan" || continue

  # Chemins en backticks de la section ## Tests uniquement, jusqu'au titre suivant.
  while IFS= read -r listed; do
    [ -n "$listed" ] || continue
    if [ "$REL" = "$listed" ] || [ "${REL%/"$listed"}" != "$REL" ]; then
      {
        echo "BLOQUÉ — \`$REL\` est un test validé : c'est le contrat du dev, il ne se modifie pas pour faire passer l'implémentation."
        echo "Si le test te semble faux ou impossible à satisfaire, arrête-toi et explique-le : c'est une décision humaine. Le verrou se lève en décochant \`Tests valides\` dans \`${plan#"$ROOT"/}\`."
      } >&2
      exit 2
    fi
  done < <(awk '/^## Tests/{f=1; next} /^## /{f=0} f' "$plan" | grep -oE '`[^`]+`' | tr -d '`' | grep -E '[/.]')
done

exit 0
