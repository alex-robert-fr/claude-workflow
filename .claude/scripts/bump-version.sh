#!/bin/bash
# Synchronise la version du plugin dans les trois fichiers qui doivent la porter.
# Usage : .claude/scripts/bump-version.sh 1.6.0
#
# Pourquoi un script : la version est declaree a QUATRE endroits (plugin.json,
# marketplace.json x2, CHANGELOG.md). Un oubli desynchronise la version annoncee
# dans la marketplace publique de celle du plugin installe — panne silencieuse.
# C'est un travail deterministe : il ne se confie pas a un LLM.
#
# Le CHANGELOG n'est pas ecrit ici (c'est le role de /pipe-changelog) : le script
# verifie seulement que la section de la version existe deja.

set -eu

ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || echo .)}"
VERSION="${1:-}"

if [ -z "$VERSION" ]; then
  echo "usage: $(basename "$0") X.Y.Z" >&2
  exit 2
fi

if ! printf '%s' "$VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
  echo "Version invalide : '$VERSION' (attendu X.Y.Z, sans prefixe v)" >&2
  exit 2
fi

command -v jq >/dev/null 2>&1 || { echo "jq requis" >&2; exit 2; }

PLUGIN="$ROOT/.claude-plugin/plugin.json"
MARKET="$ROOT/.claude-plugin/marketplace.json"
CHANGELOG="$ROOT/CHANGELOG.md"

for f in "$PLUGIN" "$MARKET"; do
  [ -f "$f" ] || { echo "Fichier introuvable : $f" >&2; exit 1; }
done

# jq n'ecrit jamais en place : passer par un temporaire, et ne remplacer qu'en cas de succes.
# $1 = fichier, $2 = filtre jq. La version est injectee en variable $v (jamais interpolee
# dans le filtre : une version non validee ne doit pas pouvoir devenir du code jq).
patch() {
  tmp=$(mktemp)
  if jq --arg v "$VERSION" "$2" "$1" > "$tmp"; then
    mv "$tmp" "$1"
  else
    rm -f "$tmp"
    echo "Echec du patch de $1" >&2
    exit 1
  fi
}

patch "$PLUGIN" '.version = $v'
patch "$MARKET" '.metadata.version = $v | .plugins[0].version = $v'

echo "plugin.json          → $VERSION"
echo "marketplace.json     → $VERSION (metadata + plugins[0])"

status=0
if [ -f "$CHANGELOG" ]; then
  if grep -qF "## [$VERSION]" "$CHANGELOG"; then
    echo "CHANGELOG.md         → section [$VERSION] presente"
  else
    echo "CHANGELOG.md         → section [$VERSION] ABSENTE : lancer /pipe-changelog $VERSION" >&2
    status=1
  fi
else
  echo "CHANGELOG.md         → fichier absent" >&2
  status=1
fi

# Filet : aucune autre occurrence de l'ancienne version ne doit subsister dans les manifests.
reste=$(grep -oE '"version": *"[0-9]+\.[0-9]+\.[0-9]+"' "$PLUGIN" "$MARKET" | grep -vF "\"$VERSION\"" || true)
if [ -n "$reste" ]; then
  echo "Versions desynchronisees restantes :" >&2
  printf '%s\n' "$reste" >&2
  status=1
fi

exit $status
