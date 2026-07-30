#!/bin/bash
# Fixe la version du plugin et verifie que le CHANGELOG l'annonce.
# Usage : .claude/scripts/bump-version.sh 1.6.0
#
# Pourquoi un script pour un seul champ : parce que l'oublier est une panne
# TOTALE et SILENCIEUSE. La version de `plugin.json` est la cle de cache des
# mises a jour — la doc officielle est explicite : « If you set version in
# plugin.json, you must bump it every time you want users to receive changes.
# Pushing new commits alone is not enough. » Sans bump, `/plugin update` repond
# « already at the latest version » et personne ne recoit rien. Aucun test, aucune
# review et aucun lint ne rattrape cet oubli : seul un utilisateur le decouvre,
# et il ne peut pas savoir que la faute est la.
#
# Le CHANGELOG n'est pas ecrit ici (c'est le role de /pipe-changelog) : le script
# verifie seulement que la section de la version existe deja.
#
# Ce script est LOCAL a ce repo : la mecanique de publication d'un plugin n'a
# rien a faire dans un skill distribue.

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

[ -f "$PLUGIN" ] || { echo "Fichier introuvable : $PLUGIN" >&2; exit 1; }

# Tout ce qui peut refuser le bump est verifie AVANT d'ecrire : un echec ne doit
# laisser aucun effet de bord. Sinon un CHANGELOG manquant sort en erreur en ayant
# quand meme bumpe la version — l'etat le plus trompeur possible, puisque le repo
# annonce alors une version dont rien ne documente le contenu.

if [ ! -f "$CHANGELOG" ]; then
  echo "CHANGELOG.md introuvable — rien n'a ete modifie" >&2
  exit 1
fi

if ! grep -qF "## [$VERSION]" "$CHANGELOG"; then
  echo "CHANGELOG.md : section [$VERSION] absente — rien n'a ete modifie" >&2
  echo "Lancer d'abord /pipe-changelog $VERSION" >&2
  exit 1
fi

# Garde anti-regression. `plugin.json` gagne dans l'ordre de resolution de version,
# donc une version redeclaree dans le marketplace n'est jamais lue : elle ne casse
# rien, elle ment. Ces champs ont ete retires une fois, ce test empeche leur retour.
if [ -f "$MARKET" ] \
  && jq -e '(.metadata.version? // empty), (.plugins[]?.version? // empty)' "$MARKET" >/dev/null 2>&1; then
  echo "marketplace.json declare une version : champ mort, plugin.json fait autorite" >&2
  echo "La retirer avant de bumper — rien n'a ete modifie" >&2
  exit 1
fi

# jq n'ecrit jamais en place : passer par un temporaire, et ne remplacer qu'en cas
# de succes — un jq en echec ne doit pas laisser un manifeste tronque. La version
# est injectee en variable, jamais interpolee dans le filtre.
tmp=$(mktemp)
if ! jq --arg v "$VERSION" '.version = $v' "$PLUGIN" > "$tmp"; then
  rm -f "$tmp"
  echo "Echec du patch de $PLUGIN" >&2
  exit 1
fi
mv "$tmp" "$PLUGIN"

echo "plugin.json      → $VERSION"
echo "CHANGELOG.md     → section [$VERSION] presente"
echo "marketplace.json → aucune version declaree (correct)"
