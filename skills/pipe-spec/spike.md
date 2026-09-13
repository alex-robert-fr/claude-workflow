# Ticket d'investigation (spike)

Chargé par `/pipe-spec` quand le ticket est une question à trancher, pas une feature à développer. Son livrable est la **spec** de la feature concernée (création ou mise à jour, décisions et hors-scope compris), jamais du code livré.

- Annonce : « ticket d'investigation, livrable = spec `<feature>` »
- Pilotage : coche d'office `Plan valide`, `Tests ecrits`, `Tests valides`, `Dev termine`, `Code valide` avec `(sans objet — spike)` ; section Branche : `spike/<identifiant>-<titre-court>` (exploration) et `docs/<identifiant>-<titre-court>` (livraison de la spec)
- Exploration (étape 3) : du code jetable sur `spike/` — prototype, stories, variantes d'écran. Piste retenue → Comportement attendu ; pistes écartées → Décisions avec leur raison. Commits au fil de l'eau sur `spike/` (validation humaine, corps facultatif : rien n'est livré). La branche est poussée pour sauvegarde, jamais nettoyée ni mergée : réécrire depuis la spec coûte moins que trier un prototype
- Suite (étape 8) : `git switch -c docs/<identifiant>-<titre-court> <branche d'intégration>` (la spec non committée suit), puis `/pipe-commit` et `/pipe-pr` de la spec seule — `/pipe-ship` enchaîne du cadrage aux commits
- Une fois la spec mergée : supprimer `spike/`, clore le ticket avec un commentaire vers la spec, créer les tickets de dev (`/create-issue`) liés au ticket d'investigation — chacun repart de la branche d'intégration avec un cycle complet
- Exception : la réponse tient en un changement évident → pas de nouveau ticket, le ticket d'investigation devient le ticket de dev (label et description mis à jour), cycle normal depuis `/pipe-plan` sur une branche `feat/` neuve
