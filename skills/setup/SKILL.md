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

`bash "${CLAUDE_SKILL_DIR}/../../shared/scripts/setup-diagnose.sh"` — une ligne `ok` / `KO (motif)` par élément : CLAUDE.md, workflow-config sans placeholder, les quatre hooks de `.claude/settings.json` chacun câblé vers un script exécutable, check-specs.sh, `.claude/plans/`, `docs/specs/` et son index. Vérifie aussi l'absence de placeholder dans tout autre fichier de `.claude/skills/`.

Affiche le diagnostic tel quel, puis la liste des actions ; confirme-la avant de commencer.

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

`bash "${CLAUDE_SKILL_DIR}/../../shared/scripts/setup-install.sh"` — copie les quatre hooks, check-specs.sh et le template de settings, sans écraser : `différent` → demande, puis relance avec `--force` si confirmé.

- `settings.json` existant → merge les hooks du template sans toucher permissions ni MCP
- Placeholders, depuis workflow-config : `<EXTENSIONS>` (liste `ts|tsx|js`, sans point ni antislash — tableau « Valeurs par stack » de hooks-reference), `<COMMANDE_FORMAT>` (sans chemin de fichier), `<COMMANDE_TEST>`
- Après écriture : aucun `<...>` ne subsiste, rejoue le contrôle d'existence de l'étape 0. `jq` absent → le signaler, installer quand même
- Affiche la config générée et demande confirmation avant d'écrire

## Étape 4 — Répertoires

`.claude/plans/` (ajouté à `.gitignore`), `.claude/rules/`, `docs/specs/` (versionné, jamais ignoré) avec un `README.md` vide créé selon `${CLAUDE_SKILL_DIR}/../pipe-spec/index-format.md` (Read) — aucune spec n'est écrite depuis `/setup`. Projet avec des features livrées → `Pour les documenter en partant des plus rentables : /pipe-spec sans argument (inventaire priorisé, une feature par passe).`

## Étape 5 — Récap

Read `${CLAUDE_SKILL_DIR}/recap.md` et affiche-le avec les valeurs du projet.

---

## Input utilisateur

$ARGUMENTS
