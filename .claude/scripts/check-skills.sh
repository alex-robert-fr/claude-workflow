#!/bin/bash
# Verifie la coherence mecanique des skills de ce repo.
# Outillage LOCAL — jamais distribue par le plugin, donc jamais appele par un skill
# du pipeline. A lancer a la main apres toute modification de skill ; CLAUDE.md et
# .claude/skills/create-skill/ y renvoient.
#
# Detecte les ecarts a la doctrine maison qu'aucune relecture ne rattrape :
#   - une description trop longue : elle est injectee dans le prompt système de
#     CHAQUE session, c'est un cout permanent
#   - une DIRECTIVE DE CHARGEMENT citant un fichier support OU un autre skill sans
#     chemin qualifie : Read exige un chemin absolu, un nom nu n'est resolvable que
#     depuis le cwd de ce repo, pas depuis un plugin installe
#   - un skill invocable sans $ARGUMENTS : l'argument utilisateur est perdu
#   - un corps trop long sans fichier support : le seuil de delegation n'est pas tenu
#   - le diagramme du pipeline divergent entre ses trois copies

ROOT="${CLAUDE_PROJECT_DIR:-.}"
status=0

# Noms des skills distribues, pour le check 2. Sans cette liste, la detection ne
# porterait que sur les fichiers annexes (reference.md, guide.md) et laisserait
# passer un chargement par nom de skill nu — l'ecart le plus silencieux, puisqu'il
# echoue seulement une fois le plugin installe ailleurs.
skill_names=""
for d in "$ROOT"/skills/*/; do
  [ -d "$d" ] || continue
  skill_names="$skill_names|$(basename "$d")"
done
skill_names="${skill_names#|}"

for skill in "$ROOT"/skills/*/SKILL.md "$ROOT"/.claude/skills/*/SKILL.md; do
  [ -f "$skill" ] || continue
  dir=$(dirname "$skill")
  name=$(basename "$dir")

  # 1. Cout permanent de la description
  desc=$(awk 'NR > 1 && /^---$/ { exit } /^description:/ { sub(/^description:[ \t]*/, ""); print; exit }' "$skill")
  if [ "${#desc}" -gt 130 ]; then
    echo "SKILL $name — description trop longue (${#desc} car, max 130)"
    status=1
  fi

  # 2. Directive de chargement a chemin nu.
  # On ne signale QUE les lignes qui demandent reellement un chargement (Read /
  # charge / charger). Une simple mention en prose ou en cellule de tableau ne
  # produit aucun Read : la signaler serait du bruit, et le bruit fait ignorer
  # le check. On exige ensuite un chemin sur la ligne : ${CLAUDE_SKILL_DIR}/,
  # skills/... ou .claude/...
  #
  # Deux formes de nom nu sont cherchees : un fichier support (reference.md,
  # guide.md) et un AUTRE skill cite en backticks (`git-conventions`). Le nom du
  # skill courant est exclu — il se cite lui-meme sans rien charger. Les backticks
  # sont exiges colles au nom, ce qui laisse passer `/pipe-commit` : une invocation
  # de commande n'est pas un chargement de fichier.
  others=$(printf '%s' "$skill_names" | tr '|' '\n' | grep -vx "$name" | paste -sd'|' -)
  motif='(reference|guide)\.md'
  [ -n "$others" ] && motif="$motif|\`($others)\`"

  while IFS=: read -r ln text; do
    [ -z "$ln" ] && continue
    echo "SKILL $name — chargement a chemin nu ligne $ln : $(printf '%s' "$text" | sed 's/^[ \t*-]*//' | cut -c1-60)"
    status=1
  done < <(grep -nE "$motif" "$skill" \
    | grep -E 'Read|charge|charger' \
    | grep -vE '\$\{CLAUDE_SKILL_DIR\}|(^|[^a-z])(skills|\.claude)/')

  # 3. Skill invocable qui n'exploite pas l'argument utilisateur
  if ! grep -qE '^user-invocable:[ \t]*false' "$skill" && ! grep -qF '$ARGUMENTS' "$skill"; then
    echo "SKILL $name — invocable mais aucun \$ARGUMENTS"
    status=1
  fi

  # 4. Corps > 150 lignes sans aucun fichier support a cote
  fm_end=$(awk 'NR > 1 && /^---$/ { print NR; exit }' "$skill")
  body=$(( $(wc -l < "$skill") - ${fm_end:-0} ))
  if [ "$body" -gt 150 ] && [ -z "$(find "$dir" -maxdepth 1 -type f ! -name 'SKILL.md' -print -quit)" ]; then
    echo "SKILL $name — corps de $body lignes sans fichier support (max 150)"
    status=1
  fi
done

# 5. Le diagramme du pipeline est reproduit a trois endroits : README.md (source),
# CLAUDE.md (aide-memoire de session) et le recap de /setup. Ils avaient déjà
# diverge une fois, le dernier ayant perdu une pause humaine — c'est-a-dire une
# etape ou l'humain decide. On compare la SEQUENCE des skills pipe-*, pas la prose.
#
# Les zones comparees sont ancrees explicitement, jamais devinees : un simple
# `sed '/pipe-spec/,/pipe-pr/p'` attraperait la première mention en prose du
# fichier et produirait une fausse divergence.
#   - README.md et CLAUDE.md : bloc entre <!-- pipeline:debut --> et <!-- pipeline:fin -->
#   - skills/setup/SKILL.md  : la ligne du recap, prefixee `Cycle : `
sequence() {
  # Noms de skills pipe-* dans l'ordre, dedoublonnes a la suite. pipe-ship est
  # ecarte : il reprend le cycle, il n'en est pas une phase.
  grep -oE '/pipe-[a-z]+' \
    | sed 's:^/::' \
    | grep -vx 'pipe-ship' \
    | awk '$0 != prev { print; prev = $0 }' \
    | paste -sd'>' -
}

ancre_bloc() { sed -n '/<!-- pipeline:debut -->/,/<!-- pipeline:fin -->/p' "$1"; }
ancre_recap() { grep '^Cycle : ' "$1"; }

ref=$(ancre_bloc "$ROOT/README.md" 2>/dev/null | sequence)
if [ -z "$ref" ]; then
  echo "PIPELINE — bloc <!-- pipeline:debut --> introuvable dans README.md"
  status=1
else
  compare() {
    [ -f "$ROOT/$1" ] || return 0
    got=$("$2" "$ROOT/$1" 2>/dev/null | sequence)
    if [ -z "$got" ]; then
      echo "PIPELINE — ancre du diagramme introuvable dans $1"
      status=1
    elif [ "$got" != "$ref" ]; then
      echo "PIPELINE — $1 diverge du diagramme de README.md"
      echo "  README.md : $ref"
      echo "  $1 : $got"
      status=1
    fi
  }
  compare "CLAUDE.md" ancre_bloc
  compare "skills/setup/SKILL.md" ancre_recap
fi

[ $status -eq 0 ] && echo "Skills : coherents"
exit $status
