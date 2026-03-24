---
name: templates
description: Initialiser ou remplir les fichiers templates projet-specific dans .claude/skills/. Detecte les placeholders et propose des valeurs. Utiliser apres /init pour configurer les conventions du projet.
argument-hint: [nom du template ou rien pour tous]
---

Initialise ou met a jour les fichiers templates projet-specific dans `.claude/skills/`. Detecte automatiquement ce qui est possible et pose des questions pour le reste.

## Etape 0 — Verifications

1. Verifie que `.claude/skills/` existe dans le projet courant
2. Scanne tous les fichiers `.md` dans `.claude/skills/` pour trouver ceux contenant des placeholders `<!-- ... -->`
3. Si aucun placeholder trouve → affiche "Tous les templates sont deja remplis." et arrete-toi

### Si un argument est fourni — Mode cible

Filtre sur le template dont le nom correspond a `$ARGUMENTS` (ex: `tech-stack`).
Si le fichier n'existe pas ou n'a aucun placeholder → signale-le et arrete-toi.

### Si aucun argument — Mode global

Traite tous les templates contenant des placeholders.

## Etape 1 — Auto-detection

Analyse le projet (fichiers de config, dependances, structure de dossiers, code source) pour proposer une valeur a chaque placeholder.

## Etape 2 — Recap et questions

Pour chaque template, affiche un tableau :

| Champ | Valeur proposee |
|-------|----------------|
| ... | valeur detectee ou ? Non detecte |

- Pour chaque champ ? → pose la question a l'utilisateur
- Pour les champs detectes → demande confirmation globale
- L'utilisateur peut corriger n'importe quelle valeur

## Etape 3 — Ecriture

Une fois confirme :

1. Remplace chaque placeholder `<!-- ... -->` par la valeur validee
2. Ne touche pas aux champs deja remplis (sans placeholder)
3. Affiche le resultat par fichier modifie

---

## Input utilisateur

$ARGUMENTS
