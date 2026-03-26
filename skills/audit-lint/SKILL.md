---
name: audit-lint
description: Auditer et configurer le linting/formatting d'un projet TypeScript. Analyse les configs existantes, recommande les outils modernes (Biome, ESLint flat config), et applique les corrections.
argument-hint: [biome|eslint|hooks|perf|strict ou rien pour audit complet]
---

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/../_workflow-persona/SKILL.md` avant de commencer.

---

### Si aucun argument — Mode audit complet

Analyse toutes les configs lint/format du projet et produit un rapport complet avec recommandations.

### Si un argument — Mode cible

Focus sur un aspect specifique. Arguments possibles :
- `biome` — audit de la config Biome uniquement
- `eslint` — audit de la config ESLint uniquement
- `hooks` — audit des pre-commit hooks
- `perf` — analyse de performance du linting
- `strict` — audit du niveau de strictness des regles

---

## Etape 1 — Explorer les configs existantes

Utilise Read pour charger `.claude/skills/tech-stack/SKILL.md` pour comprendre la stack du projet, puis scanne pour identifier toutes les configurations lint/format en place :

- `biome.json` / `biome.jsonc` (racine et workspaces)
- `eslint.config.mjs` / `.eslintrc.*` (racine et workspaces)
- `.prettierrc*` / `prettier.config.*`
- `.editorconfig`
- `.husky/` / `.lefthook.yml` / `lint-staged.config.*`
- `turbo.json` (tasks lint/format)
- `package.json` (scripts lint/format, devDependencies liees)
- `tsconfig.json` (options strictness liees au linting)

Lis chaque fichier trouve pour comprendre la configuration actuelle.

## Etape 2 — Analyser

Utilise Read pour charger `reference.md` (grilles d'evaluation detaillees), puis evalue chaque axe :

1. Choix des outils — sont-ils optimaux ?
2. Performance — temps de lint, cache active ?
3. Strictness — regles critiques activees ?
4. Formatting — un seul formatter, config coherente ?
5. Couverture — tous les types de fichiers couverts ?
6. Automatisation — hooks, CI, IDE ?
7. Configuration — convention over config, pas de duplication ?

## Etape 3 — Produire le rapport

Affiche le rapport au format defini dans reference.md.

Pour chaque amelioration recommandee, montre le diff concret (avant/apres) de la config concernee.

## Etape 4 — Confirmer avant d'appliquer

Affiche le recap des modifications a effectuer :

```
Modifications a appliquer (N) :

1. [fichier] — [ce qui va changer]
2. [fichier] — [ce qui va changer]
...

Actions irreversibles :
- [suppression de fichier, changement de dependances...]
```

Demande confirmation : **"J'applique ces modifications ?"**

## Etape 5 — Appliquer les corrections

Pour chaque modification confirmee :

- Modifie les fichiers de config
- Installe/supprime les dependances necessaires (`npm install`/`npm uninstall`)
- Met a jour les scripts dans `package.json` si necessaire
- Met a jour `turbo.json` si necessaire

## Etape 6 — Verifier

Execute le linting pour verifier que tout fonctionne :

```bash
npx turbo lint
```

Si des erreurs apparaissent, corrige-les ou signale celles qui necessitent une intervention manuelle.

Affiche le resultat final :

```
## Configuration lint/format mise a jour

### Modifications appliquees
- [liste des changements]

### Verification
- turbo lint : OK / ERREUR
- Temps d'execution : Xs

### Prochaines etapes recommandees
- [actions manuelles restantes, si applicable]
```

---

## Input utilisateur

$ARGUMENTS
