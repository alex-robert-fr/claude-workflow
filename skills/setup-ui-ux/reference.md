# Setup UI/UX — Questionnaire et exemples

## Questionnaire (8 sections)

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

## Exemple de structure generee

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
