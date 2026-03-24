Commence par lire ce fichier :

1. `.claude/skills/shared.md`

---

## Étape 1 — Identifier et récupérer l'issue

L'argument peut prendre plusieurs formes. Adapte-toi :

- `42` → numéro d'issue, utilise le repo détecté via `git remote origin`
- `https://github.com/org/repo/issues/42` → extrais org, repo, numéro
- `titre partiel` ou texte libre → recherche dans les issues ouvertes du repo courant, prends la correspondance la plus proche, confirme avec l'utilisateur si ambigu

Récupère l'issue complète via le MCP GitHub (titre, body, labels, commentaires si présents).

## Étape 2 — Explorer le codebase

Avant de planifier, explore la structure du projet pour ancrer le plan dans la réalité du code existant. Utilise les outils de lecture (Read, Glob, Grep) pour :

- Identifier les fichiers et modules concernés par l'issue
- Comprendre les patterns déjà en place (conventions, architecture, abstractions existantes)
- Repérer les dépendances et les zones impactées

## Étape 3 — Analyser l'issue

À partir de l'issue et de l'exploration du code, comprends précisément :

- **Nature** : bug, feature, refactor, chore ?
- **Périmètre** : quelles couches sont impactées ? (domaine, infra, API, UI, config...)
- **Dépendances** : est-ce que ça nécessite qu'une autre issue soit faite avant ?
- **Risques** : y a-t-il des effets de bord potentiels ? Des zones sensibles à ne pas toucher ?
- **Critères d'acceptance** : qu'est-ce qui définit "c'est terminé" ?

## Étape 4 — Produire le plan technique

Structure le plan ainsi :

```
## 📋 Plan — [Titre de l'issue] (#XX)

### Vue d'ensemble
Résumé en 2-3 phrases de ce qu'on va faire et pourquoi.

### Approche technique
Explique le raisonnement : quel pattern, quelle architecture, pourquoi ce choix.
Signale les alternatives écartées si c'est pertinent.

### Étapes d'implémentation

#### 1. [Nom de l'étape]
**Fichiers concernés :**
- `chemin/vers/fichier.ts` — ce qu'on y fait précisément (créer / modifier / supprimer)
- `chemin/vers/autre.ts` — idem

**Ce qu'on implémente :**
Description précise des changements : signature des fonctions, structure des classes, logique métier, etc. Pas de pseudo-code vague — si c'est utile, donne un exemple concret.

#### 2. [Nom de l'étape]
...

### Tests
Quoi tester, où, et comment. Unitaires / intégration / e2e selon ce qui est pertinent.

### Points d'attention
- Effets de bord potentiels
- Ce qu'il ne faut surtout pas casser
- Contraintes techniques connues
```

### Règles de précision

- Les chemins de fichiers doivent correspondre à la structure réelle du projet (vérifiés lors de l'étape 2)
- Si un fichier n'existe pas encore, indique-le clairement : `(à créer)`
- Pas d'étape floue. Si tu ne sais pas comment implémenter quelque chose, dis-le explicitement plutôt que de rester vague
- Ordre des étapes = ordre logique d'implémentation (les dépendances d'abord)

## Étape 5 — Confirmer et proposer /code

Demande à l'utilisateur de valider le plan. Une fois confirmé, propose de lancer `/code` pour implémenter.

```
---
✅ Plan prêt. Ce plan te convient ? Tu veux que je lance `/code` pour implémenter ça ?
```

---

## Input utilisateur

$ARGUMENTS
