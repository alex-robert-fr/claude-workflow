# Entrée de CHANGELOG — types, mapping, rédaction

Chargé par `/pipe-changelog` (collecte) et `/pipe-pr` (bloc `## Changelog` du body). Standard : [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/) + [SemVer 2.0.0](https://semver.org/spec/v2.0.0.html).

## Types, dans cet ordre imposé

| Type | Usage |
|---|---|
| `Added` | Nouvelle fonctionnalité |
| `Changed` | Modification de comportement existant |
| `Deprecated` | Fonctionnalité vouée à être supprimée |
| `Removed` | Suppression définitive |
| `Fixed` | Correction de bug |
| `Security` | Patch de sécurité |

Pas de type custom (`Improved`, `Refactored`, `Chore`) ; un type sans entrée n'apparaît pas.

## Mapping préfixe de commit → type

| Préfixe | Défaut | Exception |
|---|---|---|
| `feat` | `Added` | `Removed` si suppression explicite, `Deprecated` si dépréciation |
| `fix` | `Fixed` | `Security` si patch de sécurité |
| `perf` | `Changed` | — |
| `refactor` | exclu | `Changed` si l'API publique change |
| `docs` | exclu | `Added`/`Changed` si doc user-facing (README public, doc d'API consommée) |
| `chore` | exclu | `Changed` si config publique ou variable d'environnement requise |
| `test` | exclu | — |

Les cas spéciaux se détectent au contenu, pas au préfixe : suppression → `Removed`, dépréciation → `Deprecated`, sécurité → `Security`, breaking change → entrée préfixée `**BREAKING**` avec la migration requise. Doute entre exclure et inclure → exclure, marquer `⚠️`, laisser l'utilisateur trancher.

## Exclusions

Commits purement techniques sans impact consommateur ni déploiement (refactors internes, tests, CI/CD, bumps de dépendances, docs contributeur, config interne), merges, `fixup!`/`squash!`, typos purs, revert immédiatement suivi du recommit. Ils restent documentés par l'historique git et leurs corps.

## Rédiger pour le consommateur

Une entrée = une phrase, sur une seule ligne, qui décrit un effet observable, et se termine par ses références. Gabarit : `[Verbe actif présent] [feature publique] [effet visible]` — « Ajoute le filtre `?type=base|composed` sur `GET /recipes` pour limiter les résultats par catégorie. »

- Verbe à la voix active, au présent (`Ajoute`, `Corrige`, `Renvoie`) — pas de passif ni de forme nominale
- Feature publique nommée entre backticks (endpoint, paramètre, option, fichier de config) ; valeurs actionnables explicites (« minimum 12 caractères »)
- Jamais un message de commit verbatim ; aucun détail d'implémentation (décorateur, hook, refactor) — il vit dans le corps du commit lié
- Impact client dit explicitement quand le consommateur doit adapter son code
- Fusionner ce qui forme un même événement pour le consommateur (page de connexion + protection des routes + redirection = une entrée « authentification ») ; découper ce qui se consomme indépendamment (champ obligatoire + filtre + endpoint = trois entrées)
- Consolider en état final au sein d'une même release : ajout puis suppression → rien ; ajout puis renommage → une entrée au nom final ; modifications successives → l'état final. Jamais entre deux versions déjà taguées ; succession douteuse → demander

Heuristique : si l'entrée ne dit pas ce qui change concrètement pour moi ni si je dois adapter mon code, elle manque de contenu ; si elle explique comment c'est implémenté, elle en dit trop.

```
❌ Ajout du décorateur @Public() et désactivation du guard JWT sur les GET
✅ Expose les endpoints `GET` des ressources métier publiquement, sans authentification requise

❌ Refactor de find_by_email pour masquer l'existence des comptes
✅ Renvoie 404 au lieu de 403 lors de la consultation d'une recette privée sans autorisation, pour ne pas divulguer son existence
```

## Références en fin d'entrée

PR si elle existe (elle porte le contexte, les commits et les issues), sinon SHA court. Entrée fusionnée → plusieurs références séparées par des virgules. Toujours en lien Markdown explicite — GitHub n'auto-lie pas dans les fichiers du dépôt :

```
- Texte reformulé ([#15](https://github.com/org/repo/pull/15))
- Texte d'une entrée fusionnée ([#15](url/pull/15), [`abc1234`](url/commit/abc1234))
```
