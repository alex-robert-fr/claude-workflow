---
name: frontend-code-conventions
description: Conventions d'architecture frontend framework-agnostiques. Structure pages/features/shared, flux de donnees, politiques types/mappers/services/screens. Utiliser lors de l'ecriture ou la revue de code frontend pour respecter l'architecture.
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
- Ne pas multiplier les types quasi identiques sans benefice reel
- Un type distinct uniquement si la forme backend differe reellement de la forme UI
- Pas de types "par discipline architecturale"

### Mappers

- Utiles mais non automatiques
- Creer un mapper seulement si :
  - Vraie transformation backend→frontend
  - Champs a deriver ou donnees a normaliser
  - Transformation reutilisee ou lourde
- Pas de mapper "par principe"

### Composables / hooks

- Rares, petits, specialises
- Jamais de "composable/hook controller" qui remplace le Screen
- La logique reste dans le Screen tant qu'elle est lisible
- Extraire seulement un sous-probleme clair et borne

### State management (stores)

- Rares : uniquement pour etat partage global (auth, user, permissions)
- Etat local d'ecran = dans le Screen, pas dans un store

### Services

- Appels API uniquement
- Pas de logique d'affichage ou de formatage UI
- Si un service transforme trop pour la vue → mapper

## Role des Screens

Point d'orchestration de l'ecran.

**Contient** : etat local, orchestration, appels services, actions UI, lifecycle.

**Ne contient pas** : helpers transverses, utilitaires generiques, logique reutilisable hors feature.

## Matrice de decision — ou placer le code

| Question | Destination |
|----------|-------------|
| Appel backend ? | `services/` |
| Transformation de donnees avec vraie valeur ? | `mappers/` |
| Fonction pure transverse ? | `shared/lib/` |
| Etat partage global ? | store |
| Logique locale lisible ? | Screen |
| Sous-probleme reutilisable ou lourd ? | petit composable/hook cible |

## Decoupage quand un Screen grossit

Extraire dans cet ordre :

1. Composant UI/metier
2. Mapper si transformation reelle
3. Petit composable/hook cible

**Jamais** extraire un gros composable/hook controller pour "nettoyer visuellement".

## Convention de style

- Noms explicites, responsabilites visibles, peu d'indirection
- Lisibilite pratique > lisibilite academique
- Code un peu plus long si plus simple a lire = OK
- Pas d'alias obscurs, pas de helpers magiques, pas d'architecture enterprise decorative

## Anti-patterns

- Page qui contient toute la logique d'ecran
- Store pour etat local d'une page
- Composable/hook geant qui remplace le Screen
- Multiplication de types quasi identiques
- Mapper cree par reflexe sans transformation utile
- Service qui fait de la presentation UI cachee
- Code genere avec trop d'abstraction ou de couches
