---
name: worktree
description: Creer, lister, supprimer et basculer entre worktrees git pour travailler en parallele sur plusieurs branches.
argument-hint: [create|list|remove|switch] [branche]
allowed-tools: Read, Bash(git *)
---

## Contexte

- Worktrees actifs : !`git worktree list`
- Branche courante : !`git branch --show-current`
- Repertoire du repo : !`git rev-parse --show-toplevel`

---

## Convention d'emplacement

Les worktrees sont créés dans un repertoire frere du repo :

```
<parent>/
  mon-repo/                          <- repo principal
  mon-repo-worktrees/                <- repertoire des worktrees
    feat-123-login/                  <- un worktree par branche
    fix-456-header/
```

**Slug de branche** : remplacer `/` par `-` dans le nom de branche.
Exemple : `feat/123-login` devient `feat-123-login`.

---

## Étape 1 — Router l'action

Determine l'action depuis `$0` :

| `$0` | Action |
|------|--------|
| `create` | Aller a l'Étape 2 |
| `list` | Aller a l'Étape 3 |
| `remove` | Aller a l'Étape 4 |
| `switch` | Aller a l'Étape 5 |
| _(vide)_ | Aller a l'Étape 3 (list par defaut) |

Si `$0` ne correspond a aucune action connue, affiche les actions disponibles et arrete-toi.

---

## Étape 2 — Create

**Prerequis** : `$1` doit être fourni (nom de branche).

1. Calcule le slug et le chemin cible (cf. Convention d'emplacement)
2. Verifie que le worktree n'existe pas déjà dans la liste des worktrees actifs
3. Determine si la branche `$1` existe déjà :
   - **Existe** : `git worktree add <chemin> $1`
   - **N'existe pas** : `git worktree add -b $1 <chemin>`
4. Confirme la creation :

```
Worktree créé :
  Branche : $1
  Chemin  : <chemin>
```

Suite : `/worktree switch $1` pour basculer, ou `/pipe-code` dans ce worktree pour implementer en parallele.

---

## Étape 3 — List

Affiche les worktrees actifs sous forme de tableau lisible :

```
Worktrees actifs :

| Branche | Chemin | Commit |
|---------|--------|--------|
| main    | /path/to/repo | abc1234 |
| feat/xx | /path/to/worktree | def5678 |
```

Si aucun worktree supplementaire (seulement le repo principal), indique :

```
Aucun worktree supplementaire. Utilise `/worktree create <branche>` pour en créer un.
```

---

## Étape 4 — Remove

**Prerequis** : `$1` doit être fourni (nom de branche).

1. Calcule le slug et le chemin cible
2. Verifie que le worktree existe dans la liste des worktrees actifs
3. Verifie qu'on n'est pas actuellement dans le worktree a supprimer
4. **Confirmation obligatoire** : "Je supprime le worktree `$1` a `<chemin>` ?"
5. Apres confirmation :
   - `git worktree remove <chemin>`
   - `git worktree prune`
6. Confirme la suppression :

```
Worktree supprime : $1
Prochaine étape : `/worktree list` pour vérifier.
```

---

## Étape 5 — Switch

**Prerequis** : `$1` doit être fourni (nom de branche).

1. Calcule le slug et le chemin cible
2. Verifie que le worktree existe dans la liste des worktrees actifs
3. Utilise l'outil natif `EnterWorktree` avec le chemin du worktree pour basculer le contexte Claude Code
4. Confirme :

```
Contexte bascule vers le worktree :
  Branche : $1
  Chemin  : <chemin>
```

Suite : `ExitWorktree` ou `/worktree list` pour revenir au repo principal.

---

## Input utilisateur

$ARGUMENTS
