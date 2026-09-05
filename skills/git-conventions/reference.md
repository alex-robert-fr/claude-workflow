# Git Conventions — Exemples et templates

## Exemples de branches

| Issue | Branche |
|-------|---------|
| #42 `[Feature] Ajout authentification OAuth` | `feat/42-add-oauth-authentication` |
| #17 `[Bug] Crash au login avec email +` | `fix/17-login-crash-email-plus` |
| #8 `[Docs] Documentation API publique` | `docs/8-public-api-documentation` |

## Exemples de commits

```
🐛 fix(billing): correction du calcul de TVA sur les abonnements annuels
```

```
🔧 chore: mise a jour des dependances npm
```

```
♻️ refactor(user): extraction du service de validation email
```

```
✨ feat(auth): ajout login OAuth Google

- integre le flow Authorization Code avec PKCE
- gere le refresh token via cookie HttpOnly
```

## Template PR — Body

**Important** : `Closes #XX` est obligatoire, pas optionnel. Toujours present avec le bon numero d'issue. Si plusieurs issues sont liees : `Closes #12, Closes #15`.

La PR est la porte d'entree, pas la doc technique : le detail (pourquoi, approche, alternatives) vit dans le body des commits. Pas de liste de fichiers ni de liste de commits (la plateforme les affiche deja dans ses onglets), pas de section tests (la CI le dit deja), pas de points de review (ils recopieraient les commits).

Le bloc `## Changelog` est ecrit au format du CHANGELOG du projet, pret a y etre agrege a la release : memes types, memes regles de redaction (voir `pipe-changelog/reference.md`, sections « Types d'entrees », « Regles de contenu », « Rediger pour le consommateur »). Chaque entree se termine par ses references en liens Markdown explicites vers les commits (SHA court). Il decrit l'**etat final** de la branche : un commit ajoute en iteration reecrit l'entree concernee, il n'en ajoute pas une nouvelle. Les commits sans impact consommateur n'y figurent pas — ils restent visibles dans l'onglet Commits.

```markdown
## Contexte

Lien vers l'issue et resume en 1-2 phrases de pourquoi ce changement est necessaire.

Closes #XX

## Ce qui a ete fait

L'approche en prose, courte : le comment et les arbitrages, pas la liste des fichiers ni des commits.

## Changelog

### Added
- Effet observable pour le consommateur, une phrase ([`abc1234`](url/commit/abc1234), [`def5678`](url/commit/def5678))

### Fixed
- Effet observable pour le consommateur, une phrase ([`9a8b7c6`](url/commit/9a8b7c6))

## A verifier a la main

Uniquement ce que ni les tests ni la CI ne couvrent (rendu navigateur, media query, parcours reel). Section omise s'il n'y a rien.
```

## Template PR — Commentaire d'iteration

Utilise uniquement lors de la mise a jour d'une PR existante. Liste tous les commits depuis la derniere mise a jour.

```markdown
## Mise a jour — [date]

### Nouveaux commits

- `emoji type(scope): description du commit 1`
- `emoji type(scope): description du commit 2`

### Changements ajoutes

- `chemin/fichier` — ce qui a change

### Impact

Resume en une phrase de l'ensemble de cette iteration.
```

S'il n'y a qu'un seul commit, le format reste identique — une seule entree dans la liste.
