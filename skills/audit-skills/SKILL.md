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
2. Lister tous les skills a auditer
3. Identifier les fichiers de config (`workflow-config`, `tech-stack`, rules)

## Etape 3 — Auditer par sub-agents

Pour chaque skill ou groupe de fichiers a analyser, lancer un sub-agent en parallele via l'outil Agent (`subagent_type: "Explore"`).

Chaque sub-agent recoit :
- Le chemin du skill/fichier a analyser
- Les criteres de la grille (axe 6 — Skills) a verifier
- La consigne de retourner un rapport structure : conformite frontmatter, description, structure, fichiers supports, anti-patterns detectes

Lancer les sub-agents en parallele quand les analyses sont independantes.

Les axes globaux (1-5, 7) sont evalues dans le contexte principal a partir de `CLAUDE.md`, `settings.json`, hooks et de la structure generale — pas besoin de sub-agents pour ceux-la.

## Etape 4 — Synthetiser et produire le rapport

1. Agreger les rapports des sub-agents avec l'evaluation des axes globaux
2. Scorer chaque axe (1-10) selon la grille
3. Produire le rapport final au format defini dans `audit-grille.md`
4. Proposer des corrections par priorite (P0/P1/P2)

---

## Input utilisateur

$ARGUMENTS
