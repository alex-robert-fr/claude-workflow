# Hooks Reference — Templates pour /setup

Ce fichier documente les hooks et checks outilles a installer dans un projet.
Ce sont des garde-fous deterministes — ils ne ratent jamais, la ou une instruction au LLM peut être ignoree.

## Deux catégories, deux traitements

| Catégorie | Contenu | Comment `/setup` l'installe |
|-----------|---------|------------------------------|
| **Scripts universels** | Aucune variable projet | **Copies tels quels** depuis `${CLAUDE_SKILL_DIR}/scripts/` — jamais recopies a la main |
| **Valeurs par stack** | Liste d'extensions, commandes de format et de test | Injectees comme **arguments** des scripts dans `settings.json`, depuis `workflow-config` |

Un script universel n'a **qu'une** version correcte : le recopier depuis un markdown, c'est confier a un LLM un travail que `cp` fait sans erreur d'echappement. Ne jamais reecrire ces fichiers a la main — les corriger dans le plugin. Ce qui varie d'un projet a l'autre ne vit donc pas dans le corps d'un script, mais dans ses arguments.

## Principe — les 5 scripts a copier

| Hook / check | Rôle | Quand | Script (plugin → projet) | Arguments |
|--------------|------|-------|--------------------------|-----------|
| SessionStart | Injecter l'index des specs dans le contexte | Au demarrage de chaque session | `scripts/session-start.sh` → `.claude/hooks/` | aucun |
| PreToolUse | Bloquer les commandes dangereuses | Avant chaque appel d'outil | `scripts/pre-tool-use.sh` → `.claude/hooks/` | aucun |
| PostToolUse | Auto-lint/format apres ecriture | Apres Write ou Edit | `scripts/post-tool-use.sh` → `.claude/hooks/` | liste d'extensions + commande de format |
| Stop | Vérifier que les tests passent | Quand Claude pense avoir fini | `scripts/stop.sh` → `.claude/hooks/` | commande de test |
| check-specs | Cohérence des specs | Appele par `/pipe-review` | `scripts/check-specs.sh` → `.claude/scripts/` | aucun |

`cp` puis `chmod +x`. Les sections ci-dessous expliquent ce que chacun fait et pourquoi — elles ne contiennent pas leur code.

## Check outille — cohérence des specs

Ce n'est **pas un hook** : c'est un script appele par `/pipe-review` dans ses checks outilles (étape 1), au meme titre que le format, le lint et les tests. Il est ici parce que `/setup` le deploie comme les hooks.

Il couvre quatre ecarts qu'un agent detecte mal :

- une spec qui pointe vers des fichiers disparus
- une spec absente de l'index, donc jamais injectee par le hook SessionStart, donc morte
- une ligne d'index pointant vers une spec disparue, seul mode de panne qui produise de la **fausse** information plutot que de l'absence
- une phrase d'index depassant 80 caracteres

Points de mecanique, tous vérifiés par test — a connaitre avant de modifier le script :

- **Ne lire que la colonne 1 du tableau.** La colonne Rôle cite souvent d'autres chemins (`.gitignore`, `.claude/plans/`) qui ne sont pas des points d'entrée — les extraire produirait des faux positifs a chaque spec
- **Ignorer les lignes `(a créer)`**, accents compris. Une spec est ecrite avant le dev : sans cette tolerance, tout cadrage en amont echouerait le check
- **Distinguer quelques chemins morts de tous les chemins morts.** Le second cas signifie que la feature a disparu : le message invite a deprecier plutot qu'a rafistoler. C'est un diagnostic, pas une action — la depreciation reste humaine
- **Sauter les specs au statut `depreciee`** pour le controle des chemins : leurs fichiers ont disparu par construction, les signaler a chaque review serait du bruit permanent. Elles restent en revanche controlees cote index
- **Valider l'index dans les deux sens.** Partir des fichiers ne voit pas la ligne d'index orpheline — et celle-la continue d'être injectee dans chaque session en decrivant une feature qui n'existe plus
- **Plafonner la phrase d'index a 80 caracteres.** L'index est le seul poste de contexte qui grossit a chaque `/pipe-spec` reussi : sans borne outillee, il derive vers ~1300 tokens par session a vingt specs
- **Comparer les noms de fichiers en entier.** Un match en sous-chaine ferait passer `csv.md` pour indexe des qu'une ligne cite `export-csv.md`
- Projet sans `docs/specs/` → exit 0 silencieux
- Exit 1 des qu'un ecart est trouve : `/pipe-review` le remonte comme les autres checks, sans bloquer le cycle

## SessionStart — Index des specs

Les specs de `docs/specs/` n'ont de valeur que si elles sont **lues**. Une instruction dans le CLAUDE.md repose sur la bonne volonte du LLM ; ce hook rend l'index present dans le contexte des le demarrage, sans exception.

**Pas de matcher** — l'événement n'en prend pas. **Pas d'argument.**

Points de mecanique — a connaitre avant de modifier le script :

- L'injection passe par `hookSpecificOutput.additionalContext`, avec `hookEventName` **obligatoire** — un `echo` de texte brut n'est pas garanti d'atteindre le contexte
- `jq -Rs` echappe le markdown de l'index : ne jamais construire ce JSON a la main
- **L'injection s'arrete a la section « Specs depreciees »** : une feature retiree ne doit pas être proposee comme contexte de reference. Le titre de cette section est donc un contrat entre l'index et ce script
- `suppressOutput: true` evite d'afficher l'index dans le transcript a chaque demarrage
- Projet sans `docs/specs/README.md` → sortie vide et exit 0 : le hook est inerte, pas en erreur
- Cout : l'index seul (une ligne par feature), pas les specs. Compter ~200 tokens pour une dizaine de features — c'est ce qui evite l'exploration a l'aveugle

