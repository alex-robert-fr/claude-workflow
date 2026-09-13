---
name: audit-conformity
description: Auditer la conformité du code à un document de référence (spec, règle, skill, CLAUDE.md) et planifier la remédiation.
disable-model-invocation: true
argument-hint: [document de référence] [périmètre optionnel]
---

**Le document est la loi, le code est le prévenu : ce skill ne modifie aucune ligne.** Il produit un rapport de conformité, un plan de remédiation en lots, et propose leur mise en place dans le pipeline.

## Étape 0 — Document et périmètre

- Un document de référence lisible ; sans argument ou ambigu → inventorie les candidats (`docs/specs/*.md`, `CLAUDE.md`, `.claude/skills/*/SKILL.md`, `skills/*/SKILL.md`) et demande lequel. Un seul document par audit
- Second argument = périmètre (`src/auth/`, `**/*.tsx`) ; sinon le projet entier
- Read `.claude/skills/workflow-config/SKILL.md` s'il existe (stack et conventions cadrent le périmètre)

## Étape 1 — Grille de règles (pause)

Read `${CLAUDE_SKILL_DIR}/reference.md`, section « Extraction de la grille ». Lis le document en entier, convertis-le en règles atomiques `R1..Rn` (énoncé impératif, portée, citation source), liste à part les intentions non vérifiables. Affiche la grille et attends validation : l'utilisateur corrige les règles mal lues, retire celles qui ne s'appliquent plus, ajoute l'implicite.

## Étape 2 — Zones

Fichiers du périmètre (Glob) hors dépendances, artefacts de build, fichiers générés, lockfiles, `.git`. Découpe par répertoire ou module, jamais par règle : < 30 fichiers → 2 zones ; 30–150 → 3 à 4 ; > 150 → 5 à 6, au-delà élargis les zones plutôt que leur nombre. Annonce : `Périmètre — N fichiers · G zones · R règles`.

## Étape 3 — Audit (fan-out)

Un agent `claude-workflow:auditor` par zone, tous lancés dans un seul message, chacun avec le document, la grille entière et sa zone seule.

## Étape 4 — Réfutation

Regroupe les constats par règle ; un agent `claude-workflow:refuter` par lot, en parallèle, avec les violations du lot, la grille et le document. Les constats réfutés restent dans le rapport, avec leur motif.

## Étape 5 — Angles morts

Un seul agent `claude-workflow:gap-finder` avec la grille, la carte des zones et les rapports agrégés. Trous remontés → une salve ciblée d'auditeurs, une seule : au-delà, c'est la grille qu'il faut revoir.

## Étape 6 — Rapport

Écris `.claude/audits/audit-<slug>.md` (répertoire créé, dans `.gitignore`) au format de `${CLAUDE_SKILL_DIR}/reference.md`, section « Format du rapport ». À l'écran : le tableau des règles avec leur verdict et le décompte des violations confirmées par sévérité, rien de plus. Conformité totale → une ligne, rapport écrit, stop.

## Étape 7 — Arbitrage (pause)

Par violation confirmée, sévérité décroissante, une décision explicite : corriger le code (→ plan de remédiation), amender le document (la règle est fausse, obsolète ou trop large), ou accepter l'écart avec sa raison, consignée dans le rapport. Rien n'est corrigé ici, même trivial.

## Étape 8 — Plan de remédiation

Lots selon `${CLAUDE_SKILL_DIR}/reference.md`, section « Plan de remédiation » : par règle (correction mécanique répétée) ou par zone (compréhension du module), ≤ 15 fichiers, ordonnés par sévérité puis dépendance. Route : mécanique sans comportement → `/pipe-commit` (voie rapide) ; comportement à valider → `/pipe-spec` puis le cycle ; chantier à suivre → `/create-issue`.

```
Plan — N lots · [x] voie rapide, [y] cycle, [z] issues.
Je mets en place le lot 1 ([route]) ?
```

Un lot à la fois, chacun avec son propre cycle.

---

## Input utilisateur

$ARGUMENTS
