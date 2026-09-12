#!/bin/bash
# Detecteur d'accents francais manquants (substitution ASCII) — deterministe, aucun LLM.
# Recoit le texte a verifier sur stdin, imprime les mots suspects trouves (un par ligne,
# "mot" -> "correction"). Exit 0 si rien trouve, exit 1 si au moins un mot signale.
#
# Volontairement conservateur : seuls des mots dont la forme sans accent ne collisionne
# jamais avec un mot anglais, un identifiant de code ou une autre forme francaise correcte
# sont surveilles. Deux exclusions notables, trouvees par sondage sur ce depot :
#   - "reference" : mot anglais courant (reference.md, "cross-reference"...), la forme
#     francaise correcte cohabite avec des usages anglais legitimes partout dans ce repo
#   - "decision"/"utilise" : "utilise" est correct sans accent a l'imperatif ("utilise Read
#     pour charger" — convention de ce depot) ; "decision" est deja utilise sans accent dans
#     une grande partie du corpus existant (a corriger a part, pas par ce garde-fou)
# Cette liste s'etend au besoin : un mot ajoute ici doit d'abord etre sonde sur le corpus
# existant pour eviter un nouveau faux positif systemique.
#
# Usage : printf '%s' "$TEXTE" | check-accents.sh

WORDS=(
  "deja:déjà"
  "etre:être"
  "francais:français"
  "francaise:française"
  "annee:année"
  "annees:années"
  "probleme:problème"
  "problemes:problèmes"
  "systeme:système"
  "systemes:systèmes"
  "developpement:développement"
  "developpements:développements"
  "fonctionnalite:fonctionnalité"
  "fonctionnalites:fonctionnalités"
  "securite:sécurité"
  "necessaire:nécessaire"
  "necessaires:nécessaires"
  "egalement:également"
  "premiere:première"
  "premieres:premières"
  "derniere:dernière"
  "dernieres:dernières"
  "entierement:entièrement"
  "integralite:intégralité"
  "verite:vérité"
  "qualite:qualité"
  "qualites:qualités"
  "specifique:spécifique"
  "specifiques:spécifiques"
  "generalement:généralement"
  "particulierement:particulièrement"
  "immediatement:immédiatement"
  "veritable:véritable"
  "interet:intérêt"
  "interets:intérêts"
  "recuperer:récupérer"
  "reussite:réussite"
  "procedure:procédure"
  "procedures:procédures"
  "periode:période"
  "periodes:périodes"
)

TEXT=$(cat)
[ -n "$TEXT" ] || exit 0

found=0
for pair in "${WORDS[@]}"; do
  wrong="${pair%%:*}"
  right="${pair#*:}"
  if printf '%s' "$TEXT" | grep -qiwE "$wrong"; then
    echo "\"$wrong\" -> \"$right\""
    found=1
  fi
done

exit $found
