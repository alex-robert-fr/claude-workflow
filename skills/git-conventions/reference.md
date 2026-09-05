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

La PR est la porte d'entree, pas la doc technique : le detail (pourquoi, approche, alternatives) vit dans le body des commits. Pas de liste de fichiers (GitHub l'affiche deja), pas de section tests (la CI le dit deja), pas de points de review (ils recopieraient les commits).

```markdown
## Contexte

Lien vers l'issue et resume en 1-2 phrases de pourquoi ce changement est necessaire.

Closes #XX

## Ce qui a ete fait

Description claire de l'implementation. Pas une liste de fichiers — une explication de ce qui a change et pourquoi c'est fait comme ca.

## Changesets

- `emoji type(scope): description du commit 1`
- `emoji type(scope): description du commit 2`

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
