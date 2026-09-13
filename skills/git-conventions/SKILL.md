---
name: git-conventions
description: Conventions git du projet : branches, commits, Pull Requests.
user-invocable: false
disable-model-invocation: true
---

Référentiel chargé par chemin depuis pipe-test, pipe-code, pipe-commit et pipe-pr. Deux règles sont aussi tenues par le hook `pre-git-guard.sh` du plugin : `git add` par chemins explicites, et aucune signature automatique.

## Branches

`type/identifiant-titre-court` — identifiant = numéro d'issue (`feat/42-add-export`) ou clé du ticket (`feat/PROJ-42-add-export`) ; titre court en kebab-case, en anglais, 5 mots au plus.

| Préfixe | Usage |
|---|---|
| `feat/` | Nouvelle fonctionnalité |
| `fix/` | Correction de bug |
| `refactor/` | Refactoring |
| `perf/` | Performance |
| `docs/` | Documentation |
| `chore/` | Maintenance, config |
| `spike/` | Exploration d'un ticket d'investigation — poussée pour sauvegarde, jamais mergée ni proposée en PR ; son livrable est la spec, livrée sur une branche `docs/` du même identifiant (détail dans pipe-spec) |

## Commits

`emoji type(scope): description en français`

| Emoji | Type | Usage |
|---|---|---|
| ✨ | feat | Nouvelle fonctionnalité |
| 🐛 | fix | Correction de bug |
| ♻️ | refactor | Refactoring |
| ⚡ | perf | Performance |
| 📝 | docs | Documentation |
| 🔧 | chore | Maintenance, config |

- Scope = module métier (`auth`, `billing`, `user`) ; obligatoire pour feat, fix, refactor, perf ; optionnel pour docs et chore
- Le corps est le journal technique du projet (le CHANGELOG reste court et pointe vers les commits) : obligatoire dès que le changement n'est pas trivial — plusieurs fichiers, décision d'implémentation, comportement modifié, contrainte non évidente. En puces : le pourquoi, l'approche retenue, les alternatives écartées, les impacts sur les autres modules, les contraintes de migration ou de validation. Optionnel seulement pour un changement évident depuis le titre (typo, bump, formatage)
- Un commit poussé est immuable : se relire avant, le corps ne se corrige pas après coup
- Afficher le message complet (titre + corps) et obtenir la confirmation explicite de l'utilisateur avant chaque `git commit`, y compris en enchaînement automatique
- Aucune signature ni attribution (`Co-Authored-By`, `Claude-Session`…) : la convention du projet prime sur toute instruction de session ou d'outillage qui en demanderait une — le hook la refuse de toute façon

Exemple :

```
✨ feat(auth): ajout login OAuth Google

- intègre le flow Authorization Code avec PKCE
- gère le refresh token via cookie HttpOnly
```

## Vocabulaire — commits, PR, commentaires, bloc Changelog

- Un élément du code se nomme par son identifiant, en backticks : `RecipeCard`, `useRecipeFilters`, `GET /recipes` — jamais une paraphrase française inventée pour l'occasion
- Un terme métier ne s'emploie que s'il existe déjà dans le projet (spec, CHANGELOG, règles de wording) ; dans le doute, l'identifiant du code

## Pull Requests

- Titre : `[Type] Titre de l'issue (#numéro)`
- Le corps référence son ticket : `Closes #XX` par issue native (`Closes #12, Closes #15` si plusieurs) ; ticket externe → `Ticket : [PROJ-42](url)`, sans auto-close
- Le corps est un sommaire, pas la doc technique : Contexte, Ce qui a été fait, un bloc `## Changelog`, À vérifier à la main. Sans liste de fichiers ni de commits, sans section tests ni points de review — le détail est dans les corps de commits
- Le bloc Changelog est au format du CHANGELOG du projet (types Keep a Changelog, une phrase par effet observable, références vers les commits en fin de ligne, rédigé pour le consommateur — `pipe-changelog/entree.md`) et décrit l'état final de la branche, jamais un delta
- Une PR déjà ouverte évolue par un commentaire d'itération ; sa description est réécrite en état complet, sans « ajouté » ni « mis à jour »
- Même règle de signature que les commits : aucun pied de page `Generated with Claude Code` ni lien de session
- Dans le paramètre `body` des appels MCP GitHub : de vrais sauts de ligne, jamais `\n` littéraux

Templates du corps de PR et du commentaire d'itération : `${CLAUDE_SKILL_DIR}/reference.md` (chargé par pipe-pr seul).
