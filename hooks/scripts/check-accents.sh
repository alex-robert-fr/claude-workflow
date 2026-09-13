#!/bin/bash
# Détecteur d'accents français manquants (substitution ASCII) — déterministe, aucun LLM.
# Reçoit le texte à vérifier sur stdin, imprime les mots suspects trouvés (un par ligne,
# "mot" -> "correction"). Exit 0 si rien trouvé, exit 1 si au moins un mot signalé.
#
# Volontairement conservateur : seuls des mots dont la forme sans accent ne collisionne
# jamais avec un mot anglais, un identifiant de code ou une autre forme française correcte
# sont surveillés. Deux exclusions notables, trouvées par sondage sur ce dépôt :
#   - "reference" : mot anglais courant (reference.md, "cross-reference"...), la forme
#     française correcte cohabite avec des usages anglais légitimes partout dans ce repo
#   - "decision"/"utilise" : "utilise" est correct sans accent à l'impératif ("utilise Read
#     pour charger" — convention de ce dépôt) ; "decision" est encore écrit sans accent dans
#     une grande partie du corpus existant (à corriger à part, pas par ce garde-fou)
# Cette liste s'étend au besoin : un mot ajouté ici doit d'abord être sondé sur le corpus
# existant pour éviter un nouveau faux positif systémique. Seconde salve (1.9.0) : mots
# sans homographe anglais — écartés pour cette raison : detail, verification, coherent,
# precis, resume, recap, implementer, verifies, decoupage, execute, schema, element.
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
  "creer:créer"
  "generer:générer"
  "preparer:préparer"
  "decouper:découper"
  "ecrire:écrire"
  "reponse:réponse"
  "reponses:réponses"
  "dediee:dédiée"
  "guidee:guidée"
  "apres:après"
  "detecte:détecte"
  "deroule:déroule"
  "versionnee:versionnée"
  "parallele:parallèle"
  "conformite:conformité"
  "regle:règle"
  "regles:règles"
  "outilles:outillés"
  "recapitulatif:récapitulatif"
  "cle:clé"
  "critere:critère"
  "criteres:critères"
  "redige:rédige"
  "rediger:rédiger"
  "reecrit:réécrit"
  "specifie:spécifie"
  "genere:génère"
  "pedagogie:pédagogie"
  "pedagogique:pédagogique"
  "implemente:implémente"
  "defaut:défaut"
  "demarrage:démarrage"
  "demarre:démarre"
  "memoire:mémoire"
  "dependance:dépendance"
  "dependances:dépendances"
  "etape:étape"
  "etapes:étapes"
  "deploiement:déploiement"
  "mecanique:mécanique"
  "resultat:résultat"
  "modele:modèle"
  "verifie:vérifie"
  "equipe:équipe"
  "operationnel:opérationnel"
  "requete:requête"
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
