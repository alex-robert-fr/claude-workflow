# claude-workflow

Plugin Claude Code pour le workflow AI-Driven Development (`name: claude-workflow` dans `.claude-plugin/plugin.json` — les skills sont namespaces `/claude-workflow:pipe-code`).

Le detail fonctionnel — raison d'etre, pipeline commente, specs, voie rapide, installation, inventaire des skills — vit dans `README.md`. Le lire avant de modifier le comportement d'un skill : il est la source unique, ce fichier n'en est pas une copie.

## Pipeline

<!-- pipeline:debut -->
```
/pipe-spec (cadrage de la feature + validation humaine)
→ /pipe-plan (Q/R + plan) → /pipe-test (tests d'abord + review humaine)
→ session neuve : /pipe-code (guide par les tests, changesets au fil de l'eau)
→ session neuve : /pipe-review (format/lint/tests outilles + agent + review humaine + fraicheur de la spec)
→ /pipe-commit (decoupage en changesets) → /pipe-pr (vers la branche d'integration)
```
<!-- pipeline:fin -->

`/pipe-ship <ticket>` est la commande de reprise : elle lit le pilotage, detecte la phase et deroule jusqu'a la prochaine pause humaine. Release : `/pipe-release` → [merge + deploiement] → `/pipe-tag`.

Deux documents, deux durees de vie — ne jamais les confondre. La **spec** (`docs/specs/<feature>.md`, versionnee) dit ce que la feature **est** ; le **pilotage** (`.claude/plans/plan-<ticket>.md`, gitignore) dit ce qu'on **fait** sur ce ticket, et meurt a la PR. Regle de tri : si une phrase devient fausse une fois le ticket merge, elle n'a rien a faire dans une spec.

## Regles

- Les fichiers de `skills/` sont **partages** — distribues via le plugin. `.claude/` porte l'outillage local du repo (create-skill, scripts de check) et n'est jamais distribue
- Les templates projet-specifiques sont dans `skills/setup/`, deployes par `/setup`. `workflow-config` est la source unique de config projet (plateforme, commandes, stack)
- **Un script est un fichier, jamais un bloc de code dans un markdown** : les scripts sans variable projet vivent dans `skills/setup/scripts/*.sh` et sont **copies** par `/setup`. Seuls les templates reellement variables (commandes de lint, format, test) restent dans les markdown — le pourquoi est dans `README.md`
- La qualite est garantie par les **hooks** et les **sub-agents**, jamais par des instructions au LLM. Les garde-fous outilles : `.claude/scripts/check-skills.sh` (budget et coherence des skills), `skills/setup/scripts/check-specs.sh` (coherence des specs, lance par `/pipe-review`)
- Ne jamais mettre de logique specifique a un projet dans les skills partages
- Chaque skill est un repertoire `nom/SKILL.md` avec frontmatter obligatoire
- References entre skills du plugin : `${CLAUDE_SKILL_DIR}/../autre-skill/`. **Toujours un chemin qualifie**, jamais un nom de fichier nu : `Read` exige un chemin absolu, et un nom nu n'est resolvable que depuis le cwd de ce repo — pas depuis un plugin installe
- Toute ligne ajoutee ici est payee dans **chaque** session : ce fichier reste un aide-memoire operationnel, pas de la documentation

## Renvois

- Ecrire ou modifier un skill : `.claude/skills/create-skill/` (conventions de nommage, frontmatter, seuils de delegation)
- Commits, branches, Pull Requests : `skills/git-conventions/SKILL.md` — a respecter systematiquement
- Publier une version : `/pipe-release` puis `/pipe-tag`. La version de `plugin.json` est la **cle de cache des mises a jour** : sans bump, aucun utilisateur ne recoit quoi que ce soit et `/plugin update` repond « already at the latest version ». Panne totale et silencieuse, qu'aucun test ne rattrape — lancer `.claude/scripts/bump-version.sh X.Y.Z`, jamais editer a la main. Meme exigence pour la cible d'installation de `marketplace.json` (`repo`, `homepage`, `repository`) : divergente du remote, elle fait installer un autre depot que celui publie
