Commence par lire ce fichier :

1. `.claude/skills/shared.md`

---

## Étape 1 — Détecter le repo courant

Utilise le MCP GitHub pour identifier le repo actif à partir du remote Git (`origin`). Toutes les issues seront créées dans ce repo.

## Étape 2 — Analyser la demande

Lis attentivement ce que l'utilisateur décrit. Évalue si c'est **une seule issue ou plusieurs**.

### Règles de découpage

Crée **plusieurs issues séparées** si la demande contient :

- Des **domaines fonctionnels distincts** (ex : auth + dashboard + API = 3 domaines → 3 issues si les tâches sont indépendantes)
- Un **mix de natures différentes** : un bug ET une feature dans la même description → toujours séparer
- Des **couches techniques indépendantes** qui peuvent être développées et mergées séparément (ex : backend + frontend si non couplés)
- Une **charge estimée > 2 jours** sur un seul sujet → découper en sous-tâches cohérentes
- Des **dépendances claires** entre sous-tâches (A doit être fait avant B) → issues séparées avec mention de la dépendance dans la description

Garde **une seule issue** si :

- C'est un bug isolé avec cause et correction claires
- C'est une petite feature qui tient en un seul PR cohérent
- Les éléments décrits sont fortement couplés et ne peuvent pas être livrés séparément

### En cas de doute

Préfère **découper** : une issue trop petite est moins grave qu'une issue fourre-tout.

## Étape 3 — Rédiger les issues

Pour **chaque issue** identifiée, rédige :

**Titre** : court, précis, en français. Format : `[Type] Description concise`

- Types : `[Bug]`, `[Feature]`, `[Refactor]`, `[Chore]`, `[Docs]`, `[Perf]`

**Body** en markdown structuré :

```
## Contexte
Pourquoi cette issue existe. Ce qui a déclenché le besoin.

## Description
Ce qu'il faut faire, précisément. Pas de vague.

## Critères d'acceptance
- [ ] Critère 1
- [ ] Critère 2
- [ ] ...

## Notes techniques (si pertinent)
Contraintes, pièges connus, suggestions d'approche.
```

## Étape 4 — Récapituler avant de créer

Avant de créer quoi que ce soit sur GitHub, **affiche le récap** :

```
📋 Issues à créer (N) :

1. [Bug] Titre de l'issue 1
   → Résumé en une phrase

2. [Feature] Titre de l'issue 2
   → Résumé en une phrase
```

Puis demande confirmation : **"Je crée ces N issues sur GitHub ?"**

## Étape 5 — Créer les issues via MCP GitHub

Commence par lire `.claude/skills/github-labels.md` pour connaître les labels disponibles.

Une fois confirmation reçue, crée chaque issue via le MCP GitHub dans l'ordre logique (dépendances d'abord).

Pour chaque issue :

- Assigne le **label** correspondant au type de l'issue, en suivant la correspondance définie dans le skill. Si le label n'existe pas encore sur le repo, crée-le.
- Si l'issue **dépend d'une autre**, ajoute `Dépend de #X` dans la section Contexte du body.
- Affiche l'URL retournée.

---

## Input utilisateur

$ARGUMENTS
