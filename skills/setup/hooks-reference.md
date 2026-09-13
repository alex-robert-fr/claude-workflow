# Hooks et checks outillés — référence pour /setup

Garde-fous déterministes installés dans le projet par `/setup`. Un script universel n'a qu'une version correcte : il se **copie** depuis `${CLAUDE_SKILL_DIR}/scripts/`, jamais réécrit à la main — ce qui varie par projet passe en argument dans `settings.json`. Les hooks sans variable projet (accents, conventions git, verrou des tests) vivent dans `hooks/hooks.json` du plugin et n'ont pas besoin de `/setup`.

## Les 5 scripts à copier

| Hook / check | Rôle | Script (plugin → projet) | Arguments |
|--------------|------|--------------------------|-----------|
| SessionStart | Injecte l'index des specs dans le contexte | `scripts/session-start.sh` → `.claude/hooks/` | aucun |
| PreToolUse (`Bash`) | Bloque les commandes aux dégâts irréversibles | `scripts/pre-tool-use.sh` → `.claude/hooks/` | aucun |
| PostToolUse (`Write\|Edit`) | Formate le fichier écrit | `scripts/post-tool-use.sh` → `.claude/hooks/` | `'<EXTENSIONS>' '<COMMANDE_FORMAT>'` |
| Stop | Tests avant de considérer la tâche finie | `scripts/stop.sh` → `.claude/hooks/` | `<COMMANDE_TEST>` |
| check-specs | Cohérence des specs, lancé par `/pipe-review` (pas un hook) | `scripts/check-specs.sh` → `.claude/scripts/` | aucun |

`cp` puis `chmod +x`. Un hook câblé vers un script absent ou non exécutable ne fait rien, en silence : `/setup` vérifie l'existence de chaque cible au diagnostic et après écriture. `session-start.sh` et `check-specs.sh` requièrent `jq`. Template complet : `${CLAUDE_SKILL_DIR}/settings-template.json`.

## Mécanique à connaître avant de modifier un script

- **Codes de sortie** : seul `exit 2` bloque (PreToolUse, Stop), et c'est **stderr** qui est transmis à Claude — un motif sur stdout donne un blocage muet. `exit 1` est une erreur non bloquante ; sur `exit 0`, stdout ne va qu'au journal
- **SessionStart** : injection par `hookSpecificOutput.additionalContext` avec `hookEventName` obligatoire, JSON construit par `jq -Rs` ; s'arrête à la section « Specs depreciees » de l'index (titre contractuel) ; `suppressOutput: true` ; pas de `docs/specs/README.md` → inerte. Coût : l'index seul, ~200 tokens pour dix features
- **PreToolUse** : liste des motifs dans le script (`rm -rf`, `git push --force` sur branche protégée, `DROP TABLE`, `git reset --hard`…) — à étendre dans le fichier déployé pour un projet, dans le plugin pour tous
- **PostToolUse** : lit le JSON sur stdin, extrait le chemin, n'applique la commande que si l'extension figure dans la liste ; le chemin est ajouté par le script. `<EXTENSIONS>` = liste séparée par `|`, **sans point ni antislash** (`ts|tsx|js`) : une regex transportée dans le JSON casserait `settings.json` et tuerait les quatre hooks d'un coup. Deux commandes de format (ESLint puis Prettier) → deux entrées dans le même matcher, pas une commande composée. Toujours `|| true` sur le lint
- **Stop** : propage `exit 2` quand la commande de test échoue (un `npm test` rouge sort en 1, qui serait inerte) ; `stop_hook_active` protège de la boucle infinie ; aucune commande en argument → `exit 0`
- **check-specs** : ne lit que la première colonne du tableau des points d'entrée ; ignore les lignes `(a créer)` ; distingue quelques chemins morts (retard) de tous les chemins morts (feature retirée → déprécier, décision humaine) ; saute les specs dépréciées côté chemins ; valide l'index dans les deux sens ; plafonne la phrase d'index à 80 caractères et une spec active à 80 lignes ; compare les noms de fichiers en entier ; sans `docs/specs/` → `exit 0` ; `exit 1` dès qu'un écart est trouvé, remonté par `/pipe-review` sans bloquer le cycle

## Valeurs par stack

Commandes de format et de test : celles de `workflow-config` si renseignées, sinon ce défaut.

| Stack | Extensions | Commande format/lint | Commande test |
|-------|------------|----------------------|---------------|
| Biome (TypeScript/JavaScript) | `ts\|tsx\|js\|jsx\|json\|css` | `npx biome check --write` | `npx vitest run` |
| ESLint + Prettier | `ts\|tsx\|js\|jsx` | `npx eslint --fix` puis `npx prettier --write` | `npm run test` |
| Ruff (Python) | `py` | `ruff check --fix` puis `ruff format` | `pytest` |
| rustfmt (Rust) | `rs` | `rustfmt` | `cargo test` |
| gofmt (Go) | `go` | `gofmt -w` | `go test ./...` |

Dans ce tableau `\|` est un `|` échappé pour le markdown : écrire `|` dans `settings.json`.
