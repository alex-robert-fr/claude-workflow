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

```markdown
## Contexte

Lien vers l'issue et resume en 1-2 phrases de pourquoi ce changement est necessaire.

Closes #XX

## Ce qui a ete fait

Description claire de l'implementation. Pas une liste de fichiers — une explication de ce qui a change et pourquoi c'est fait comme ca.

## Fichiers modifies

- `chemin/fichier.ts` — ce qu'on y a fait
- `chemin/fichier.ts` — idem

## Points de review

Ce sur quoi le reviewer doit porter son attention en priorite. Decisions techniques non triviales, zones sensibles, compromis acceptes.

## Tests

Ce qui a ete teste, comment. Si rien n'a ete teste, le dire explicitement avec la raison.
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
