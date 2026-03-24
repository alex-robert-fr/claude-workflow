Commence par lire ce fichier :

1. `.claude/skills/labels-catalog/SKILL.md`

---

## Rôle

Crée les labels GitHub manquants sur le repo courant, en se basant sur les labels standard définis dans le skill.

## Étape 1 — Détecter le repo

Récupère l'URL du remote `origin` via `git remote get-url origin` pour identifier le repo GitHub.

## Étape 2 — Vérifier les labels existants

Pour chaque label défini dans le skill `labels-catalog`, vérifie s'il existe déjà sur le repo via MCP GitHub (`get_label`).

## Étape 3 — Récapituler et confirmer

Affiche le récap :

```
📋 Labels à créer :

- `bug` (#d73a4a) — Correction de bug
- `feature` (#0075ca) — Nouvelle fonctionnalité

Labels déjà présents :
- `chore`, `docs`
```

Demande confirmation : **"Je crée ces labels sur GitHub ?"**

## Étape 4 — Créer les labels manquants

Crée chaque label manquant via MCP GitHub avec le nom, la couleur et la description définis dans le skill.

Affiche le résultat :

```
✅ Labels créés : bug, feature
ℹ️ Déjà présents : chore, docs
```

---

## Input utilisateur

$ARGUMENTS
