# Pipe Plan — References

## Template de plan technique

```markdown
## Plan — [Titre du ticket] (#XX / PROJ-XX)

### Vue d'ensemble
Resume en 2-3 phrases de ce qu'on va faire et pourquoi.

**Classification :** technique | metier | mixte
**Source :** GitHub #42 | GitLab #42 | JIRA PROJ-42

### Approche technique
Raisonnement : quel pattern, quelle architecture, pourquoi ce choix.
Alternatives ecartees si pertinent (1-2 lignes chacune, pas de dissertation).

### Etapes d'implementation

#### 1. [Nom de l'etape]
- `chemin/vers/fichier.ts` — creer | modifier | supprimer
- Description textuelle des changements : noms de fonctions, signatures, logique
- Pas de bloc de code — decrire en langage naturel ce que /pipe-code devra ecrire

#### 2. [Nom de l'etape]
...

### Tests
Quoi tester, ou, comment. 2-5 bullet points max.

### Points d'attention
- Effets de bord potentiels
- Zones sensibles
- Contraintes techniques

### Recapitulatif des fichiers

| Fichier | Action | Description |
|---------|--------|-------------|
| `chemin/fichier.ts` | creer | Breve description |
| `chemin/autre.ts` | modifier | Ce qui change |
```

## Regles

- Les chemins de fichiers doivent correspondre a la structure reelle du projet (verifies lors de l'exploration)
- Si un fichier n'existe pas encore, indique-le : `(a creer)`
- Pas d'etape floue — si tu ne sais pas comment implementer quelque chose, dis-le explicitement
- Ordre des etapes = ordre logique d'implementation (dependances d'abord)
- **Pas de blocs de code** dans le plan. Decrire les changements en langage naturel avec les noms de fonctions, types et signatures. Le code sera ecrit par `/pipe-code`
- **Budget : 80-120 lignes** pour un ticket simple, 150 max pour un ticket decompose. Si le plan depasse, c'est probablement qu'il contient du code ou des details d'implementation qui appartiennent a `/pipe-code`

## Criteres de classification

| Type | Signaux | Exemples |
|------|---------|----------|
| **Technique** | refactor, migration, perf, CI, lint, deps, infra, dette, tooling | "Migrer de Express a Fastify", "Ajouter le linting" |
| **Metier** | utilisateur, fonctionnalite, UX, dashboard, ecran, bouton, workflow, export | "Ajouter un graphique de suivi", "Export CSV" |
| **Mixte** | Besoin metier + changement architectural significatif | "Ajouter l'authentification OAuth" (login user + couche auth) |

Le type **mixte** est le plus frequent en pratique : la plupart des features metier impliquent du travail technique. Reserve **technique pur** aux tickets sans impact utilisateur visible, et **metier pur** aux tickets qui n'ajoutent pas de nouvelle couche technique.

## Guide de decomposition

### Quand decomposer

Un ticket merite d'etre decompose quand :
- Il touche **>3 modules** distincts
- Il impacte **>2 couches** d'architecture (data, domaine, API, UI)
- Il contient **plusieurs features independantes** emballees ensemble
- Son implementation depasse ce qu'une seule session `/pipe-code` peut couvrir

### Principes de decoupage

- Chaque sous-ticket est **implementable independamment** et apporte de la valeur
- L'ordre respecte les **dependances** (schema DB avant API, API avant UI)
- Les sous-tickets techniques precedent les sous-tickets metier quand ils sont pre-requis
- Chaque sous-ticket a un **critere d'acceptance clair**
- Classifier chaque sous-ticket independamment (technique, metier ou mixte)

### Format de sortie pour un ticket decompose

1. **Liste des sous-tickets** avec pour chacun : classification, titre, 1-2 lignes de description, dependances
2. **Plan detaille uniquement pour le sous-ticket 1** (le template complet ci-dessus)
3. Les sous-tickets suivants seront planifies via `/pipe-plan` au moment de les implementer

### Exemple

Ticket : "Ajouter un systeme de notifications temps reel"

1. **[Technique]** Mettre en place le serveur WebSocket — infra de base, depend de rien
2. **[Technique]** Creer le modele Notification en base — schema + migration, depend de rien
3. **[Mixte]** Implementer l'API de notifications — CRUD + logique metier, depend de 1 et 2
4. **[Metier]** Ajouter le composant notifications dans l'UI — bell + dropdown, depend de 3
5. **[Metier]** Ajouter les preferences de notification utilisateur — settings, depend de 3

→ Plan detaille pour le sous-ticket 1 uniquement. Les autres seront planifies ensuite.
