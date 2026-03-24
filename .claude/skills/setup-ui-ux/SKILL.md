---
name: setup-ui-ux
description: Generer les conventions UI/UX specifiques a un projet. Pose des questions puis cree .claude/skills/ui-ux/SKILL.md avec les preferences visuelles, layouts, patterns d'interaction et composants. Utiliser une fois par projet pour definir l'identite UI.
argument-hint: [theme ou vide pour wizard interactif]
---

Lis `.claude/skills/workflow-persona/SKILL.md` avant de commencer.

---

## Etape 0 — Verifications

- [ ] On est a la racine d'un projet (`.git/` existe)
- [ ] Le dossier `.claude/skills/` existe

Si `.claude/skills/ui-ux/SKILL.md` existe deja, propose de le mettre a jour plutot que de l'ecraser.

Si `$ARGUMENTS` contient un theme (ex: `minimal`, `premium`, `enterprise`), pre-remplir les reponses en consequence et confirmer avec l'utilisateur au lieu de poser toutes les questions.

## Etape 1 — Questionnaire interactif

Pose les questions suivantes via AskUserQuestion, **un groupe a la fois**. Pour chaque groupe, propose les options entre parentheses et un choix par defaut.

### 1. Identite visuelle

- **Tone visuel** : sobre/pro (Linear, Stripe) | colore/ludique | minimaliste/epure | autre
- **Densite** : compact (style Linear) | aere (style Notion) | standard
- **Mode** : light par defaut | dark par defaut | les deux | systeme

### 2. Layouts

- **Back-office/admin** : sidebar fixe | topbar | autre
- **Interface publique** : topbar | sidebar | custom
- **Mobile** : bottom bar | hamburger | tabs | autre

### 3. Formulaires et saisie

- **Pattern creation** : creation rapide (2-3 champs) + completer apres | formulaire complet | wizard step-by-step
- **Edition** : inline editing | page dediee | modale
- **Taille max formulaire** : nombre de champs visibles sans scroll (defaut: 5)

### 4. Tableaux et listes

- **Fonctionnalites** : tri, filtres, pagination, inline edit, bulk actions, colonnes redimensionnables (lesquelles ?)
- **Densite des lignes** : compact | standard | confortable

### 5. Feedback utilisateur

- **Succes/info** : toasts | banners | inline
- **Position toasts** : bas-droite | haut-droite | haut-centre
- **Actions destructives** : modale de confirmation | inline confirm | undo

### 6. Etats de chargement

- **Pattern** : skeleton loaders | spinners | shimmer | progress bar
- **Empty states** : sobre + bouton action | illustration + texte | custom

### 7. Animations

- **Niveau** : micro-interactions poussees (premium) | transitions basiques | minimal | aucune
- **Duree standard** : rapide (100-200ms) | standard (200-300ms) | lente (300-500ms)
- **Respect prefers-reduced-motion** : oui | non

### 8. Design system

- **Librairie de composants** : shadcn, Radix, MUI, Ant Design, custom... (laquelle ?)
- **Politique couleurs** : tokens semantiques uniquement | couleurs directes autorisees
- **Librairie d'icones** : Lucide | Heroicons | Material Icons | autre

## Etape 2 — Generer le fichier

A partir des reponses, genere le contenu de `.claude/skills/ui-ux/SKILL.md` avec ce frontmatter :

```yaml
---
name: ui-ux
description: Conventions UI/UX du projet. Utiliser lors de la creation d'interfaces, composants, ecrans et interactions pour respecter l'identite visuelle et les patterns d'interaction definis.
user-invocable: false
---
```

Le contenu doit :

- Etre structure en sections correspondant aux 8 axes
- Contenir les regles (ce qu'on fait) ET les anti-patterns (ce qu'on evite)
- Inclure un tableau recapitulatif en fin de fichier
- Ne jamais depasser 150 lignes

### Exemple de structure type

```markdown
## Identite visuelle
- Tone : sobre et professionnel (references : Linear, Stripe)
- Densite : compact, bien hierarchise
- Mode : light par defaut, dark supporte

## Layouts
| Contexte | Layout |
|----------|--------|
| Back-office | Sidebar fixe gauche |
| Public | Top bar |
| Mobile | Bottom bar |

## Formulaires
- Pattern par defaut : creation rapide (2-3 champs) + completer apres
- Inline editing pour modifications rapides
- Pas de formulaire > 5 champs visibles sans justification

## Anti-patterns UI
- Formulaire classique > 10 champs
- Spinner seul au centre de la page
- Couleurs en dur au lieu des tokens
- Empty state sans action
- Table sans tri/filtre/pagination
```

## Etape 3 — Confirmer et ecrire

Affiche le contenu complet du fichier genere et demande confirmation :

```
Fichier .claude/skills/ui-ux/SKILL.md a [creer | mettre a jour] :

[contenu complet]

J'ecris ce fichier ?
```

Cree le repertoire `.claude/skills/ui-ux/` si necessaire, puis ecris le fichier apres confirmation.

---

## Input utilisateur

$ARGUMENTS
