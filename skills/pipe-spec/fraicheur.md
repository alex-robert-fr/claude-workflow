# Fraîcheur et fin de vie d'une spec

Chargé par `/pipe-review` (fraîcheur des specs après validation du code). Une spec qui décrit du code qui n'existe plus est lue comme une référence : c'est le pire cas, et ces deux mécanismes servent à l'éviter.

## Vérification de fraîcheur

Deux niveaux :

- **Mécanique** — `check-specs.sh`, lancé dans les checks outillés : points d'entrée vers des fichiers disparus, spec hors index, ligne d'index sans fichier, phrase d'index > 80 caractères, spec > 80 lignes, sommaire absent ou désynchronisé des sections
- **Au jugement**, pour chaque spec concernée par le diff :
  1. Le comportement attendu décrit-il ce que le code fait maintenant ?
  2. Le hors scope est-il toujours exact — n'a-t-on pas implémenté ce qui en était exclu ?
  3. Les points d'entrée couvrent-ils les fichiers structurants **ajoutés** par le ticket ? Un fichier neuf n'est dans aucune liste : matcher aussi par répertoire
  4. Une décision structurante prise pendant le dev est-elle consignée dans le journal ?

Tout écart se corrige dans la spec avant de committer — la spec fait partie du changeset. Corriger n'est pas y verser le détail de l'implémentation.

## Dépréciation

Quand : la feature est retirée du produit, remplacée par une autre (la spec qui prend le relais est nommée dans la raison), ou fusionnée dans une plus large (la spec absorbée est dépréciée, celle qui absorbe mise à jour). Un simple refactor ne déprécie pas : la spec reste active, ses points d'entrée sont mis à jour.

Comment :

1. Statut `dépréciée` et ligne `Retrait` : version de retrait, raison en une ligne
2. Le corps est conservé en entier — il répond à « pourquoi cette feature a existé, et pourquoi elle a disparu »
3. Sa ligne d'index passe dans la section « Specs depreciees »
4. Le fichier n'est jamais supprimé

Effets : le hook `SessionStart` cesse de l'injecter (il s'arrête à cette section) ; `check-specs.sh` cesse de contrôler ses points d'entrée.

Signal : `check-specs.sh` distingue quelques points d'entrée morts (la spec a pris du retard → corriger les points d'entrée) de **tous** les points d'entrée morts (la feature n'existe plus → déprécier). La décision reste humaine : une feature peut avoir simplement déménagé.
