---
name: audit-skills
description: Auditer un projet selon la grille AI-Driven Development (7 axes, scoring 1-10). Evaluer skills, CLAUDE.md, hooks, conventions et workflow. Utiliser avec "audit" pour lancer une evaluation complete.
user-invocable: true
argument-hint: [audit | audit commandes | audit workflow | audit skills]
allowed-tools: Bash(ls *)
---

## Contexte

- Skills projet : !`ls .claude/skills/ 2>/dev/null || echo "Aucun skill projet"`
- Skills plugin : !`ls ${CLAUDE_SKILL_DIR}/../`
- Hooks : !`ls .claude/settings.json 2>/dev/null || echo "Pas de settings.json"`

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/../_workflow-persona/SKILL.md` avant de commencer.

---

## Etape 1 — Charger la grille

Utilise Read pour charger `audit-grille.md` pour les criteres et le format de rapport.

## Etape 2 — Explorer le projet

1. Explorer : `.claude/` (skills, settings), `CLAUDE.md`, hooks, conventions
2. Lire chaque skill et verifier la coherence
3. Identifier les fichiers de config (`workflow-config`, `tech-stack`, rules)

## Etape 3 — Evaluer

Evaluer selon la grille (7 axes, scoring 1-10) :

1. Process — Pipeline sequentiel avec gates
2. Qualite — Par defaut, pas par effort
3. Architecture — Plugin + Config projet
4. Contexte — Ressource rare
5. Permissions et autonomie
6. Skills — Qualite de conception
7. Replicabilite

## Etape 4 — Produire le rapport

Produire le rapport au format defini dans la grille. Proposer des corrections par priorite (P0/P1/P2).

---

## Input utilisateur

$ARGUMENTS
