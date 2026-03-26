---
name: setup-init
description: Generer ou completer le CLAUDE.md d'un projet avec le contexte minimal necessaire. Utiliser pour initialiser un nouveau projet avec Claude Code.
argument-hint: [rien — detecte automatiquement le projet]
---

Genere ou complete le CLAUDE.md du projet avec le contexte minimal necessaire pour orienter Claude des le debut. Le detail technique vit dans les skills, pas ici.

## Etape 0 — Verifications

1. Verifie qu'on est a la racine d'un projet (`.git/`, `package.json`, ou autre marqueur)
2. Si `CLAUDE.md` existe deja, lis-le pour ne pas ecraser ce qui est en place

## Etape 1 — Analyse du projet

Detecte le strict minimum :

- **Nom du projet**
- **Description courte** (une phrase)
- **Stack principale** (ex: NestJS + PostgreSQL, Nuxt 3 + Supabase)
- **Regles critiques** s'il y en a d'evidentes (monorepo, strict mode, etc.)

## Etape 2 — Recap et confirmation

Affiche le CLAUDE.md propose. Demande confirmation avant d'ecrire.

- Si le fichier existait → montre uniquement ce qui sera ajoute

## Etape 3 — Ecriture

Ecris le CLAUDE.md. Affiche :

```
CLAUDE.md — [cree | mis a jour]
```

---

## Input utilisateur

$ARGUMENTS
