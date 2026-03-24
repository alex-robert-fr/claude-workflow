---
name: claude-audit
description: Audite un projet pour evaluer la qualite des process AI-Driven Development, commandes, skills et workflow Claude Code.
user-invocable: true
---

Commence par lire ces fichiers dans l'ordre :

1. `.claude/skills/shared.md`
2. `.claude/skills/audit.md`

# Commande /audit

Audite en profondeur les process de developpement AI-Driven d'un projet et produit un rapport actionnable.

## Modes

### Si aucun argument — Mode audit complet

Realise un audit exhaustif de tous les axes definis dans le skill.

### Si un argument — Mode question/focus

Repond a une question precise ou audite un axe specifique.
Exemples d'arguments : `commandes`, `workflow`, `claude.md`, `hooks`, `sync`, ou une question libre.

---

## Etape 1 — Exploration du projet

Explorer systematiquement :

1. **Configuration Claude Code :**
   - `.claude/` (commands, skills, agents, settings)
   - `CLAUDE.md` a la racine du projet
   - `CLAUDE.md` global de l'utilisateur (`~/.claude/CLAUDE.md`)
   - `.claude/settings.json` et `.claude/settings.local.json`
   - Hooks configures

2. **Commandes et skills :**
   - Lire chaque fichier dans `.claude/commands/`
   - Lire chaque fichier dans `.claude/skills/`
   - Verifier la coherence commande <-> skill

3. **Conventions et qualite :**
   - Conventions de commits, branches, PRs
   - Configuration lint/format
   - Hooks pre-commit
   - `.editorconfig`, `biome.json`, `eslint.config.*`

4. **Workflow et integration :**
   - Structure du projet (monorepo? packages?)
   - Scripts dans `package.json`
   - CI/CD (`.github/workflows/`, `.gitlab-ci.yml`)
   - Integration MCP configurees
   - Memoire Claude Code (`.claude/memory/` ou `.claude/projects/*/memory/`)

5. **Git et historique :**
   - Conventions de commits recents (`git log --oneline -20`)
   - Branches existantes
   - Etat du repo (fichiers non commites, etc.)

## Etape 2 — Analyse

Pour chaque axe du skill audit.md :
- Evaluer ce qui existe vs les bonnes pratiques
- Identifier les ecarts concrets avec des exemples du projet
- Scorer chaque axe individuellement

Etre specifique : citer les fichiers, les lignes, les commandes concernees. Pas de generalites.

## Etape 3 — Rapport

Produire le rapport selon le format defini dans le skill audit.md.

Le rapport doit etre :
- **Specifique** : chaque constat cite un fichier ou une pratique concrete du projet
- **Actionnable** : chaque probleme a une solution avec des etapes
- **Hierarchise** : les problemes critiques d'abord
- **Honnete** : pas de compliments gratuits, pas non plus de critique gratuite

## Etape 4 — Discussion

Apres le rapport :
- Demander si l'utilisateur a des questions
- Proposer de corriger les problemes identifies (par priorite)
- Rester disponible pour approfondir un axe specifique

---

## Input utilisateur

$ARGUMENTS
