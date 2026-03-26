---
name: prepare-plan
description: Planifier l'implementation d'une issue GitHub. Analyse le code, produit un plan technique detaille avec etapes, fichiers et approche. Utiliser avant /code.
argument-hint: [numero issue, URL ou texte]
---

Utilise Read pour charger `.claude/skills/_workflow-persona/SKILL.md` avant de commencer.

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

Utilise Read pour charger `reference.md` — il contient le template de plan et les regles de precision.

Structure le plan selon le template : vue d'ensemble, approche technique, etapes d'implementation (avec fichiers reels), tests, points d'attention.

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
