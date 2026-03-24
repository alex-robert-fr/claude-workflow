---
name: commit-convention
description: Convention de messages de commit du projet. Utiliser lors de la création de commits, pour formater les messages de commit avec le bon emoji, type et scope.
user-invocable: false
---

## Format

```
emoji type(scope): description en français
```

## Table des types

| Emoji | Type | Usage |
|-------|------|-------|
| ✨ | feat | Nouvelle fonctionnalité |
| 🐛 | fix | Correction de bug |
| ♻️ | refactor | Refactoring |
| ⚡ | perf | Optimisation performance |
| 📝 | docs | Documentation |
| 🔧 | chore | Maintenance / config |

## Scope

Le scope correspond au module métier / DDD (`auth`, `billing`, `user`...).

- **Obligatoire** pour `feat`, `fix`, `refactor`, `perf`
- **Optionnel** pour `docs` et `chore`

## Body

Optionnel, uniquement si le changement n'est pas évident depuis le titre. Sous forme de liste à puces :

```
✨ feat(auth): ajout login OAuth Google

- intègre le flow Authorization Code avec PKCE
- gère le refresh token via cookie HttpOnly
```

## Règles

- **Pas de signature** : ne jamais ajouter de trailer `Co-Authored-By` ou autre signature automatique dans les messages de commit

## Exemples

```
🐛 fix(billing): correction du calcul de TVA sur les abonnements annuels
```

```
🔧 chore: mise à jour des dépendances npm
```

```
♻️ refactor(user): extraction du service de validation email
```
