---
name: workflow-config
description: Configuration du workflow AI-Driven Development pour ce projet. Contrat entre le plugin et le projet — lu par tous les skills du workflow. Rempli par /setup.
user-invocable: false
---

## Plateforme

- **Git hosting** : <!-- ex: GitHub, GitLab, Gitea -->
- **Issue tracker** : <!-- ex: GitHub Issues, Jira, Linear -->
- **Branche par defaut** : <!-- ex: main, develop -->

## Commandes

- **Lint** : <!-- ex: npx biome check, npx eslint -->
- **Format** : <!-- ex: npx biome check --write, npx prettier --write . -->
- **Test** : <!-- ex: npm run test, npx vitest run, go test ./... -->
- **Build** : <!-- ex: npm run build, tsc --noEmit, go build ./... -->
- **Typecheck** : <!-- ex: tsc --noEmit, mypy . -->

## Notifications

- **Canal** : <!-- ex: #dev-reviews, aucun -->
- **MCP** : <!-- ex: slack, aucun -->

## Conventions

- **Branches** : type/numero-titre
- **Commits** : emoji type(scope): description
- **PR titre** : [Type] Titre de l'issue (#numero)
