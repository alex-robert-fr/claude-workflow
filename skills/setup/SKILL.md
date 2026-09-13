---
name: setup
description: Configurer un projet pour le workflow AI-Driven Development : CLAUDE.md, workflow-config, hooks, scripts, plans, specs.
disable-model-invocation: true
allowed-tools:
  - Bash(git remote -v)
  - Bash(git symbolic-ref *)
  - Bash(git branch --show-current)
---

**Ne traite que ce qui manque, après confirmation de la liste.** Les scripts se copient (`cp`), ils ne se réécrivent jamais ; ce qui varie par projet passe en argument dans `settings.json`.

## Étape 0 — Diagnostic

- `CLAUDE.md` à la racine
- `.claude/skills/workflow-config/SKILL.md` rempli (aucun placeholder `<!-- -->`) ; idem pour tout autre fichier de `.claude/skills/`
- `.claude/settings.json` avec les quatre hooks (SessionStart, PreToolUse, PostToolUse, Stop — vérifiés séparément), chacun câblé vers un script existant et exécutable :

  ```bash
  jq -r '.hooks | to_entries[] | .value[].hooks[].command' .claude/settings.json 2>/dev/null \
    | awk '{print $2}' | sort -u | while read -r f; do [ -x "$f" ] && echo "ok $f" || echo "KO $f"; done
  ```

- `.claude/scripts/check-specs.sh` ; `.claude/plans/` ; `docs/specs/` avec son `README.md`

Récap `✅ / ❌ (motif)` par ligne — un hook dont le script est absent ou non exécutable compte ❌. Confirme la liste des actions avant de commencer.

## Étape 1 — CLAUDE.md

Absent → génère le minimum : nom, description en une phrase, stack détectée (package.json, Cargo.toml, go.mod…), règles critiques évidentes, et deux sections :

```markdown
## Git

Conventions du plugin claude-workflow : branches `type/identifiant-titre-court`, commits `emoji type(scope): description` en français avec corps en puces, aucune signature automatique — appliquées par `/pipe-commit` et `/pipe-pr`.

## Specs

Chaque feature a une spec dans `docs/specs/` : intention, comportement attendu, hors-scope, décisions et points d'entrée. **Avant de modifier une feature, lire sa spec** (index : `docs/specs/README.md`). Écrites et maintenues par `/pipe-spec`.
```

Présent → vérifie ces deux sections, propose d'ajouter celle qui manque.

## Étape 2 — workflow-config

Absent → Read `${CLAUDE_SKILL_DIR}/workflow-config-template.md` comme squelette. Placeholders → pose les questions, valeur détectée proposée :

1. Plateforme git (`git remote -v`)
2. Issue tracker (MCP configurés) ; si Jira ou Linear : statut à appliquer aux tickets à la release
3. Branche par défaut (`git symbolic-ref refs/remotes/origin/HEAD`) et branche de production si distincte
4. Commandes lint, format, test, build (scripts de package.json ou équivalent)
5. Notification (canal, aucun)

Stack, architecture et nommage se remplissent depuis ce qui est détecté. Confirme, écris. Un `.claude/skills/tech-stack/SKILL.md` (legacy) → propose de le fusionner puis de le supprimer. Ne touche jamais un champ déjà rempli.

## Étape 3 — Hooks et scripts

Read `${CLAUDE_SKILL_DIR}/hooks-reference.md`.

```bash
mkdir -p .claude/hooks .claude/scripts
cp "${CLAUDE_SKILL_DIR}/scripts/session-start.sh" "${CLAUDE_SKILL_DIR}/scripts/pre-tool-use.sh" \
   "${CLAUDE_SKILL_DIR}/scripts/post-tool-use.sh" "${CLAUDE_SKILL_DIR}/scripts/stop.sh" .claude/hooks/
cp "${CLAUDE_SKILL_DIR}/scripts/check-specs.sh" .claude/scripts/
chmod +x .claude/hooks/*.sh .claude/scripts/*.sh
cp "${CLAUDE_SKILL_DIR}/settings-template.json" .claude/settings.json
```

- Fichier déjà présent : identique → rien ; différent → demande avant d'écraser
- `settings.json` existant → merge les hooks du template sans toucher permissions ni MCP
- Placeholders, depuis workflow-config : `<EXTENSIONS>` (liste `ts|tsx|js`, sans point ni antislash — tableau « Valeurs par stack » de hooks-reference), `<COMMANDE_FORMAT>` (sans chemin de fichier), `<COMMANDE_TEST>`
- Après écriture : aucun `<...>` ne subsiste, rejoue le contrôle d'existence de l'étape 0. `jq` absent → le signaler, installer quand même
- Affiche la config générée et demande confirmation avant d'écrire

## Étape 4 — Répertoires

`.claude/plans/` (ajouté à `.gitignore`), `.claude/rules/`, `docs/specs/` (versionné, jamais ignoré) avec un `README.md` vide créé selon `${CLAUDE_SKILL_DIR}/../pipe-spec/index-format.md` (Read) — aucune spec n'est écrite depuis `/setup`. Projet avec des features livrées → `Pour les documenter en partant des plus rentables : /pipe-spec sans argument (inventaire priorisé, une feature par passe).`

## Étape 5 — Récap

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

---

## Input utilisateur

$ARGUMENTS
