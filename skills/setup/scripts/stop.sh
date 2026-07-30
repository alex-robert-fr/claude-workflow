#!/bin/bash
# Hook Stop — verifie que les tests passent avant de laisser Claude terminer.
# C'est le garde-fou qui remplace « pense a lancer les tests » adresse au LLM.
#
# Script unique et parametre — seule la commande de test change d'un projet a
# l'autre, elle vient de workflow-config :
#
#   bash .claude/hooks/stop.sh npm run test
#   bash .claude/hooks/stop.sh cargo test
#
# $@ = commande de test du projet.
# Aucun argument → exit 0 : un projet sans commande de test n'est jamais bloque.
#
# SEMANTIQUE DU HOOK Stop, a ne pas improviser :
#   - exit 2 : bloque l'arret, et c'est STDERR qui est transmis a Claude
#   - exit 1 : erreur non bloquante — Claude s'arrete quand meme, sans diagnostic
#   - exit 0 : stdout ne va qu'au journal de debug, Claude ne le voit pas
# Propager le code de retour brut de la commande de test serait donc inerte : un
# `npm test` rouge sort en 1, et Claude terminerait sans jamais l'apprendre.
#
# stop_hook_active protege de la boucle infinie : si Claude a deja ete relance par
# ce hook, on le laisse s'arreter. Sans ce garde-fou, des tests durablement rouges
# bloqueraient la session indefiniment.

[ $# -gt 0 ] || exit 0

# Tolerance : commande passee en une seule chaine ("npm run test").
if [ $# -eq 1 ]; then
  # shellcheck disable=SC2086
  set -- $1
fi

INPUT=$(cat 2>/dev/null)

if [ -n "$INPUT" ] && command -v jq >/dev/null 2>&1; then
  ACTIVE=$(printf '%s' "$INPUT" | jq -r '.stop_hook_active // false' 2>/dev/null)
  [ "$ACTIVE" = "true" ] && exit 0
fi

# La sortie est capturee pour etre renvoyee sur stderr en cas d'echec : c'est le
# seul canal que Claude lit sur un exit 2.
if OUTPUT=$("$@" 2>&1); then
  exit 0
fi

{
  echo "Les tests echouent — la tache n'est pas terminee."
  echo "Commande : $*"
  echo "---"
  printf '%s\n' "$OUTPUT"
} >&2

exit 2
