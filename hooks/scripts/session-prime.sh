#!/bin/bash
# Hook SessionStart (plugin) — injecte un rappel court de style au démarrage de chaque
# session, pour que le premier passage soit déjà correct au lieu de dépendre uniquement
# des garde-fous qui corrigent après coup (pre-write-accents.sh, stop-quality.sh).
#
# additionalContext est le seul canal garanti pour injecter du contexte ; jq -Rs échappe
# le texte, ne jamais construire ce JSON à la main. suppressOutput évite de l'afficher dans
# le transcript à chaque démarrage. Coût : quelques lignes, payées à chaque session — d'où
# le format télégraphique, pas une explication.

command -v jq >/dev/null 2>&1 || exit 0

RAPPEL="Rappel de style (vérifié ensuite par des garde-fous automatiques du plugin) :
- Réponses directes et specs (docs/specs/) : va droit au fait, coupe ce qui n'apprend rien, aucune phrase d'introduction ou de transition.
- Avant une question technique de clarification, ou pour expliquer un choix : donne d'abord une vue haut niveau simple, en langage non technique. Ne creuse le détail que si on te le demande.
- Français avec tous ses accents, toujours — y compris dans les commits, les Pull Requests et les commentaires de code."

printf '%s' "$RAPPEL" | jq -Rs \
  '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: .}, suppressOutput: true}'
