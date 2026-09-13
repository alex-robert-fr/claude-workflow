---
name: pipe-review
description: Reviewer le code en session dediee : checks outilles, agent, review humaine, fraicheur de la spec. Apres /pipe-code.
disable-model-invocation: true
argument-hint: [cle du ticket ou rien si un seul cycle en cours]
allowed-tools:
  - Bash(bash "${CLAUDE_SKILL_DIR}/../../shared/scripts/find-plan.sh" *)
  - Bash(bash .claude/scripts/check-specs.sh)
  - Bash(git status *)
  - Bash(git diff *)
  - Bash(git log *)
---

**La qualité mécanique vient des outils, le jugement d'un agent isolé puis de l'humain** : ce skill ne corrige rien sans validation explicite.

## Étape 0 — Vérifications

- Read `.claude/skills/workflow-config/SKILL.md`
- Pilotage : `bash "${CLAUDE_SKILL_DIR}/../../shared/scripts/find-plan.sh" [identifiant]` — exit 3 : demander lequel. Avec pilotage : `Dev termine` coché, `git switch` sur sa branche, lis plan et notes de reprise. Sans pilotage (usage autonome) : la branche courante n'est pas la branche par défaut
- Aucun changement (ni commits d'avance, ni working tree modifié) → une ligne, stop

## Étape 1 — Checks outillés

Dans l'ordre, avec les commandes de workflow-config : format (appliqué), lint, tests, puis `bash .claude/scripts/check-specs.sh` s'il existe. Commande non configurée → une ligne, on continue.

- Lint ou tests rouges → corrige, 3 tentatives au plus ; le problème semble venir d'un test → stop et signale, c'est une décision humaine. Après 3 échecs → stop avec le détail
- Un écart de `check-specs.sh` n'est pas bloquant : il se traite à l'étape 6
- Récap une ligne : `Format : ✅ | Lint : ✅ | Tests : ✅ N passent | Specs : ✅`

## Étape 2 — Contexte

Le strict nécessaire — il porte encore les étapes 5 et 6, puis `/pipe-commit` et `/pipe-pr` dans la même session : `git diff <branche par défaut>` + fichiers non trackés (`git status`), liste des fichiers modifiés et créés, ticket (pilotage ou nom de branche). Aucune lecture de fichier ici : l'agent les lit lui-même, une étape qui en a besoin lit ponctuellement.

## Étape 3 — Agent `reviewer`

Lance l'agent (Agent tool, `subagent_type: "claude-workflow:reviewer"`) avec : branche et branche par défaut, liste des fichiers modifiés, chemin du `CLAUDE.md` du projet et de `.claude/_review-persona.md` (ou « absent »), et le diff complet.

## Étape 4 — Rapport

- Statut OK → une ligne, rien de plus : `**Review [branche]** — rien à signaler : pas de bug détecté, organisation du projet respectée.`
- Des constats → Read `${CLAUDE_SKILL_DIR}/rendu.md` et affiche le rapport à son format

## Étape 5 — Review humaine du code (pause)

Affiche de quoi démarrer, rien d'autre — résumé depuis le diff, lecture ponctuelle du seul fichier qui ne s'y résume pas :

```
### À relire

- `chemin/fichier.ts` — [ce que le fichier apporte, une ligne]
```

Puis, par sévérité décroissante, un problème à la fois au format Q/R de `rendu.md` : corriger (relis le fichier avant d'appliquer), adapter (demande la modification puis applique), ignorer. Les retours de l'utilisateur sur sa propre relecture se traitent de même. Après toute correction : tests et lint. Des bloquants ignorés → `⚠️ X bloquant(s) ignoré(s) — risque de bug ou de régression.`

Code validé par l'utilisateur → étape 6.

## Étape 6 — Fraîcheur des specs

Specs concernées, quatre sources croisées : un point d'entrée dans le diff ; un point d'entrée qui partage un répertoire avec un fichier du diff (rattrape les fichiers neufs) ; la spec du pilotage ; les écarts de `check-specs.sh`. Aucune (`sans objet`, ou pas de `docs/specs/`) → étape 7 sans rien signaler.

Read `${CLAUDE_SKILL_DIR}/../pipe-spec/fraicheur.md` et applique-le à chaque spec concernée :

- Fichier structurant du diff hors de toute spec alors qu'il appartient à une feature spécifiée → l'ajouter aux points d'entrée
- Feature retirée (tous les points d'entrée disparus, fichiers structurants supprimés) → dépréciation, après validation explicite : les fichiers ont peut-être seulement déménagé
- Écarts présentés puis corrigés après validation, au format `### Spec — docs/specs/<feature>.md` / `- [section] <écart> → <correction>` ; une décision structurante prise pendant le dev rejoint le journal avec le ticket ; aucun écart → une ligne
- La spec modifiée fait partie du changeset : `/pipe-commit` la rattache à la feature

Coche `Code valide` dans le pilotage.

## Étape 7 — Suite

```
Code validé. Suite : `/pipe-commit [ticket]` (même session).
```

---

## Input utilisateur

$ARGUMENTS
