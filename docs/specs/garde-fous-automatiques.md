# Garde-fous automatiques

> **Statut** : active
> **Tickets** : —

## En une phrase

Des hooks portés par le plugin lui-même — actifs dès qu'il est chargé, sans passer par `/setup` — qui vérifient les accents français et la qualité pédagogique des réponses de la session principale.

## Intention

[`garde-fous-outillés`](garde-fous-outilles.md) ne s'applique qu'après un `/setup` explicite, projet par projet — pertinent pour des commandes de lint ou de test qui varient d'un projet à l'autre. Deux exigences transversales n'ont, elles, rien de projet-spécifique : des accents français corrects et une pédagogie qui donne la vue d'ensemble avant le détail technique. Les faire dépendre de `/setup` les rendrait absentes sur tout projet non configuré ; les confier à une simple consigne de skill les rendrait dépendantes de la bonne volonté du modèle — exactement ce que la doctrine de ce plugin exclut.

Réussi quand un mot français sans accent, produit par ce plugin dans une réponse, une spec, un commit ou une Pull Request, ne peut jamais rester en l'état.

## Philosophie

Le premier passage doit déjà être correct ; le garde-fou rattrape ce qui lui échappe. Un rappel injecté au démarrage de la session vise le premier objectif ; les hooks ci-dessous vérifient le second, après coup.

## Comportement attendu

- Un mot français dont l'accent a été remplacé par sa lettre ASCII est refusé avant d'atteindre un fichier Markdown, un message de commit ou une Pull Request
- La même vérification s'applique à la dernière réponse de la session principale avant qu'elle ne s'arrête
- Une réponse nettement plus longue que l'information qu'elle transmet, ou qui pose une question technique sans vue haut niveau préalable, est renvoyée pour reprise
- Chaque session démarre avec un rappel court de ces deux exigences, pour que le premier jet les respecte déjà
- Une dépendance manquante (`jq`, `claude`) rend le garde-fou concerné inerte et muet, jamais bloquant

## Hors scope

- Les commentaires de code — jugés par le sub-agent de [`review-de-fin-de-cycle`](review-de-fin-de-cycle.md), pas par un hook : la question du *pourquoi* d'un commentaire n'est pas une vérification mécanique
- La liste de mots surveillée n'est pas exhaustive — elle exclut volontairement tout mot qui collisionne avec un usage anglais ou une convention déjà établie de ce dépôt (ex. `reference`, `decision`)
- Tout appel réseau autre que le jugement lui-même

## Fonctionnement technique

Trois hooks, déclarés dans `hooks/hooks.json` à la racine du plugin (`${CLAUDE_PLUGIN_ROOT}`) — aucun `/setup` requis, à la différence des garde-fous outillés.

`check-accents.sh` est le détecteur : une liste conservatrice de mots français dont la forme sans accent ne collisionne avec rien d'anglais ni d'existant dans ce dépôt. Il est appelé par deux hooks :

- `PreToolUse` (matcher `Write|Edit|Bash`) : vérifie le contenu écrit vers un fichier `*.md` (intégralité) ou `*.sh` (lignes de commentaire uniquement — jamais le code, dont les motifs volontairement flous comme `de*pre*ci`), ou une commande `git commit` / `gh pr create|edit|comment` / `gh issue create`. Bloque (`exit 2`) avant l'écriture
- `Stop` : vérifie la dernière réponse assistant du transcript. Si elle est saine côté accents et substantielle (longue, ou porteuse d'une question), un juge invoqué en `claude --safe-mode -p` (aucun hook, aucun CLAUDE.md — seulement le texte à juger) évalue verbosité et pédagogie et bloque si un défaut net est identifié

Le juge est une session `claude` complète : son propre `Stop` pourrait redéclencher ce script. `--safe-mode` désactive les hooks de cette session imbriquée ; `CLAUDE_WORKFLOW_JUDGE_ACTIVE` neutralise le script en secours si jamais il s'exécutait quand même.

`SessionStart` injecte le rappel de premier passage via `additionalContext`, comme le hook équivalent de `/setup` pour l'index des specs — mêmes contraintes (canal garanti, coût payé à chaque session, donc texte court).

## Dépendances

- **Externes** : `jq` ; le binaire `claude` lui-même pour le juge du hook `Stop`
- **Dépendants** : aucun — ce sont des garde-fous terminaux, rien dans le pipeline n'en dépend

## Décisions

| Version | Ticket | Décision | Raison | Alternative écartée |
|---------|--------|----------|--------|---------------------|
| 1.8.0 (à venir) | — | Hooks portés par le plugin, pas par `/setup` | Deux exigences sans variable projet ne doivent pas dépendre d'une installation explicite | Les ajouter aux cinq garde-fous outillés existants, déployés par `/setup` |
| 1.8.0 (à venir) | — | Le juge de verbosité/pédagogie tourne en `--safe-mode`, jamais `--bare` | `--bare` exige une clé API et ignore l'authentification OAuth de la session courante — la majorité des installations en dépendent | `--bare`, plus rapide mais incompatible avec l'authentification par défaut |
| 1.8.0 (à venir) | — | Le juge n'a aucune liste d'outils explicitement interdite | Testé : une liste `--disallowed-tools` déstabilise le mécanisme de sortie structurée du modèle et lui fait ignorer l'extrait soumis, silencieusement | `--disallowed-tools` pour une défense en profondeur supplémentaire |
| 1.8.0 (à venir) | — | La liste d'accents exclut `reference` et `decision` | Ces mots collisionnent avec un usage anglais et une convention déjà établie dans ce dépôt sans accent — les inclure aurait bloqué la quasi-totalité des écritures futures | Une liste exhaustive, corrigée au cas par cas ensuite |

## Points d'entrée

| Fichier | Rôle |
|---------|------|
| [hooks.json](../../hooks/hooks.json) | Déclare les trois hooks et leurs cibles |
| [check-accents.sh](../../hooks/scripts/check-accents.sh) | Détecteur d'accents manquants, déterministe |
| [pre-write-accents.sh](../../hooks/scripts/pre-write-accents.sh) | `PreToolUse` — bloque avant écriture |
| [stop-quality.sh](../../hooks/scripts/stop-quality.sh) | `Stop` — accents puis juge de verbosité/pédagogie |
| [session-prime.sh](../../hooks/scripts/session-prime.sh) | `SessionStart` — rappel de premier passage |

## Pièges et zones sensibles

- **Le corpus existant de ce dépôt est très largement écrit sans accents** : la liste de `check-accents.sh` a été sondée mot par mot contre ce corpus pour éviter qu'elle ne bloque en permanence — l'étendre sans ce sondage réintroduit le risque
- **Le juge de verbosité a une variance réelle** : un même extrait peut être jugé différemment d'un appel à l'autre, comme tout jugement porté par un modèle rapide — ce n'est pas un défaut à corriger, c'est la nature d'un garde-fou sémantique plutôt que mécanique
- **`--safe-mode` désactive aussi les hooks du juge lui-même** : c'est voulu, et c'est la première ligne de défense contre la récursion — ne jamais le retirer sans le remplacer
