#!/bin/bash
# Extrait le corps d'une section de CHANGELOG.md sans charger le fichier entier —
# remplace la commande sed recopiée dans pipe-tag, pipe-release et pipe-changelog.
#
# Usage : changelog-section.sh <version>    (1.2.3, v1.2.3 ou Unreleased)
# Sortie : le contenu de la section, sans son titre ni le bloc de liens de
# comparaison, lignes vides de bord retirées. Section absente ou vide → exit 1,
# rien sur stdout.
# Exécuté depuis le plugin (${CLAUDE_SKILL_DIR}/../../shared/scripts/), jamais copié.

ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
FILE="${CHANGELOG_FILE:-$ROOT/CHANGELOG.md}"

[ -n "$1" ] || { echo "Usage : changelog-section.sh <version>" >&2; exit 2; }
[ -f "$FILE" ] || { echo "Pas de CHANGELOG.md dans $ROOT" >&2; exit 1; }

v="${1#v}"
esc=$(printf '%s' "$v" | sed 's/\./\\./g')

# Le titre de section peut être nu (`## [1.2.3] - date`) ou lié
# (`## [1.2.3](url) - date`) : les deux commencent par `## [1.2.3]`.
out=$(sed -n "/^## \[$esc\]/,/^## \[/{/^## \[/d;/^\[[^]]*\]: /d;p;}" "$FILE" \
  | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}')

[ -n "$(printf '%s' "$out" | tr -d '[:space:]')" ] || exit 1
printf '%s\n' "$out" | sed '/./,$!d'
