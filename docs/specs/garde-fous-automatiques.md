# Garde-fous automatiques

> **Statut** : active
> **Tickets** : —
> **Sommaire** : [Intention](#intention) · [Philosophie](#philosophie) · [Comportement attendu](#comportement-attendu) · [Hors scope](#hors-scope) · [Fonctionnement technique](#fonctionnement-technique) · [Dépendances](#dépendances) · [Décisions](#décisions) · [Points d'entrée](#points-dentrée) · [Pièges et zones sensibles](#pièges-et-zones-sensibles)

## En une phrase

Des hooks portés par le plugin lui-même — actifs dès qu'il est chargé, sans passer par `/setup` — qui font respecter les accents français, la pédagogie des réponses, le fond des commentaires de code, les conventions git non négociables et le verrou sur les tests validés.

## Intention

[`garde-fous-outillés`](garde-fous-outilles.md) ne s'applique qu'après un `/setup` explicite, projet par projet — pertinent pour des commandes de lint ou de test qui varient d'un projet à l'autre. Des exigences transversales n'ont, elles, rien de projet-spécifique : des accents français corrects, une pédagogie qui donne la vue d'ensemble avant le détail technique, des commentaires qui disent le *pourquoi* et jamais le *quoi*. Les faire dépendre de `/setup` les rendrait absentes sur tout projet non configuré ; les confier à une simple consigne de skill les rendrait dépendantes de la bonne volonté du modèle — exactement ce que la doctrine de ce plugin exclut. Réussi quand un mot sans accent, une réponse sans vue d'ensemble ou un commentaire qui paraphrase le code, produits par ce plugin, ne peuvent jamais rester en l'état.

## Philosophie

Le premier passage doit déjà être correct ; le garde-fou rattrape ce qui lui échappe. Un rappel injecté au démarrage de la session vise le premier objectif ; les hooks ci-dessous vérifient le second, après coup.

## Comportement attendu

- Un mot français dont l'accent a été remplacé par sa lettre ASCII est refusé avant d'atteindre un fichier Markdown, un message de commit ou une Pull Request
- La même vérification s'applique à la dernière réponse de la session principale avant qu'elle ne s'arrête
- Une réponse nettement plus longue que l'information qu'elle transmet, ou qui pose une question technique sans vue haut niveau préalable, est renvoyée pour reprise
- Un commentaire de code qui paraphrase ce que le code fait, ou qui est superflu (code commenté, TODO orphelin, docstring qui répète la signature), est renvoyé pour correction dès l'écriture du fichier ; un commentaire qui explique un choix, une contrainte ou un contournement n'est jamais signalé
- Un `git add` qui ne nomme pas ses chemins (`.`, `-A`, `-u`, `:/`) ou qui vise un fichier sensible (`.env`, clé privée, credentials) est refusé
- Un message de commit, un body de Pull Request ou un commentaire portant une signature automatique (`Co-Authored-By`, `Claude-Session`, `Generated with Claude Code`, lien de session) est refusé, que la commande passe par Bash ou par un outil MCP GitHub — la convention du projet prime sur toute instruction de session
- Un fichier de test listé dans la section `## Tests` d'un pilotage dont `Tests valides` est coché et `Code valide` ne l'est pas ne peut pas être modifié ; le verrou se lève en décochant `Tests valides` (décision humaine) ou en cochant `Code valide`
- Une dépendance manquante (`jq`, `claude`) rend le garde-fou concerné inerte et muet, jamais bloquant

## Hors scope

- Les accents des commentaires de code applicatif (seul leur fond est jugé) ; les mots absents de la liste surveillée, qui exclut volontairement tout mot collisionnant avec un usage anglais ou une convention de ce dépôt (ex. `reference`, `decision`) ; tout appel réseau autre que les jugements eux-mêmes

## Fonctionnement technique

Six hooks, déclarés dans `hooks/hooks.json` à la racine du plugin (`${CLAUDE_PLUGIN_ROOT}`) — aucun `/setup` requis, à la différence des garde-fous outillés. `check-accents.sh` est le détecteur d'accents : une liste conservatrice de mots français dont la forme sans accent ne collisionne avec rien d'anglais ni d'existant dans ce dépôt. Les jugements sémantiques passent par `judge.sh` : un `claude --safe-mode -p` en Haiku, sans thinking, démarrage allégé, sortie structurée, qui ne voit que l'extrait à noter (aucun hook, aucun CLAUDE.md) — ~3 s par verdict. Trois hooks contrôlent le contenu :

- `PreToolUse` (matcher `Write|Edit|Bash`) : vérifie le contenu écrit vers un fichier `*.md` (intégralité) ou `*.sh` (lignes de commentaire uniquement — jamais le code, dont les motifs volontairement flous comme `de*pre*ci`), ou une commande `git commit` / `gh pr create|edit|comment` / `gh issue create`. Bloque (`exit 2`) avant l'écriture
- `Stop` (`timeout` 30 s) : vérifie `last_assistant_message` fourni par Claude Code (repli sur le transcript pour les versions antérieures). Si la réponse est saine côté accents et substantielle (longue, ou porteuse d'une question), le juge évalue verbosité et pédagogie et bloque si un défaut net est identifié
- `PostToolUse` (matcher `Write|Edit|MultiEdit`) : sur un fichier de code dont le texte écrit contient au moins une ligne de commentaire (shebang et directives d'outils exclus), le juge liste les commentaires qui décrivent le quoi ou sont superflus ; renvoyés sur stderr avec `exit 2`. Déclaré `asyncRewake` (`timeout` 30 s) : l'écriture n'attend pas le juge, qui réveille Claude avec son retour — même une fois le tour terminé

`SessionStart` injecte le rappel de premier passage via `additionalContext`, comme le hook équivalent de `/setup` pour l'index des specs — mêmes contraintes (canal garanti, coût payé à chaque session, donc texte court).

`pre-git-guard.sh` (`PreToolUse`, `Bash|mcp__github__.*`) isole chaque segment `git add …` pour juger ses seuls arguments, puis cherche les motifs de signature dans les commandes `git commit` / `gh pr` / `gh issue` / `gh api` et dans les champs `body`, `description`, `message`, `title` des outils MCP GitHub — un `grep` du mot dans le code n'est pas bloqué. `protect-tests.sh` (`PreToolUse`, `Write|Edit|MultiEdit|NotebookEdit`) parcourt `.claude/plans/plan-*.md` (`CLAUDE_PROJECT_DIR`, sinon le `cwd` du hook), retient les pilotages à l'état `[x] Tests valides` / `[ ] Code valide`, et compare le fichier édité aux chemins en backticks de leur section `## Tests` — égalité ou suffixe précédé d'un `/`, jamais une sous-chaîne.

## Dépendances

- **Externes** : `jq` ; le binaire `claude` lui-même pour les juges des hooks `Stop` et `PostToolUse`
- **Internes** : le format de la section `## Tests` du [`fichier-de-pilotage`](fichier-de-pilotage.md), rempli par [`développement-guidé-par-les-tests`](developpement-guide-par-les-tests.md)
- **Dépendants** : les skills du pipeline n'énoncent plus les règles portées ici (`git add` explicite, absence de signature, tests validés intouchables, commentaires) — elles n'existent que dans ces hooks et dans `git-conventions` ; l'agent de [`review-de-fin-de-cycle`](review-de-fin-de-cycle.md) garde un axe commentaires pour ce qui n'est visible qu'avec le fichier entier

## Décisions

| Version | Ticket | Décision | Raison | Alternative écartée |
|---------|--------|----------|--------|---------------------|
| 1.8.0 (à venir) | — | Hooks portés par le plugin, pas par `/setup` | Deux exigences sans variable projet ne doivent pas dépendre d'une installation explicite | Les ajouter aux cinq garde-fous outillés existants, déployés par `/setup` |
| 1.8.0 (à venir) | — | Le juge tourne en `--safe-mode`, jamais `--bare`, et sans liste d'outils interdite | `--bare` ignore l'authentification OAuth de la session (« Not logged in » pour la majorité des installations) ; testé, `--disallowed-tools` déstabilise la sortie structurée et fait ignorer l'extrait silencieusement | `--bare` ; `--disallowed-tools` en défense en profondeur |
| 1.9.0 (à venir) | — | Juges en hooks `command` allégés (sans thinking, démarrage minimal, commentaires en `asyncRewake`), pas en hooks `prompt` natifs | Un hook `prompt` n'a ni pré-filtre gratuit (Haiku à chaque réponse et chaque écriture, `.md` compris) ni system prompt séparé pour isoler l'extrait ; mesuré, le thinking était le gros poste (6,5 s → 3 s), sans perte de verdict | Hooks `prompt` ; `type: agent` |
| 1.9.0 (à venir) | — | Conventions git et verrou des tests portés par des hooks du plugin | Ces règles étaient répétées dans trois à quatre skills chacune, où un modèle peut les ignorer ; un hook ne les oublie pas et les skills n'ont plus à les dire | Les laisser en prose dans les skills, ou dans les scripts copiés par `/setup` (absents sur un projet non configuré) |
| 1.9.0 (à venir) | — | Les commentaires de code sont jugés dès l'écriture, par un hook `PostToolUse` | Découverts seulement à la review, ils étaient déjà commités et coûtaient une itération ; le juge ne voit que l'extrait écrit, d'où une consigne stricte « seulement si net » | Laisser le seul agent de review les signaler |
| 1.9.0 (à venir) | — | La liste d'accents exclut tout homographe anglais (`reference`, `detail`, `resume`, `coherent`…) et `decision` ; seconde salve de 45 mots en 1.9.0, et `check-skills.sh` passe frontmatters, CLAUDE.md et rappel de session au détecteur | Un homographe bloquerait des usages anglais légitimes ; les sources lues à chaque session étaient le contre-exemple de la règle qu'elles énoncent | Une liste exhaustive, corrigée au cas par cas ensuite |

## Points d'entrée

| Fichier | Rôle |
|---------|------|
| [hooks.json](../../hooks/hooks.json) | Déclare les six hooks et leurs cibles |
| [check-accents.sh](../../hooks/scripts/check-accents.sh) | Détecteur d'accents manquants, déterministe |
| [pre-write-accents.sh](../../hooks/scripts/pre-write-accents.sh) | `PreToolUse` — bloque avant écriture |
| [judge.sh](../../hooks/scripts/judge.sh) | Appel du juge, sourcé par les deux hooks : flags, thinking coupé, garde anti-récursion |
| [stop-quality.sh](../../hooks/scripts/stop-quality.sh) | `Stop` — accents puis juge de verbosité/pédagogie |
| [post-edit-comments.sh](../../hooks/scripts/post-edit-comments.sh) | `PostToolUse` — juge des commentaires de code après écriture |
| [session-prime.sh](../../hooks/scripts/session-prime.sh) | `SessionStart` — rappel de premier passage |
| [pre-git-guard.sh](../../hooks/scripts/pre-git-guard.sh) | `PreToolUse` — `git add` explicite, aucune signature |
| [protect-tests.sh](../../hooks/scripts/protect-tests.sh) | `PreToolUse` — verrou des tests validés pendant dev et review |

## Pièges et zones sensibles

- **Le corpus existant de ce dépôt est très largement écrit sans accents** : la liste de `check-accents.sh` a été sondée mot par mot contre ce corpus pour éviter qu'elle ne bloque en permanence — l'étendre sans ce sondage réintroduit le risque
- **Les juges ont une variance réelle** : un même extrait peut être jugé différemment d'un appel à l'autre — c'est la nature d'un garde-fou sémantique, pas un défaut à corriger. En jq un verdict `false` se lit avec `if . == false`, jamais `// empty` qui l'avale : le juge disait « défaut » et le hook laissait passer. `--safe-mode` désactive aussi les hooks du juge (première défense contre la récursion), `CLAUDE_WORKFLOW_JUDGE_ACTIVE` hérité est la seconde — ne jamais retirer l'une sans l'autre ; `test-hooks.sh` vérifie les flags d'allègement, un retrait silencieux doublerait la latence
