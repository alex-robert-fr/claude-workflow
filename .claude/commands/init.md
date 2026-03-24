# Commande /init

Génère ou complète le CLAUDE.md du projet avec le contexte minimal nécessaire pour orienter Claude dès le début. Le détail technique vit dans les skills, pas ici.

## Étape 0 — Vérifications

1. Vérifie qu'on est à la racine d'un projet (`.git/`, `package.json`, ou autre marqueur)
2. Si `CLAUDE.md` existe déjà, lis-le pour ne pas écraser ce qui est en place

## Étape 1 — Analyse du projet

Détecte le strict minimum :

- **Nom du projet**
- **Description courte** (une phrase)
- **Stack principale** (ex: NestJS + PostgreSQL, Nuxt 3 + Supabase)
- **Règles critiques** s'il y en a d'évidentes (monorepo, strict mode, etc.)

## Étape 2 — Récap et confirmation

Affiche le CLAUDE.md proposé. Demande confirmation avant d'écrire.

- Si le fichier existait → montre uniquement ce qui sera ajouté

## Étape 3 — Écriture

Écris le CLAUDE.md. Affiche :

```
✅ CLAUDE.md — [créé | mis à jour]
```

---

## Input utilisateur

$ARGUMENTS
