#!/bin/bash
# Hook PostToolUse — lance le formateur/linter du projet sur le fichier ecrit.
# Le formatage est deterministe : il ne doit jamais dependre du LLM.
#
# Script unique et parametre — chaque stack se resume a une liste d'extensions et
# une commande, il n'y a donc rien a reecrire par stack, seulement a configurer :
#
#   bash .claude/hooks/post-tool-use.sh 'ts|tsx|js|jsx|json|css' 'npx biome check --write'
#   bash .claude/hooks/post-tool-use.sh 'py' 'ruff format'
#
# $1   = extensions concernees, separees par |, SANS point ni antislash
# $2.. = commande de format/lint ; le fichier est ajoute en dernier argument
#
# Pourquoi une liste et non une regex : cet argument vit dans une chaine JSON de
# .claude/settings.json, et une regex du type `\.(ts|tsx)$` y est un echappement
# invalide — le settings.json devient illisible et les quatre hooks meurent d'un
# coup, en silence. La regex est donc construite ici, jamais transportee.
#
# Recoit le JSON du hook sur stdin. Ne bloque JAMAIS l'ecriture : un linter absent,
# un payload malforme ou un crash du formateur sortent en 0 sans un mot.
# Plusieurs commandes = plusieurs entrees de hook.

EXTS="$1"
shift
CMD="$*"
[ -n "$EXTS" ] || exit 0
[ -n "$CMD" ] || exit 0

# jq absent : le hook est inerte, pas en erreur.
command -v jq >/dev/null 2>&1 || exit 0

INPUT=$(cat)

# stderr etouffe : un stdin non-JSON ne doit pas polluer la sortie du hook.
FILE=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -n "$FILE" ] || exit 0

[[ "$FILE" =~ \.($EXTS)$ ]] || exit 0

# Decoupage en mots volontaire : la commande arrive en une chaine.
# shellcheck disable=SC2086
$CMD "$FILE" 2>/dev/null || true
exit 0
