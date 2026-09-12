---
name: workflow-config
description: Config du workflow pour ce projet : plateforme, commandes, stack, conventions. Lu par tous les skills. Rempli par /setup.
user-invocable: false
disable-model-invocation: true
---

<!-- Référentiel de config : lu par Read depuis les skills du pipeline, jamais
     invoqué. Flags documentés dans .claude/skills/create-skill/reference.md,
     section "Frontmatter — contrôle d'invocation". -->

## Plateforme

- **Git hosting** : GitHub (`alex-robert-fr/claude-workflow`)
- **Issue tracker** : GitHub Issues
- **Statut ticket à la release** : sans objet — Issue tracker = GitHub Issues
- **Branche par defaut** : `develop` — base des features et cible de leurs PRs
- **Branche de production** : `main` — cible des PRs de release

## Commandes

- **Lint** : aucune — `shellcheck` n'est pas installe sur la machine
- **Format** : aucune — ni `prettier`, ni `shfmt`, ni `markdownlint`
- **Test** : `bash .claude/scripts/check-skills.sh` — ce repo n'a pas de suite de tests, ses checks de cohérence en tiennent lieu. `bash .claude/scripts/check-specs.sh` complète la verification et est appele par `/pipe-review`
- **Build** : aucune — un plugin Claude Code est distribue tel quel
- **Typecheck** : aucune

Outillage local du repo (voir Architecture) — aucun skill ne peut les appeler par lui-même.

## Stack technique

- **Backend / Frontend** : aucun
- **Langages** : markdown (skills, fichiers supports), bash (hooks, checks)
- **Dépendances** : aucune — seul `jq` est requis (`session-start.sh`, `check-specs.sh`)

## Architecture

- Un skill = un repertoire `nom/SKILL.md` avec frontmatter obligatoire
- `skills/` est **distribue** par le plugin ; `.claude/` porte l'outillage local du repo et ne sort jamais d'ici
- Les fichiers supports d'un skill sont lus a la demande, et toujours depuis un chemin qualifie — jamais references depuis le frontmatter, dont le cout est permanent
- Les scripts sont des fichiers, jamais des blocs de code dans un markdown

## Conventions de nommage

| Contexte | Convention |
|----------|-----------|
| Fichiers | `kebab-case` |
| Code (variables, fonctions, proprietes) | bash : fonctions en `snake_case`, variables d'environnement et constantes en `MAJUSCULES` |
| Identifiants (IDs) | sans objet — le plugin ne persiste rien |

Le français du repo s'ecrit **sans accents**, dans les skills comme dans la documentation.

## Notifications

- **Canal** : aucun
- **MCP** : aucun
