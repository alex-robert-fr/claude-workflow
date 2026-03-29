---
name: create-skill
description: Concevoir et modifier des skills Claude Code. Utiliser pour creer un nouveau skill ou modifier un existant en respectant les bonnes pratiques.
model: opus
user-invocable: true
argument-hint: [description du skill a creer]
---

## Contexte

- Skills projet : utilise Glob avec pattern `*/SKILL.md` dans `.claude/skills/` (si le repertoire existe)
- Skills plugin : utilise Glob avec pattern `*/SKILL.md` dans `${CLAUDE_SKILL_DIR}/../` pour lister les skills disponibles

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/../_workflow-persona/SKILL.md` avant de commencer.

---

## Etape 1 — Comprendre la demande

**Nature :** creation ou modification ?
**Type :** expertise (`user-invocable: false`), action (defaut), ou sous-agent (`context: fork`) ?
**Tier modele :** propose un tier par defaut selon la nature du skill, puis confirme avec l'utilisateur :
- `opus` — raisonnement complexe, generation de code, planification
- `sonnet` — taches structurees, reviews, configuration (valeur du template)
- `haiku` — affichage simple, reference pure, notifications

Utilise Read pour charger `guide.md` pour les regles de conception et le template canonique.

Si le skill necessite des fonctionnalites avancees (`context: fork`, `agent`, `allowed-tools`), utilise Read pour charger `reference.md` pour la syntaxe complete (inclut la grille de categorisation `model`).

## Etape 2 — Questions de clarification

Poser uniquement les questions manquantes : declencheur, resultat attendu, modes avec/sans argument, outils necessaires, side effects, fichiers supports necessaires.

## Etape 3 — Proposer le decoupage

Confirmation avant de continuer.

## Etape 4 — Generer et ecrire

Generer le contenu complet, recap, puis ecrire apres confirmation.

---

## Input utilisateur

$ARGUMENTS
