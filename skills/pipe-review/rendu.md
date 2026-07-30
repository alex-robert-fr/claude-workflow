# Pipe Review — Maquettes de rendu

Ce fichier est charge par le **contexte principal** du skill (jamais par le sub-agent), et seulement quand la review a produit au moins un constat : un statut OK n'a besoin de rien d'ici.

## Motif d'un constat

Un constat s'affiche sur trois lignes, quelle que soit sa severite :

```
- `fichier.ts:42` <probleme_une_phrase>
  · <contexte_fonctionnel>
  → <correction>
```

## Format du rapport (etape 4)

Les trois sections utilisent le meme motif. Ne pas afficher les sections vides.

```
## Review — [branche]

### Statut : Avertissements / Bloquant

### Problemes bloquants (a corriger avant de continuer)
<constats>

### Avertissements
<constats>

### Suggestions
<constats>
```

## Squelette Question/Reponse (etape 5)

Un probleme a la fois, par severite decroissante, a partir des 7 champs produits par le sub-agent :

```
[Severite N/Total] — <fichier>:<ligne>

❓ De quoi on parle ?
   <contexte_fonctionnel>

❓ Le probleme en une phrase
   <probleme_une_phrase>

❓ C'est grave ?
   <gravite_impact>

❓ D'ou ca vient ?
   <cause>

❓ Comment on corrige ?
   <correction>

→ corriger / adapter / ignorer ?
```

## Exemple de rendu Question/Reponse

```
[Bloquant 1/3] — src/services/user.service.ts:42

❓ De quoi on parle ?
   De la modification du profil utilisateur. Quand l'utilisateur
   enregistre des changements, on met a jour la base, on rafraichit
   le cache, puis on lui confirme que c'est sauvegarde pour qu'il
   voie les bonnes infos sur les ecrans suivants.

❓ Le probleme en une phrase
   On confirme la sauvegarde a l'utilisateur avant que le cache
   soit reellement a jour.

❓ C'est grave ?
   L'utilisateur verra l'ancienne version de son profil juste apres
   l'avoir modifie. Ca se produit environ 1 fois sur 10 selon la
   charge, et il faut recharger la page pour voir les bonnes infos.

❓ D'ou ca vient ?
   Le code lance le rafraichissement du cache mais n'attend pas
   sa fin avant d'envoyer la confirmation. Un mot-cle d'attente
   est manquant a cet endroit precis.

❓ Comment on corrige ?
   Attendre la fin du rafraichissement du cache avant de notifier
   l'utilisateur : ajouter `await` devant l'appel a `saveCache(user)`.

→ corriger / adapter / ignorer ?
```
