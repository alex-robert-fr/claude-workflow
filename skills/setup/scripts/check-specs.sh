#!/bin/bash
# Verifie la coherence mecanique des specs de docs/specs/
# Appele par /pipe-review dans ses checks outilles. Ce n'est pas un hook.
#
# Detecte ce qu'un agent repere mal :
#   - un point d'entree qui pointe vers un fichier disparu
#   - une spec absente de l'index (donc jamais injectee dans le contexte)

ROOT="${CLAUDE_PROJECT_DIR:-.}"
SPECS="$ROOT/docs/specs"
[ -d "$SPECS" ] || exit 0

status=0

for spec in "$SPECS"/*.md; do
  [ -e "$spec" ] || continue
  base=$(basename "$spec")
  [ "$base" = "README.md" ] && continue

  # Points d'entree : premiere colonne du tableau de la section uniquement.
  # La colonne Role cite souvent d'autres chemins — les lire produirait des faux positifs.
  # Les lignes marquees (a creer) sont ignorees : une spec precede le dev.
  while IFS= read -r p; do
    [ -z "$p" ] && continue
    [ -e "$ROOT/$p" ] || { echo "SPEC $base — point d'entree introuvable : $p"; status=1; }
  done < <(awk '/^## Points d.entree/{f=1;next} /^## /{f=0} f && /^\|/ && !/\([aà] *cr[eé]er\)/' "$spec" \
    | awk -F'|' '{print $2}' \
    | grep -oE '`[^`]+`' | tr -d '`')

  if [ -f "$SPECS/README.md" ] && ! grep -qF "$base" "$SPECS/README.md"; then
    echo "SPEC $base — absente de l'index docs/specs/README.md"
    status=1
  fi
done

[ $status -eq 0 ] && echo "Specs : coherentes"
exit $status
