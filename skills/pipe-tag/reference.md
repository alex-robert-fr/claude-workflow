# Tags git — cas hors cadre

Chargé par `/pipe-tag` seulement pour une pre-release à arbitrer, un tag à supprimer ou un doute SemVer.

## SemVer

| Composant | Quand l'incrémenter |
|-----------|-------------------|
| MAJOR | Breaking change (incompatibilité de l'API publique) |
| MINOR | Fonctionnalité rétro-compatible |
| PATCH | Correction rétro-compatible |

Toujours trois composants (`v1.2.0`, jamais `v1.2`) ; `v` en préfixe des tags, absent des titres du CHANGELOG (`[1.2.0]`).

## Pre-releases

`vX.Y.Z-QUALIFICATIF.N` — `alpha` (instable, interne) < `beta` (tests externes) < `rc` (quasi stable) < release stable.

## Annoté, jamais léger

`git tag -a vX.Y.Z -m "..."` pour toute release : le tag porte auteur, date et message, et peut être signé. Un tag léger (`git tag vX.Y.Z`) ne sert qu'à un marqueur interne temporaire.

## Erreurs fréquentes

| Erreur | Conséquence | Bonne pratique |
|--------|-------------|----------------|
| Tag léger en production | Aucune métadonnée, aucune traçabilité | `-a` systématiquement |
| Tag sur une feature branch | Version associée à un commit non mergé | Tagger la branche de production |
| Force-push d'un tag existant | Casse les pipelines CI/CD | Supprimer, puis recréer avec un nouveau numéro |
| Tag non poussé | Local seulement, CI/CD non déclenchée | `git push origin vX.Y.Z` |

## Suppression d'un tag

À éviter en production. Si nécessaire : `git tag -d vX.Y.Z` puis `git push --delete origin vX.Y.Z`.
