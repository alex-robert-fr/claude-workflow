# Inventaire des features non specifiees

Charge par le mode inventaire de `/pipe-spec` (aucun argument). Fichier separe
de `reference.md` a dessein : le mode inventaire enchaine sur le flow normal, qui
charge déjà `reference.md` a l'étape 5 — tout garder dans un seul fichier le
faisait lire deux fois dans la meme invocation.


Méthode du mode inventaire de `/pipe-spec` (appel sans argument), pour amorcer un projet dont les features existent déjà.

### 1. Repérer les features candidates

Croise trois sources, dans cet ordre :

- **La structure du code** : les repertoires de premier et second niveau sous la racine de code (`src/`, `app/`, `packages/`...). Un module = souvent une feature
- **Les points d'entrée utilisateur** : routes, commandes CLI, ecrans, handlers, jobs — ce que le produit expose
- **Le CLAUDE.md et le README** : ils nomment déjà les features importantes, dans le vocabulaire du projet

Retiens le **vocabulaire métier**, pas les noms techniques : la feature s'appelle « export CSV », pas `CsvExportService`.

### 2. Prioriser par valeur

Le critère : **une spec rapporte proportionnellement au nombre de fois ou on rouvrira la feature**. Le passe le predit — les zones les plus modifiees sont celles qu'on relira le plus.

```bash
git log --since="12 months ago" --name-only --pretty=format: -- <racine-de-code> \
  | grep -v '^$' \
  | awk -F/ '{print $1"/"$2}' \
  | sort | uniq -c | sort -rn | head -20
```

Adapter la profondeur de l'`awk` a l'arborescence (`$1"/"$2"/"$3` sur un monorepo). Restreindre le pathspec a la racine de code : sans cela, `CHANGELOG.md`, les manifestes et les fichiers de config saturent le haut du classement sans être des features.

Trois signaux ponderent ce classement :

- **Volume de code** : une feature d'un seul fichier trivial ne merite pas de spec
- **Complexite du métier** : les règles implicites, les cas limites nombreux, les arbitrages passes — c'est la que la spec fait gagner le plus
- **Ce que l'utilisateur sait encore** : une feature ecrite il y a deux ans dont personne ne se rappelle le pourquoi produira une spec creuse ; preferer celles dont l'intention est encore fraiche

### 3. Presenter le classement

| # | Feature | Repertoire | Modifs (12 mois) | Pourquoi maintenant |
|---|---------|------------|------------------|---------------------|
| 1 | Export CSV | `src/export/` | 38 | Zone la plus retouchee, règles métier implicites |

Exclure les features déjà presentes dans `docs/specs/README.md`. Si toutes le sont, le dire en une ligne : le rattrapage est termine.

Terminer par le compte : combien de features reperees, combien déjà specifiees, combien restent.
