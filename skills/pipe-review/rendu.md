# Pipe Review — Maquettes de rendu

Ce fichier est charge par le **contexte principal** du skill (jamais par le sub-agent), et seulement quand la review a produit au moins un constat : un statut OK n'a besoin de rien d'ici.

Regle commune aux deux maquettes : **une ligne par idee, aucune phrase de transition**. Ce qui tient sur une ligne ne prend pas un paragraphe ; le detail supplementaire, l'utilisateur le demande s'il le veut.

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
## Review — [branche] · N bloquant(s), M avertissement(s), P suggestion(s)

### Bloquants
<constats>

### Avertissements
<constats>

### Suggestions
<constats>
```

## Squelette Question/Reponse (etape 5)

Un probleme a la fois, par severite decroissante, a partir des 7 champs produits par le sub-agent. **Une ligne par champ** — les libelles suffisent, les questions ouvertes sont du remplissage.

```
**[<Severite> N/Total]** `<fichier>:<ligne>`
*<contexte_fonctionnel>*

**Probleme** — <probleme_une_phrase>
**Impact** — <gravite_impact>
**Cause** — <cause>
**Fix** — <correction>

→ corriger / adapter / ignorer ?
```

## Exemple de rendu Question/Reponse

```
**[Bloquant 1/3]** `src/services/user.service.ts:42`
*Modification du profil : on met a jour la base, on rafraichit le cache, puis on confirme a l'utilisateur.*

**Probleme** — on confirme la sauvegarde avant que le cache soit reellement a jour.
**Impact** — l'utilisateur voit son ancien profil juste apres l'avoir modifie, environ 1 fois sur 10 ; il doit recharger la page.
**Cause** — le rafraichissement du cache est lance mais pas attendu avant la confirmation.
**Fix** — attendre le rafraichissement : `await` devant l'appel a `saveCache(user)`.

→ corriger / adapter / ignorer ?
```
