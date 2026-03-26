# Reference — Grilles d'evaluation lint/format

## Choix des outils

| Outil | Forces | Quand l'utiliser |
|-------|--------|------------------|
| **Biome** | Formatter + linter unifie, Rust, <100ms, support Vue/JSON/CSS | Outil principal — remplace Prettier + une partie d'ESLint |
| **ESLint** (flat config) | Ecosysteme de plugins, regles semantiques TS, plugins Vue | Complement a Biome pour les regles que Biome ne couvre pas |
| **oxlint** | 50-100x plus rapide qu'ESLint, compatible regles ESLint | Alternative/complement a ESLint quand la vitesse CI est critique |
| **dprint** | Formatter Rust, pluggable, tres rapide | Alternative a Biome si formatter-only souhaite |

**Principe** : minimiser le nombre d'outils. Un outil rapide qui fait 90% > deux outils lents qui font 100%.

## Performance

- Le lint complet du projet doit s'executer en **< 5 secondes** en local
- Preferer les outils Rust/Go (Biome, oxlint) aux outils JS (ESLint, Prettier) quand possible
- Utiliser le cache (Biome cache, ESLint cache, Turborepo cache)
- Le pre-commit hook doit lint **uniquement les fichiers modifies** (lint-staged ou equivalent)

## Strictness

**Regles obligatoires** (non-negociables) :
- `noExplicitAny` / `@typescript-eslint/no-explicit-any` — pas de `any`
- `noUnusedImports` / `@typescript-eslint/no-unused-vars` — imports propres
- `noConsoleLog` (ou warn) — pas de debug en production
- `noDefaultExport` — sauf fichiers qui l'exigent (Vue, configs)
- `useStrictEquality` / `eqeqeq` — toujours `===`
- `noVar` — `const`/`let` uniquement
- Complexite cyclomatique max <= 15
- Max lignes par fichier <= 300
- Max lignes par fonction <= 50

**Regles recommandees** :
- `noNonNullAssertion` — eviter les `!` TypeScript
- `noParameterAssign` — parametres immutables
- `useExhaustiveDependencies` (React/Vue hooks)
- `noShadowRestrictedNames` — pas de shadowing

## Formatting

- **Un seul formatter** pour tout le projet — jamais Prettier + Biome en parallele
- Indentation : tabs (accessibilite, compacite)
- Quotes : double quotes (coherence avec JSON, HTML)
- Trailing comma : `all` (diffs git propres)
- Semicolons : obligatoires (evite les ASI bugs)
- Line width : 100 (compromis lisibilite/ecrans modernes)
- End of line : `lf` (cross-platform)

## Couverture fichiers

Tous les fichiers du projet doivent etre couverts :
- `.ts`, `.tsx` — TypeScript
- `.vue` — templates Vue (Biome 2.x + eslint-plugin-vue)
- `.json`, `.jsonc` — configs
- `.css`, `.scss` — styles (si applicable)
- `.md` — markdown (formatting only)
- `.yaml`, `.yml` — CI/configs

## Automatisation

- **Pre-commit** : lint + format des fichiers stages (husky + lint-staged ou lefthook)
- **CI** : lint complet en check mode (pas de fix, fail si erreur)
- **IDE** : format on save configure (settings recommandes dans le repo)
- **Turborepo** : tasks `lint` et `format` avec cache

## Configuration

- **Convention over configuration** — le moins de config custom possible
- Un `biome.json` a la racine du monorepo (pas par workspace sauf override necessaire)
- ESLint flat config (`eslint.config.mjs`) par workspace si les besoins different (Vue vs Node)
- Ignore patterns centralises, pas de `.eslintignore` / `.biomeignore` separes
- Pas de duplication de regles entre Biome et ESLint — desactiver dans ESLint ce que Biome couvre deja

## Anti-patterns a detecter

- Prettier ET Biome actifs en meme temps (conflits de formatting)
- `.eslintrc.json` (legacy) au lieu de `eslint.config.mjs` (flat config)
- `any` autorise sans override explicite
- Pre-commit hook qui lint tout le projet au lieu des fichiers stages
- Regles de style dans ESLint (Biome s'en charge)
- Config ESLint qui extends 10+ configs (lent, conflits)
- Pas de cache active
- Formatter configure differemment entre Biome et l'IDE

## Format de rapport

```
## Audit lint/format

### Score global : [X/10]

### Points conformes
- [ce qui est deja bien configure]

### Ameliorations recommandees
Pour chaque amelioration :
- **Quoi** : description precise
- **Pourquoi** : quel probleme ca resout
- **Comment** : changement concret a appliquer
- **Impact** : performance, strictness, DX

### Problemes critiques
[Configurations dangereuses ou anti-patterns majeurs]

### Comparaison avant/apres
| Metrique | Avant | Apres |
|----------|-------|-------|
| Temps de lint | Xs | Ys |
| Regles actives | N | M |
| Couverture fichiers | X% | Y% |
```
