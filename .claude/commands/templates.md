# Commande /templates

Initialise ou met à jour les fichiers templates projet-specific dans `.claude/skills/`. Détecte automatiquement ce qui est possible et pose des questions pour le reste.

## Étape 0 — Vérifications

1. Vérifie que `.claude/skills/` existe dans le projet courant
2. Scanne tous les fichiers `.md` dans `.claude/skills/` pour trouver ceux contenant des placeholders `<!-- ... -->`
3. Si aucun placeholder trouvé → affiche "Tous les templates sont déjà remplis." et arrête-toi

### Si un argument est fourni — Mode ciblé

Filtre sur le template dont le nom correspond à `$ARGUMENTS` (ex: `code-conventions`).
Si le fichier n'existe pas ou n'a aucun placeholder → signale-le et arrête-toi.

### Si aucun argument — Mode global

Traite tous les templates contenant des placeholders.

## Étape 1 — Auto-détection

Analyse le projet (fichiers de config, dépendances, structure de dossiers, code source) pour proposer une valeur à chaque placeholder.

## Étape 2 — Récap et questions

Pour chaque template, affiche un tableau :

| Champ | Valeur proposée |
|-------|----------------|
| ... | valeur détectée ou ❓ Non détecté |

- Pour chaque champ ❓ → pose la question à l'utilisateur
- Pour les champs détectés → demande confirmation globale
- L'utilisateur peut corriger n'importe quelle valeur

## Étape 3 — Écriture

Une fois confirmé :

1. Remplace chaque placeholder `<!-- ... -->` par la valeur validée
2. Ne touche pas aux champs déjà remplis (sans placeholder)
3. Affiche le résultat par fichier modifié

---

## Input utilisateur

$ARGUMENTS
