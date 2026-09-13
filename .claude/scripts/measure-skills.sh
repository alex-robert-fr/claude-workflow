#!/bin/bash
# Mesure le coût de chargement de chaque skill distribué : le SKILL.md seul, puis
# le SKILL.md plus la fermeture transitive des fichiers markdown qu'il charge via
# ${CLAUDE_SKILL_DIR}/... (références, templates partagés, autres skills).
#
# Outillage LOCAL, jamais distribué. À lancer avant et après une refonte pour
# savoir ce qu'on a gagné — sans mesure, une compression est une impression.
#
# Tokens estimés = mots × 1,35 (ordre de grandeur pour du français accentué).
# Le chiffre « graphe » est un MAJORANT : certains fichiers ne sont chargés que sur
# un chemin conditionnel (rendu.md sur constat, inventaire.md sans argument) ou
# par un sub-agent hors contexte principal (reference.md de pipe-review).
#
# Usage : .claude/scripts/measure-skills.sh [--md]   (--md : sortie en tableau markdown)

ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
SKILLS="$ROOT/skills"
md=0; [ "$1" = "--md" ] && md=1

words() { cat "$@" 2>/dev/null | wc -w; }
lines() { cat "$@" 2>/dev/null | wc -l; }
tok()   { awk -v w="$1" 'BEGIN { printf "%d", w * 1.35 }'; }

# Fichiers .md référencés par ${CLAUDE_SKILL_DIR}/... dans un fichier, résolus
# depuis le répertoire du skill d'origine.
refs_of() {
  local file="$1" skilldir="$2"
  grep -oE '\$\{CLAUDE_SKILL_DIR\}/[^` )"]+\.md' "$file" 2>/dev/null \
    | sed "s#\${CLAUDE_SKILL_DIR}#$skilldir#" \
    | while read -r p; do realpath -m "$p"; done \
    | sort -u
}

# Fermeture transitive : les fichiers annexes citent parfois d'autres annexes
# avec ${CLAUDE_SKILL_DIR} relatif à LEUR skill — on résout depuis le répertoire
# du fichier courant, ce qui couvre les deux cas (annexe du même skill, ou
# fichier d'un autre skill qui se cite lui-même).
closure() {
  local skill="$1" seen="" queue
  queue="$SKILLS/$skill/SKILL.md"
  while [ -n "$queue" ]; do
    local f="${queue%%$'\n'*}"
    queue="${queue#"$f"}"; queue="${queue#$'\n'}"
    case "$seen" in *"$f"*) continue ;; esac
    [ -f "$f" ] || continue
    seen="$seen$f"$'\n'
    local d; d=$(dirname "$f")
    local r; r=$(refs_of "$f" "$d")
    [ -n "$r" ] && queue="$queue${queue:+$'\n'}$r"
  done
  printf '%s' "$seen"
}

total_skill=0; total_graph=0
if [ $md -eq 1 ]; then
  echo "| Skill | SKILL.md (lignes / mots / ~tokens) | Graphe (fichiers / mots / ~tokens) |"
  echo "|---|---|---|"
else
  printf '%-18s %8s %8s %8s   %6s %8s %8s\n' SKILL lignes mots tokens fich. mots tokens
fi

for dir in "$SKILLS"/*/; do
  name=$(basename "$dir")
  s="$dir/SKILL.md"; [ -f "$s" ] || continue
  sl=$(lines "$s"); sw=$(words "$s"); st=$(tok "$sw")
  files=$(closure "$name")
  n=$(printf '%s' "$files" | grep -c .)
  gw=$(printf '%s' "$files" | tr '\n' '\0' | xargs -0 cat 2>/dev/null | wc -w); gt=$(tok "$gw")
  total_skill=$((total_skill + sw)); total_graph=$((total_graph + gw))
  if [ $md -eq 1 ]; then
    echo "| $name | $sl / $sw / $st | $n / $gw / $gt |"
  else
    printf '%-18s %8s %8s %8s   %6s %8s %8s\n' "$name" "$sl" "$sw" "$st" "$n" "$gw" "$gt"
  fi
done

if [ $md -eq 1 ]; then
  echo "| **Total** | $total_skill mots / ~$(tok "$total_skill") tokens | $total_graph mots / ~$(tok "$total_graph") tokens |"
else
  printf '%-18s %8s %8s %8s   %6s %8s %8s\n' TOTAL "" "$total_skill" "$(tok "$total_skill")" "" "$total_graph" "$(tok "$total_graph")"
fi
