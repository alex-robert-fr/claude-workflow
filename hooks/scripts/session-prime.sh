#!/bin/bash
# Hook SessionStart (plugin) — injecte un rappel court de style au demarrage de chaque
# session, pour que le premier passage soit deja correct au lieu de dependre uniquement
# des garde-fous qui corrigent apres coup (pre-write-accents.sh, stop-quality.sh).
#
# additionalContext est le seul canal garanti pour injecter du contexte ; jq -Rs echappe
# le texte, ne jamais construire ce JSON a la main. suppressOutput evite de l'afficher dans
# le transcript a chaque demarrage. Cout : quelques lignes, payees a chaque session — d'ou
# le format telegraphique, pas une explication.

command -v jq >/dev/null 2>&1 || exit 0

RAPPEL="Rappel de style (verifie ensuite par des garde-fous automatiques du plugin) :
- Reponses directes et specs (docs/specs/) : va droit au fait, coupe ce qui n'apprend rien, aucune phrase d'introduction ou de transition.
- Avant une question technique de clarification, ou pour expliquer un choix : donne d'abord une vue haut niveau simple, en langage non technique. Ne creuse le detail que si on te le demande.
- Francais avec tous ses accents, toujours — y compris dans les commits et les Pull Requests."

printf '%s' "$RAPPEL" | jq -Rs \
  '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: .}, suppressOutput: true}'
