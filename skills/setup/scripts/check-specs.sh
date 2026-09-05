#!/bin/bash
# Verifie la coherence mecanique des specs de docs/specs/
# Appele par /pipe-review dans ses checks outilles. Ce n'est pas un hook.
#
# Detecte ce qu'un agent repere mal :
#   - un point d'entree qui pointe vers un fichier disparu
#   - une spec dont TOUS les points d'entree ont disparu : la feature a
#     probablement ete retiree, la spec doit etre depreciee et non corrigee
#   - une spec absente de l'index (donc jamais injectee dans le contexte)
#   - une ligne d'index pointant vers une spec disparue : le seul ecart qui
#     injecte de la FAUSSE information dans chaque session, pas de l'absence
#   - une phrase d'index trop longue : l'index est injecte a chaque session,
#     c'est le seul poste de contexte qui grossit tout seul
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

  # Bornes autour du nom : sans elles `csv.md` serait trouve dans `export-csv.md`.
  # Le point du nom est echappe — sinon il matche n'importe quel caractere.
  esc=${base//./\\.}
  if [ -f "$SPECS/README.md" ] && ! grep -qE "(^|[^A-Za-z0-9._-])$esc([^A-Za-z0-9]|$)" "$SPECS/README.md"; then
    echo "SPEC $base — absente de l'index docs/specs/README.md"
    status=1
  fi

  # Statut depreciee : plus rien a verifier cote fichiers
  # Meme precaution de locale que dans session-start.sh (voir son commentaire).
  awk '/^>/ { t = tolower($0); gsub(/[^ -~]/, "", t)
              if (t ~ /statut.*:.*de*pre*ci/) { found = 1; exit } }
       END { exit !found }' "$spec" && continue

  # Points d'entree : premiere colonne du tableau de la section uniquement.
  # La colonne Role cite souvent d'autres chemins — les lire produirait des faux positifs.
  # Les lignes marquees (a creer) sont ignorees : une spec precede le dev.
  #
  # Deux formats coexistent le temps de la migration vers les liens :
  #   - `chemin/reel.ts` (ancien) : backtick seul, chemin complet relatif a $ROOT
  #   - [nom.ts](../../chemin/reel.ts) (nouveau) : lien markdown, chemin relatif a $SPECS
  # Le lien est tente en premier ; sans lien, on retombe sur le backtick.
  total=0
  dead=0
  dead_list=()
  while IFS= read -r cell; do
    [ -z "$cell" ] && continue
    href=$(printf '%s' "$cell" | grep -oE '\]\([^)]+\)' | head -1 | sed 's/^](//; s/)$//')
    if [ -n "$href" ]; then
      full="$SPECS/$href"
    else
      bt=$(printf '%s' "$cell" | grep -oE '`[^`]+`' | head -1 | tr -d '`')
      [ -z "$bt" ] && continue
      full="$ROOT/$bt"
    fi
    total=$((total + 1))
    if [ ! -e "$full" ]; then
      dead=$((dead + 1))
      dead_list+=("$full")
    fi
  done < <(awk '/^## Points d.entree/{f=1;next} /^## /{f=0} f && /^\|/ && !/\([aà] *cr[eé]er\)/' "$spec" \
    | awk -F'|' '{print $2}')

  if [ "$dead" -gt 0 ] && [ "$dead" -eq "$total" ]; then
    # Signal fort : la feature n'existe plus. Deprecier, pas rafistoler.
    echo "SPEC $base — tous les points d'entree ont disparu ($total) : feature retiree ? a deprecier"
    status=1
  else
    for p in "${dead_list[@]}"; do
      echo "SPEC $base — point d'entree introuvable : $p"
      status=1
    done
  fi
done

if [ -f "$SPECS/README.md" ]; then
  # Sens inverse : une ligne d'index pointant vers une spec supprimee ou renommee
  # continue d'etre injectee dans chaque session par le hook SessionStart.
  #
  # On ne retient que les CIBLES DE LIEN `](nom.md)` dont le nom est un simple
  # basename, jamais un chemin. Extraire tout ce qui ressemble a `*.md` ferait
  # remonter le moindre chemin cite en prose (`docs/specs/README.md`, un lien vers
  # `../CONTRIBUTING.md`) comme une spec disparue — un check bruyant finit ignore.
  while IFS= read -r ref; do
    [ -z "$ref" ] && continue
    [ "$ref" = "README.md" ] && continue
    [ -e "$SPECS/$ref" ] && continue
    echo "SPEC $ref — reference dans l'index mais fichier introuvable"
    status=1
  done < <(grep -oE '\]\([A-Za-z0-9._-]+\.md\)' "$SPECS/README.md" \
    | sed 's/^](//; s/)$//' | sort -u)

  # Plafond de la derniere colonne : l'index est injecte a chaque session, il ne
  # peut pas grossir librement. Le message est formate en bash — l'apostrophe de
  # « d'index » ne passerait pas dans un programme awk entre quotes simples.
  while IFS=$'\t' read -r name len; do
    [ -z "$name" ] && continue
    echo "SPEC $name — phrase d'index trop longue ($len car, max 80)"
    status=1
  done < <(awk -F'|' '
    /^\|[ \t:|-]+$/ { body = 1; next }
    !body { next }
    /^\|/ && NF > 2 {
      last = $(NF - 1)
      gsub(/^[ \t]+/, "", last); gsub(/[ \t]+$/, "", last)
      if (length(last) <= 80) next
      name = $2
      gsub(/^[ \t]+/, "", name); gsub(/[ \t]+$/, "", name)
      if (match($0, /[A-Za-z0-9._-]+\.md/)) name = substr($0, RSTART, RLENGTH)
      print name "\t" length(last)
    }' "$SPECS/README.md")
fi

[ $status -eq 0 ] && echo "Specs : coherentes"
exit $status
