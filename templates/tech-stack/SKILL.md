---
name: tech-stack
description: Stack technique et conventions de code du projet. Utiliser lors de l'ecriture ou la revue de code pour respecter les standards et la stack du projet.
user-invocable: false
---

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

## Git

- **Branche par defaut** : <!-- ex: main, develop -->

## Architecture

- **Pattern** : <!-- ex: DDD, Clean Architecture, MVC -->

## Conventions de nommage

| Contexte | Convention |
|----------|-----------|
| Fichiers | `kebab-case` |
| Code (variables, fonctions, proprietes) | <!-- ex: snake_case, camelCase --> |
| Identifiants (IDs) | <!-- ex: UUID v7, CUID, auto-increment --> |

## Regles de qualite

- Pas de `any` TypeScript sans justification explicite
- Pas de commentaires evidents — le code doit se lire seul
- Chaque fichier cree ou modifie doit etre dans un etat propre et committable
- Pas de `console.log` de debug oublie
- Pas d'import inutilise
