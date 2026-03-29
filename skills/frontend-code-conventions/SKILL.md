---
name: frontend-code-conventions
description: Conventions d'architecture frontend framework-agnostiques. Structure pages/features/shared, flux de donnees, politiques types/mappers/services/screens. Utiliser lors de l'ecriture ou la revue de code frontend pour respecter l'architecture.
model: haiku
user-invocable: false
---

## Architecture pages / features / shared

### Pages

- Minimales : la page route un Screen, pas de logique metier
- Une page = un import de Screen + config de route

### Features

Logique metier par domaine. Structure type :

```
features/
  nom-feature/
    components/     # composants specifiques au domaine
    services/       # appels API
    types/          # types du domaine
    mappers/        # optionnel — transformations backend→UI
    NomScreen.*     # orchestrateur de l'ecran
```

### Shared

Elements transverses non metier uniquement :

```
shared/
  components/       # composants UI generiques
  lib/              # fonctions utilitaires pures
  types/            # types transverses
  constants/        # constantes globales
```

**Regle** : `shared/` ne contient jamais de logique metier.

## Flux de donnees

```
service → [mapper optionnel] → Screen → composants UI
```

- Les services appellent le backend
- Les mappers transforment les donnees si necessaire
- Le Screen orchestre et distribue aux composants

## Politiques

### Types

- Utiles, pas decoratifs
- Un type distinct uniquement si la forme backend differe reellement de la forme UI

### Mappers

- Creer un mapper seulement si vraie transformation backend→frontend
- Pas de mapper "par principe"

### Composables / hooks

- Rares, petits, specialises
- Jamais de "composable/hook controller" qui remplace le Screen
- Extraire seulement un sous-probleme clair et borne

### State management (stores)

- Uniquement pour etat partage global (auth, user, permissions)
- Etat local d'ecran = dans le Screen, pas dans un store

### Services

- Appels API uniquement
- Pas de logique d'affichage ou de formatage UI

## Role des Screens

Point d'orchestration de l'ecran.

**Contient** : etat local, orchestration, appels services, actions UI, lifecycle.

**Ne contient pas** : helpers transverses, utilitaires generiques, logique reutilisable hors feature.

Si tu hesites sur ou placer du code ou si tu detectes un anti-pattern potentiel, utilise Read pour charger `reference.md` (matrice de decision, regles de decoupage, anti-patterns).
