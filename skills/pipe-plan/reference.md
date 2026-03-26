# Prepare Plan — Template de plan technique

## Structure du plan

```markdown
## Plan — [Titre de l'issue] (#XX)

### Vue d'ensemble
Resume en 2-3 phrases de ce qu'on va faire et pourquoi.

### Approche technique
Explique le raisonnement : quel pattern, quelle architecture, pourquoi ce choix.
Signale les alternatives ecartees si c'est pertinent.

### Etapes d'implementation

#### 1. [Nom de l'etape]
**Fichiers concernes :**
- `chemin/vers/fichier.ts` — ce qu'on y fait precisement (creer / modifier / supprimer)
- `chemin/vers/autre.ts` — idem

**Ce qu'on implemente :**
Description precise des changements : signature des fonctions, structure des classes, logique metier, etc. Pas de pseudo-code vague — si c'est utile, donne un exemple concret.

#### 2. [Nom de l'etape]
...

### Tests
Quoi tester, ou, et comment. Unitaires / integration / e2e selon ce qui est pertinent.

### Points d'attention
- Effets de bord potentiels
- Ce qu'il ne faut surtout pas casser
- Contraintes techniques connues
```

## Regles de precision

- Les chemins de fichiers doivent correspondre a la structure reelle du projet (verifies lors de l'exploration)
- Si un fichier n'existe pas encore, indique-le clairement : `(a creer)`
- Pas d'etape floue. Si tu ne sais pas comment implementer quelque chose, dis-le explicitement plutot que de rester vague
- Ordre des etapes = ordre logique d'implementation (les dependances d'abord)
