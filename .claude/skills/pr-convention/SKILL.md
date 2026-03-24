---
name: pr-convention
description: Templates et conventions pour les Pull Requests GitHub. Format du titre, body, et commentaires d'itération.
user-invocable: false
---

## Titre

Format : `[Type] Titre de l'issue (#numéro)`

Exemples :

- `[Feature] Ajout authentification OAuth (#42)`
- `[Fix] Crash au login avec email contenant + (#17)`

## Body

```markdown
## Contexte

Lien vers l'issue et résumé en 1-2 phrases de pourquoi ce changement est nécessaire.

Closes #XX

## Ce qui a été fait

Description claire de l'implémentation. Pas une liste de fichiers — une explication de ce qui a changé et pourquoi c'est fait comme ça.

## Fichiers modifiés

- `chemin/fichier.ts` — ce qu'on y a fait
- `chemin/fichier.ts` — idem

## Points de review

Ce sur quoi le reviewer doit porter son attention en priorité. Décisions techniques non triviales, zones sensibles, compromis acceptés.

## Tests

Ce qui a été testé, comment. Si rien n'a été testé, le dire explicitement avec la raison.
```

## Commentaire d'itération

Utilisé uniquement lors de la mise à jour d'une PR existante. Liste tous les commits depuis la dernière mise à jour.

```markdown
## Mise à jour — [date]

### Nouveaux commits

- `emoji type(scope): description du commit 1`
- `emoji type(scope): description du commit 2`

### Changements ajoutés

- `chemin/fichier` — ce qui a changé

### Impact

Résumé en une phrase de l'ensemble de cette itération.
```

S'il n'y a qu'un seul commit, le format reste identique — une seule entrée dans la liste.

## Règles de formatage MCP GitHub

Ne jamais utiliser `\n` littéraux dans le paramètre `body` des appels MCP GitHub (`create_pull_request`, `update_pull_request`, `add_issue_comment`). Utiliser de vrais sauts de ligne dans le texte, sinon les `\n` s'affichent en dur dans le markdown.
