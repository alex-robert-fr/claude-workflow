# Récap de fin de /setup

Affiche ce bloc, valeurs du projet substituées :

```
## Setup termine — [nom du projet]

### Configure
- ✅ CLAUDE.md
- ✅ workflow-config (lint: [cmd], test: [cmd], ...)
- ✅ hooks (SessionStart, PreToolUse, PostToolUse, Stop) — scripts copies dans .claude/hooks/
- ✅ post-tool-use.sh (format: [cmd], extensions: [regex]) + stop.sh (test: [cmd])
- ✅ check-specs.sh (cohérence des specs, lance par /pipe-review)
- ✅ .claude/plans/
- ✅ .claude/rules/
- ✅ docs/specs/ (+ index)

### Pipeline disponible
Cycle : /pipe-spec → [validation humaine de la spec] → /pipe-plan → /pipe-test → [review humaine des tests] → /pipe-code (session neuve) → /pipe-review (session neuve) → [review humaine du code] → /pipe-commit → /pipe-pr
Reprise a tout moment : /pipe-ship [ticket]
Release : /pipe-release → [merge + deploiement] → /pipe-tag

### Prochaine étape
Lance `/pipe-spec [ticket]` pour demarrer un cycle par le cadrage de la feature.
```
