---
name: prepare-plan
description: Planifier l'implementation d'une issue GitHub. Analyse le code, produit un plan technique detaille avec etapes, fichiers et approche. Utiliser avant /code.
argument-hint: [numero issue, URL ou texte]
---

Lis `.claude/skills/_workflow-persona/SKILL.md` avant de commencer.

---

## Etape 0 — Verifications

Avant de commencer, verifie :

- [ ] Le repo a un remote `origin` configure (necessaire pour recuperer l'issue)
- [ ] L'argument fourni permet d'identifier une issue (numero, URL ou texte)

Si une verification echoue, signale-le clairement et arrete-toi.

## Etape 1 — Identifier et recuperer l'issue

L'argument peut prendre plusieurs formes. Adapte-toi :

- `42` → numero d'issue, utilise le repo detecte via `git remote origin`
- `https://github.com/org/repo/issues/42` → extrais org, repo, numero
- `titre partiel` ou texte libre → recherche dans les issues ouvertes du repo courant, prends la correspondance la plus proche, confirme avec l'utilisateur si ambigu

Recupere l'issue complete via le MCP GitHub (titre, body, labels, commentaires si presents).

## Etape 2 — Explorer le codebase

Avant de planifier, explore la structure du projet pour ancrer le plan dans la realite du code existant. Utilise les outils de lecture (Read, Glob, Grep) pour :

- Identifier les fichiers et modules concernes par l'issue
- Comprendre les patterns deja en place (conventions, architecture, abstractions existantes)
- Reperer les dependances et les zones impactees

## Etape 3 — Analyser l'issue

A partir de l'issue et de l'exploration du code, comprends precisement :

- **Nature** : bug, feature, refactor, chore ?
- **Perimetre** : quelles couches sont impactees ? (domaine, infra, API, UI, config...)
- **Dependances** : est-ce que ca necessite qu'une autre issue soit faite avant ?
- **Risques** : y a-t-il des effets de bord potentiels ? Des zones sensibles a ne pas toucher ?
- **Criteres d'acceptance** : qu'est-ce qui definit "c'est termine" ?

## Etape 4 — Produire le plan technique

Structure le plan ainsi :

```
## Plan — [Titre de l'issue] (#XX)

### Vue d'ensemble
Resume en 2-3 phrases de ce qu'on va faire et pourquoi.

### Approche technique
Explique le raisonnement : quel pattern, quelle architecture, pourquoi ce choix.
Signale les alternatives ecartees si c'est pertinent.

### Etapes d'implementation

#### 1. [Nom de l'etape]
**Fichiers concernes :**
- `chemin/vers/fichier.ts` — ce qu'on y fait precisement (creer / modifier / supprimer)
- `chemin/vers/autre.ts` — idem

**Ce qu'on implemente :**
Description precise des changements : signature des fonctions, structure des classes, logique metier, etc. Pas de pseudo-code vague — si c'est utile, donne un exemple concret.

#### 2. [Nom de l'etape]
...

### Tests
Quoi tester, ou, et comment. Unitaires / integration / e2e selon ce qui est pertinent.

### Points d'attention
- Effets de bord potentiels
- Ce qu'il ne faut surtout pas casser
- Contraintes techniques connues
```

### Regles de precision

- Les chemins de fichiers doivent correspondre a la structure reelle du projet (verifies lors de l'etape 2)
- Si un fichier n'existe pas encore, indique-le clairement : `(a creer)`
- Pas d'etape floue. Si tu ne sais pas comment implementer quelque chose, dis-le explicitement plutot que de rester vague
- Ordre des etapes = ordre logique d'implementation (les dependances d'abord)

## Etape 5 — Persister le plan dans un fichier

Ecris le plan dans `.claude/plans/plan-<numero-issue>.md` (ou `plan-<slug>.md` si pas de numero d'issue).

Cree le repertoire `.claude/plans/` s'il n'existe pas.

Le fichier de plan permet de :
- Reprendre le travail dans une session fraiche sans perdre le contexte
- Lancer `/code` depuis un terminal different avec un contexte propre

## Etape 6 — Confirmer et proposer /code

Demande a l'utilisateur de valider le plan. Une fois confirme, propose de lancer `/code` pour implementer.

```
---
Plan ecrit dans `.claude/plans/plan-XX.md`.
Ce plan te convient ? Tu veux que je lance `/code` pour implementer ca ?
```

---

## Input utilisateur

$ARGUMENTS
