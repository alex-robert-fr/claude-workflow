# Frontend Code Conventions — Reference

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
