---
name: workflow-config
description: Configuration du workflow AI-Driven Development pour ce projet. Contrat unique entre le plugin et le projet — plateforme, commandes, stack et conventions, lu par tous les skills du workflow. Rempli par /setup.
user-invocable: false
---

## Projet

- **Niveau** : <!-- A (produit vivant : pipeline complet) | B (script/outil : code, tests, commit — pas de changelog ni review formelle) -->

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

## Stack technique

### Backend
- **Framework** : <!-- ex: NestJS + Fastify -->
- **ORM** : <!-- ex: TypeORM, Prisma, Drizzle -->
- **Base de donnees** : <!-- ex: PostgreSQL, MongoDB -->

### Frontend
- **Framework** : <!-- ex: Nuxt 4, Next.js, SvelteKit -->
- **State management** : <!-- ex: Pinia, Zustand -->
- **CSS** : <!-- ex: Tailwind, CSS Modules -->
- **Composants UI** : <!-- ex: shadcn, Radix -->

## Architecture

- **Pattern** : <!-- ex: DDD, Clean Architecture, MVC -->

## Conventions de nommage

| Contexte | Convention |
|----------|-----------|
| Fichiers | `kebab-case` |
| Code (variables, fonctions, proprietes) | <!-- ex: snake_case, camelCase --> |
| Identifiants (IDs) | <!-- ex: UUID v7, CUID, auto-increment --> |

## Notifications

- **Canal** : <!-- ex: #dev-reviews, aucun -->
- **MCP** : <!-- ex: slack, aucun -->
