Commence par lire `.claude/skills/shared/SKILL.md`.

---

### Si aucun argument — Mode audit complet

Analyse toutes les configs lint/format du projet et produit un rapport complet avec recommandations.

### Si un argument — Mode ciblé

Focus sur un aspect spécifique. Arguments possibles :
- `biome` — audit de la config Biome uniquement
- `eslint` — audit de la config ESLint uniquement
- `hooks` — audit des pre-commit hooks
- `perf` — analyse de performance du linting
- `strict` — audit du niveau de strictness des règles

---

## Étape 1 — Explorer les configs existantes

Lis `.claude/skills/code-conventions/SKILL.md` pour comprendre la stack du projet, puis scanne pour identifier toutes les configurations lint/format en place :

- `biome.json` / `biome.jsonc` (racine et workspaces)
- `eslint.config.mjs` / `.eslintrc.*` (racine et workspaces)
- `.prettierrc*` / `prettier.config.*`
- `.editorconfig`
- `.husky/` / `.lefthook.yml` / `lint-staged.config.*`
- `turbo.json` (tasks lint/format)
- `package.json` (scripts lint/format, devDependencies liées)
- `tsconfig.json` (options strictness liées au linting)

Lis chaque fichier trouvé pour comprendre la configuration actuelle.

## Étape 2 — Analyser

Lis `.claude/skills/lint-expertise/SKILL.md` puis évalue chaque axe :

1. Choix des outils — sont-ils optimaux ?
2. Performance — temps de lint, cache activé ?
3. Strictness — règles critiques activées ?
4. Formatting — un seul formatter, config cohérente ?
5. Couverture — tous les types de fichiers couverts ?
6. Automatisation — hooks, CI, IDE ?
7. Configuration — convention over config, pas de duplication ?

## Étape 3 — Produire le rapport

Affiche le rapport au format défini dans le skill `lint-expertise`.

Pour chaque amélioration recommandée, montre le diff concret (avant/après) de la config concernée.

## Étape 4 — Confirmer avant d'appliquer

Affiche le récap des modifications à effectuer :

```
📋 Modifications à appliquer (N) :

1. [fichier] — [ce qui va changer]
2. [fichier] — [ce qui va changer]
...

⚠️ Actions irréversibles :
- [suppression de fichier, changement de dépendances...]
```

Demande confirmation : **"J'applique ces modifications ?"**

## Étape 5 — Appliquer les corrections

Pour chaque modification confirmée :

- Modifie les fichiers de config
- Installe/supprime les dépendances nécessaires (`npm install`/`npm uninstall`)
- Met à jour les scripts dans `package.json` si nécessaire
- Met à jour `turbo.json` si nécessaire

Après chaque fichier modifié, affiche :

```
✅ [fichier] — [ce qui a été fait]
```

## Étape 6 — Vérifier

Exécute le linting pour vérifier que tout fonctionne :

```bash
npx turbo lint
```

Si des erreurs apparaissent, corrige-les ou signale celles qui nécessitent une intervention manuelle.

Affiche le résultat final :

```
## ✅ Configuration lint/format mise à jour

### Modifications appliquées
- [liste des changements]

### Vérification
- turbo lint : ✅ / ❌
- Temps d'exécution : Xs

### Prochaines étapes recommandées
- [actions manuelles restantes, si applicable]
```

---

## Input utilisateur

$ARGUMENTS