## PreToolUse — Blocage des commandes dangereuses

Bloque les commandes Bash qui pourraient causer des degats irreversibles.

**Matcher** : `Bash`. **Pas d'argument.**

La liste des patterns bloques vit dans le script (`rm -rf`, `git push --force` sur une branche protégée, `DROP TABLE`, `git reset --hard`...). Pour l'etendre sur un projet, editer le fichier deploye ; pour l'etendre partout, le corriger dans le plugin.

Exit 2 bloque l'action, et c'est **stderr** qui est alors transmis a Claude — un motif ecrit sur stdout donne un blocage sans explication.

## PostToolUse — Auto-lint/format

Formate automatiquement les fichiers apres chaque ecriture. Le lint est deterministe — ca ne doit JAMAIS être fait par le LLM.

**Matcher** : `Write|Edit`.

**Arguments** : `post-tool-use.sh '<EXTENSIONS>' '<COMMANDE_FORMAT>'`. Le script lit le JSON du hook sur stdin, en extrait le chemin ecrit, et n'applique la commande que si l'extension figure dans la liste. Le chemin du fichier est ajoute par le script : la commande s'ecrit sans lui.

`<EXTENSIONS>` est une liste séparée par `|`, **sans point ni antislash** (`ts|tsx|js`). C'est le script qui construit la regex. Transporter une regex du type `\.(ts|tsx)$` dans une chaine JSON serait un echappement invalide : `settings.json` deviendrait illisible et les quatre hooks mourraient d'un coup, en silence.

## Stop — Verification des tests

Verifie que les tests passent avant de laisser Claude terminer.

**Pas de matcher.**

**Arguments** : `stop.sh <COMMANDE_TEST>` — la commande complète, telle quelle.

Points de mecanique — a connaitre avant de modifier le script :

- **Seul `exit 2` bloque l'arret**, et c'est **stderr** qui est alors transmis a Claude. Un `exit 1` est une erreur non bloquante : Claude s'arrete quand meme, sans diagnostic. Propager le code de retour brut de la commande de test rendrait donc le hook inerte — un `npm test` rouge sort en 1
- Sur `exit 0`, stdout ne va qu'au journal de debug : Claude ne le voit pas
- **`stop_hook_active` protege de la boucle infinie.** Si Claude a déjà ete relance par ce hook, le script sort en 0 et le laisse s'arreter. Sans ce garde-fou, des tests durablement rouges bloqueraient la session indefiniment
- Aucune commande passee en argument → exit 0 : un projet sans commande de test n'est jamais bloque

## Valeurs par stack

Ces valeurs alimentent les arguments des deux scripts ci-dessus dans `settings.json`. La commande de format et celle de test viennent de `workflow-config` quand elles y sont déjà renseignees ; ce tableau sert de defaut par stack.

| Stack | Extensions | Commande format/lint | Commande test |
|-------|------------|----------------------|---------------|
| Biome (TypeScript/JavaScript) | `ts\|tsx\|js\|jsx\|json\|css` | `npx biome check --write` | `npx vitest run` |
| ESLint + Prettier | `ts\|tsx\|js\|jsx` | `npx eslint --fix` puis `npx prettier --write` | `npm run test` |
| Ruff (Python) | `py` | `ruff check --fix` puis `ruff format` | `pytest` |
| rustfmt (Rust) | `rs` | `rustfmt` | `cargo test` |
| gofmt (Go) | `go` | `gofmt -w` | `go test ./...` |

- Dans ce tableau, `\|` est un `|` echappe pour le markdown : ecrire `|` dans `settings.json`
- Pas de point, pas d'antislash, pas de `$` : la regex est construite par le script (voir PostToolUse ci-dessus)
- Deux commandes de format pour une meme stack (ESLint **puis** Prettier, `ruff check` **puis** `ruff format`) → deux entrées dans le tableau `hooks` du meme matcher PostToolUse, pas une commande composee

## Structure settings.json complète

Template : `${CLAUDE_SKILL_DIR}/settings-template.json` — les 4 hooks cables vers les scripts copies, avec les placeholders `<EXTENSIONS>`, `<COMMANDE_FORMAT>` et `<COMMANDE_TEST>`. `/setup` le copie puis remplace les placeholders ; il ne génère pas ce JSON de tete.

## Notes

- Les hooks sont executes par le harness Claude Code, pas par le LLM — leur exécution est gratuite en tokens (un hook qui injecte du contexte, comme SessionStart, coute en revanche ce qu'il injecte)
- Les hooks PostToolUse ne bloquent pas — ils s'executent silencieusement
- Toujours `|| true` sur les commandes de lint pour ne pas bloquer l'ecriture si le linter crash
- Les scripts doivent être dans `.claude/hooks/` et rendus executables (`chmod +x`)
- Un hook cable vers un script absent ou non executable ne fait **rien** : le PostToolUse meurt en silence, et le formatage automatique avec lui. C'est pourquoi `/setup` verifie l'existence de chaque cible au diagnostic comme apres ecriture
