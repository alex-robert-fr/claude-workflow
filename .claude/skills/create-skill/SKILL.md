---
name: create-skill
description: Concevoir ou modifier un skill Claude Code selon la doctrine de ce repo.
user-invocable: true
argument-hint: [description du skill a creer]
---

## Contexte

- Skills projet : utilise Glob avec pattern `*/SKILL.md` dans `.claude/skills/` (si le repertoire existe)
- Skills plugin : utilise Glob avec pattern `*/SKILL.md` dans `skills/` (repo du plugin)

### Conventions de ce repo

- Nommage : `kebab-case`, chaque skill est un repertoire `nom/SKILL.md`
- Prefixes : `pipe-*` (pipeline), `create-*` (artefacts), `setup-*` (config), `*-conventions` (expertise)
- Skills invocables : `user-invocable: true` (defaut). Skills expertise : `user-invocable: false`
- `$ARGUMENTS` toujours en fin de skill invocable
- Pas de champ `model` dans le frontmatter : il bascule reellement le modele pour le reste du tour (auto-invocation comprise) et peut retrograder la session. Voir `reference.md` section `model`
- Les fichiers de `skills/` sont distribues via le plugin ; ceux de `.claude/skills/` sont l'outillage local du repo. Ne jamais mettre de logique specifique a un projet dans un skill partage

`.claude/scripts/check-skills.sh` verifie mecaniquement ce qui est verifiable : longueur des descriptions, chemins de chargement qualifies, `$ARGUMENTS` present, seuil de delegation, concordance des trois copies du diagramme du pipeline. **Le lancer a la main apres toute modification de skill** — c'est de l'outillage local a ce repo, aucun skill du pipeline ne peut l'appeler.

---

## Etape 1 — Comprendre la demande

**Nature :** creation ou modification ?
**Type :** expertise (`user-invocable: false`), action (defaut), ou sous-agent (`context: fork`) ?

Utilise Read pour charger `.claude/skills/create-skill/guide.md` pour les regles de conception et le template canonique.

Si le skill necessite des fonctionnalites avancees (`context: fork`, `agent`, `allowed-tools`), utilise Read pour charger `.claude/skills/create-skill/reference.md` pour la syntaxe complete.

## Etape 2 — Questions de clarification

Poser uniquement les questions manquantes : declencheur, resultat attendu, modes avec/sans argument, outils necessaires, side effects, fichiers supports necessaires.

## Etape 3 — Proposer le decoupage

Confirmation avant de continuer.

## Etape 4 — Generer et ecrire

Generer le contenu complet, recap, puis ecrire apres confirmation.

---

## Input utilisateur

$ARGUMENTS
