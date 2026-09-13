# Plan technique — template et règles

Chargé par `/pipe-plan` à la rédaction. Le plan est écrit dans la section `## Plan` du pilotage.

## Template

```markdown
## Plan — [Titre du ticket] (#XX / PROJ-XX)

**Classification :** technique | métier | mixte

### Vue d'ensemble
- **Avant** : ce qui pose problème aujourd'hui
- **Après** : ce que ça donnera une fois fait

### Approche technique
- Fonction clé et où elle vit : `nomFonction()` dans [fichier.ts](chemin/relatif)
- Alternative écartée — pourquoi

### Étapes d'implémentation

#### 1. [fichier.ts](chemin/vers/fichier.ts) — créer | modifier | supprimer

Une phrase : à quoi sert ce fichier, dans le langage du produit.

```
Label aligné      : valeur ou signature
Si condition      : comportement
nomFonction(param: Type): TypeRetour
```

#### 2. [autre.ts](chemin/vers/autre.ts) — créer | modifier | supprimer
...

### Tests

**[fichier.spec.ts](chemin/vers/fichier.spec.ts)**
- Comportement testé, une ligne
- Un autre comportement, une ligne

### Points d'attention
- **Idée clé en gras** — le reste de l'explication
- **Effet de bord ou zone sensible** — pourquoi ça mérite l'attention

### Récapitulatif des fichiers

| Fichier | Action | Description |
|---------|--------|-------------|
| [fichier.ts](chemin/fichier.ts) | créer | Brève description |
```

## Règles

- Budget 80-120 lignes pour un ticket simple, 150 au plus pour un ticket décomposé ; au-delà, le plan contient du code ou du détail d'implémentation qui appartient à `/pipe-code`
- Chemins réels, vérifiés à l'exploration ; fichier inexistant marqué `(à créer)`
- Aucun corps de fonction ni logique. Un bloc ``` par étape est autorisé pour lister signatures et comportements (`Label : valeur`, un par ligne), précédé de sa phrase d'intro en langage naturel
- Aucun schéma : contrairement à la spec, il embrouille plus qu'il n'aide ici
- Aucune étape floue : ce qu'on ne sait pas implémenter est dit explicitement
- Ordre des étapes = ordre d'implémentation, dépendances d'abord
- La section Tests compte double : c'est elle que `/pipe-test` transforme en tests — comportements attendus et cas limites y sont explicites
- Tableau récapitulatif seulement au-delà de 4-5 fichiers ; en deçà, les en-têtes des étapes portent déjà l'information
