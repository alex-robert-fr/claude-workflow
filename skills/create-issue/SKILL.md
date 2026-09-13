---
name: create-issue
description: Creer des issues GitHub structurees depuis une demande : decoupage, critères d'acceptance, labels.
argument-hint: [description de ce qu'il faut faire]
---

**En cas de doute, découper : une issue trop petite coûte moins qu'une issue fourre-tout.** Rien n'est créé sans confirmation.

## Étape 0 — Vérifications

Remote `origin` configuré et description fournie ; sinon une ligne, stop. Le repo actif est celui du remote (MCP GitHub) : toutes les issues y vont.

## Étape 1 — Une ou plusieurs issues

Séparer si : domaines fonctionnels distincts (auth + dashboard + API = 3 issues si indépendantes) ; bug et feature mélangés ; couches techniques livrables séparément (backend + frontend non couplés) ; charge > 2 jours sur un sujet ; dépendances claires (A avant B). Une seule si : bug isolé à cause et correction claires ; petite feature qui tient en une PR ; éléments trop couplés pour être livrés séparément.

## Étape 2 — Rédaction

Titre `[Type] Description concise` en français — types `[Bug]`, `[Feature]`, `[Refactor]`, `[Chore]`, `[Docs]`, `[Perf]`. Corps :

```markdown
## Contexte
Pourquoi cette issue existe, ce qui a déclenché le besoin. `Depend de #X` si dépendance.

## Description
Ce qu'il faut faire, précisément.

## Critères d'acceptance
- [ ] Critère

## Notes techniques (si pertinent)
Contraintes, pièges connus, suggestions d'approche.
```

Un mécanisme qui bifurque réellement (plusieurs cas d'erreur parallèles) se décrit en diagramme Mermaid plutôt qu'en paragraphe — critères dans `${CLAUDE_SKILL_DIR}/../pipe-spec/template.md`, section Fonctionnement technique.

## Étape 3 — Confirmer puis créer

Récap de toutes les issues, puis « Je crée ces N issues sur GitHub ? ». Confirmé → création via MCP GitHub dans l'ordre des dépendances, label = type en minuscules (`bug`, `feature`, `refactor`, `chore`, `docs`, `perf`), créé s'il manque sur le repo ; affiche chaque URL.

---

## Input utilisateur

$ARGUMENTS
