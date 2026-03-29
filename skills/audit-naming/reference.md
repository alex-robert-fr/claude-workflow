# Referentiel de conventions de nommage

Regles universelles applicables a tout projet. Les regles framework-specific (NestJS, Vue, Nuxt, etc.) ne sont PAS ici — elles viennent du projet cible via `.claude/skills/`.

## Conventions de casse par contexte

| Contexte | Convention standard |
|---|---|
| Fichiers / dossiers | `kebab-case` |
| Variables locales | `camelCase` ou `snake_case` (selon langage) |
| Constantes globales | `SCREAMING_SNAKE_CASE` |
| Classes / Types / Enums | `PascalCase` |
| Membres d'enum | `SCREAMING_SNAKE_CASE` |
| Tables / colonnes DB | `snake_case` |
| Routes API | `kebab-case`, pluriel, noms (pas verbes) |

Le sub-agent doit detecter le langage et appliquer la convention communautaire correspondante :
- JS/TS : `camelCase` pour variables/fonctions
- Python/Ruby : `snake_case` pour variables/fonctions
- Go : `camelCase` (exporte = PascalCase)
- Rust : `snake_case` pour variables/fonctions, `PascalCase` pour types
- Java : `camelCase` pour variables/fonctions

## Antipatterns universels

| Antipattern | Correct |
|---|---|
| `data`, `info`, `manager`, `helper`, `utils` (fourre-tout) | Nom precis du domaine |
| `temp`, `tmp`, `foo`, `bar` | Variable nommee selon son role |
| Abreviations ambigues (`usr`, `ord`, `btn`) | Nom complet (`user`, `order`, `button`) |
| `new2`, `final`, `v2` dans les noms | Versioning via Git/semver |
| Prefixe `I` sur les interfaces TS (`IUserService`) | `UserService` |
| Negations dans les booleens (`not_active`, `no_access`) | Affirmations (`is_active`, `has_access`) |
| Booleens sans prefixe (`active`, `status`) | Prefixe `is_`, `has_`, `can_`, `should_` |
| Nombres sans unite (`timeout = 5000`) | Unite dans le nom (`timeout_ms = 5000`) |

## Regles de nommage semantique

### Regle 1 — Un nom revele l'intention, pas l'implementation

```
BAD:  filtered_array, result, mapped_data
GOOD: pending_orders, invoices, user_emails
```

### Regle 2 — Le contexte ne se repete pas

```
BAD:  Dans UserService : getUserById(), getUserEmail()
GOOD: Dans UserService : findById(), getEmail()
```

### Regle 3 — La longueur du nom est proportionnelle a la portee

```
Portee courte (lambda/boucle) → court OK : items.map(x => x.id)
Portee module/global → explicite : DEFAULT_PAGINATION_LIMIT
```

### Regle 4 — Les fonctions ont un verbe d'action precis

| Verbe | Contrat attendu |
|---|---|
| `get` | Retourne depuis un etat existant, synchrone |
| `fetch` | I/O impliquee (DB, API) |
| `find` | Peut retourner `null` — pas de throw |
| `create` | Instancie sans persister |
| `save` / `persist` | Persiste en DB |
| `build` | Construit un objet complexe |
| `compute` / `calculate` | Logique pure |
| `validate` | Throw ou retourne erreur si invalide |
| `parse` | Transforme un format brut en structure typee |
| `handle` | Reponse a un event/command |
| `notify` | Effet de bord (email, push, webhook) |
| `check` | Retourne boolean, pas de side effect |

### Regle 5 — Vocabulaire consistant dans tout le codebase

Un seul terme par concept (Ubiquitous Language). Ne jamais melanger `getUser()` / `fetchMember()` / `loadAccount()` pour le meme concept.

### Regle 6 — Pas de mots parasites

Mots interdits sauf contexte generique justifie : `data`, `info`, `result`, `value`, `temp`, `obj`, `item`, `Manager`, `Helper`, `Utils`.

## Exclusions par defaut

Patterns a ignorer lors du scan :

```
node_modules/
.git/
dist/
build/
coverage/
.next/
.nuxt/
vendor/
__pycache__/
.venv/
target/
*.min.js
*.min.css
*.map
*.lock
*.generated.*
```

## Format du rapport

```markdown
## Audit naming — [nom du projet]

### Resume
- Erreurs : N
- Warnings : N
- Suggestions : N

### Fichiers et dossiers
[Violations de nommage sur les fichiers/dossiers]

### Variables et constantes
[Violations de nommage sur les variables/constantes]

### Fonctions et methodes
[Violations de nommage sur les fonctions/methodes]

### Classes, types et interfaces
[Violations de nommage sur les classes/types/interfaces]

### Coherence du vocabulaire
[Inconsistances detectees dans le vocabulaire du codebase]

---

Pour chaque violation :
- Fichier et ligne
- Severite : erreur | warning | suggestion
- Description precise
- Suggestion de renommage (quand pertinent)

Severites :
- **erreur** — violation manifeste d'une convention universelle (mauvaise casse, nom interdit)
- **warning** — nom ambigu, abreviation non standard, incoherence avec le reste du codebase
- **suggestion** — amelioration possible de la lisibilite ou de la precision
```
