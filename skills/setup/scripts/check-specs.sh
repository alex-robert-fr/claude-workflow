#!/bin/bash
# Verifie la coherence mecanique des specs de docs/specs/
# Appele par /pipe-review dans ses checks outilles. Ce n'est pas un hook.
#
# Detecte ce qu'un agent repere mal :
#   - un point d'entree qui pointe vers un fichier disparu
#   - une spec dont TOUS les points d'entree ont disparu : la feature a
#     probablement ete retiree, la spec doit etre depreciee et non corrigee
#   - une spec absente de l'index (donc jamais injectee dans le contexte)
#
# Une spec au statut depreciee est exclue du controle des chemins : ses fichiers
# ont disparu par construction, la signaler eternellement serait du bruit.

ROOT="${CLAUDE_PROJECT_DIR:-.}"
SPECS="$ROOT/docs/specs"
[ -d "$SPECS" ] || exit 0

status=0

for spec in "$SPECS"/*.md; do
  [ -e "$spec" ] || continue
  base=$(basename "$spec")
  [ "$base" = "README.md" ] && continue

  if [ -f "$SPECS/README.md" ] && ! grep -qF "$base" "$SPECS/README.md"; then
    echo "SPEC $base — absente de l'index docs/specs/README.md"
    status=1
  fi

  # Statut depreciee : plus rien a verifier cote fichiers
  grep -qiE '^>.*statut.*:.*d[eé]preci' "$spec" && continue

  # Points d'entree : premiere colonne du tableau de la section uniquement.
  # La colonne Role cite souvent d'autres chemins — les lire produirait des faux positifs.
  # Les lignes marquees (a creer) sont ignorees : une spec precede le dev.
  total=0
  dead=0
  dead_list=""
  while IFS= read -r p; do
    [ -z "$p" ] && continue
    total=$((total + 1))
    if [ ! -e "$ROOT/$p" ]; then
      dead=$((dead + 1))
      dead_list="$dead_list $p"
    fi
  done < <(awk '/^## Points d.entree/{f=1;next} /^## /{f=0} f && /^\|/ && !/\([aà] *cr[eé]er\)/' "$spec" \
    | awk -F'|' '{print $2}' \
    | grep -oE '`[^`]+`' | tr -d '`')

  if [ "$dead" -gt 0 ] && [ "$dead" -eq "$total" ]; then
    # Signal fort : la feature n'existe plus. Deprecier, pas rafistoler.
    echo "SPEC $base — tous les points d'entree ont disparu ($total) : feature retiree ? a deprecier"
    status=1
  else
    for p in $dead_list; do
      echo "SPEC $base — point d'entree introuvable : $p"
      status=1
    done
  fi
done

[ $status -eq 0 ] && echo "Specs : coherentes"
exit $status
