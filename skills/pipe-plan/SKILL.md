---
name: pipe-plan
description: Planifier l'implementation d'une issue ou d'un ticket. Detecte la plateforme git (GitHub, GitLab, Gitea) et supporte les trackers externes (JIRA, Linear). Analyse le code, classifie le ticket (technique/metier/mixte), decompose si necessaire, et produit un plan technique detaille. Utiliser avant /pipe-code.
model: opus
argument-hint: [numero issue, URL, cle JIRA ou texte]
---

## Contexte

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/../_workflow-persona/SKILL.md` avant de commencer.

---

## Etape 0 — Detecter l'environnement

### Plateforme git

Recupere l'URL du remote origin (`git remote get-url origin`) et deduis la plateforme :

| Domaine | Plateforme | MCP |
|---------|-----------|-----|
| `github.com` | GitHub | `mcp__github__` |
| `gitlab.com` ou `gitlab.*` | GitLab | `mcp__gitlab__` |
| Autre | Gitea | `mcp__gitea__` |

Si `.claude/skills/workflow-config/SKILL.md` existe, sa configuration a priorite sur la detection automatique.

### Tracker externe (optionnel)

Si l'argument ressemble a une cle de projet externe ou si le workflow-config mentionne un tracker, utilise le MCP correspondant :

| Pattern | Tracker | MCP |
|---------|---------|-----|
| `ABC-123` (lettres majuscules-chiffres) | JIRA | `mcp__atlassian__` |
| URL `*.atlassian.net/*` | JIRA | `mcp__atlassian__` |
| URL `linear.app/*` | Linear | MCP Linear si disponible |

Si aucun tracker externe n'est detecte, le ticket vient de la plateforme git.

### Verifications

Avant de continuer, verifie :

- [ ] Le repo a un remote `origin` configure
- [ ] L'argument permet d'identifier un ticket (numero, URL, cle ou texte)
- [ ] Le MCP necessaire est disponible (sinon, signale-le et propose des alternatives)

Si une verification echoue, signale-le clairement et arrete-toi.

## Etape 1 — Recuperer le ticket

L'argument peut prendre plusieurs formes :

- `42` ou `#42` → issue sur la plateforme git detectee, via le MCP correspondant
- `https://github.com/org/repo/issues/42` → extrais plateforme, org, repo, numero depuis l'URL
- `https://gitlab.com/org/repo/-/issues/42` → idem pour GitLab
- `https://org.atlassian.net/browse/PROJ-42` → ticket JIRA via MCP Atlassian
- `PROJ-42` → cle JIRA, utilise le MCP Atlassian
- Texte libre → recherche dans les issues ouvertes du repo, confirme avec l'utilisateur si ambigu

Recupere le ticket complet (titre, body, labels/tags, commentaires pertinents).

## Etape 2 — Classifier le ticket

Utilise Read pour charger `reference.md` — il contient les criteres de classification et le template de plan.

Determine la nature du ticket selon les criteres de `reference.md` :

- **Technique** : dette, refactoring, perf, infra, CI/CD, migration, tooling
- **Metier** : fonctionnalite utilisateur, user story, besoin business, UX/UI
- **Mixte** : besoin metier qui implique des changements techniques significatifs

Annonce la classification a l'utilisateur — elle oriente le plan.

## Etape 3 — Evaluer la taille et decomposer si necessaire

Evalue si le ticket est implementable en une seule session `/pipe-code`. Consulte les criteres de decomposition dans `reference.md`.

**Si le ticket est trop large :**

1. Propose un decoupage en sous-tickets (voir guide dans `reference.md`)
2. Demande confirmation a l'utilisateur
3. Cree les sous-tickets sur la plateforme detectee via le MCP correspondant
4. Continue en planifiant le premier sous-ticket

**Si le ticket est de taille raisonnable**, passe directement a la suite.

## Etape 4 — Explorer le codebase

Explore la structure du projet avec Read, Glob, Grep pour :

- Identifier les fichiers et modules concernes
- Comprendre les patterns en place (conventions, architecture, abstractions)
- Reperer les dependances et les zones impactees

## Etape 5 — Produire le plan technique

Structure le plan selon le template dans `reference.md`. Le plan doit etre **actionnable par `/pipe-code`** : chemins reels, signatures concretes, logique explicite.

### Concision

Un plan est une **feuille de route**, pas du code. `/pipe-code` ecrira le code — le plan lui dit quoi faire et pourquoi.

- **Budget : 80-120 lignes** pour un ticket simple, jusqu'a 150 pour un ticket decompose
- **Pas de blocs de code** dans le plan. Les signatures de fonctions, noms de types et descriptions textuelles suffisent. Exemple : "Creer `DaylogAnalyticsService` avec methodes `getMonthTotals(month: string)`, `listByPeriod(period, month)`, `getTodayLog()`" — pas besoin d'ecrire la classe
- **Terminer par un tableau recapitulatif** des fichiers (chemin | action | description courte) — scannable en 5 secondes

### Decomposition

Quand le ticket est decompose en sous-tickets (etape 3) :
- **Plan detaille uniquement pour le 1er sous-ticket** (celui qu'on implemente next)
- **Resume en 2-3 lignes pour chaque sous-ticket suivant** : description + fichiers principaux + classification
- Les sous-tickets suivants seront planifies a leur tour via `/pipe-plan`

### Niveau de detail selon la classification

- **Metier** → insiste sur le comportement attendu cote utilisateur
- **Technique** → insiste sur les contraintes d'implementation et risques de regression
- **Mixte** → couvre les deux aspects

## Etape 6 — Persister le plan

Ecris le plan dans `.claude/plans/plan-<identifiant>.md` :
- Issue git : `plan-42.md`
- Ticket JIRA : `plan-PROJ-42.md`
- Texte libre : `plan-<slug>.md`

Cree le repertoire `.claude/plans/` si necessaire.

## Etape 7 — Confirmer et proposer la suite

```
---
Classification : [technique | metier | mixte]
Plan ecrit dans `.claude/plans/plan-XX.md`.
Ce plan te convient ? Tu veux que je lance `/pipe-code` pour implementer ?
```

---

## Input utilisateur

$ARGUMENTS
