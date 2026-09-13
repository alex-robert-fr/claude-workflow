# Inventaire des features non spécifiées

Chargé par `/pipe-spec` sans argument, pour amorcer un projet dont les features existent déjà. Une feature par passe : chacune exige le Q/R de l'étape 4.

## 1. Repérer les features candidates

Croise trois sources : la structure du code (répertoires de premier et second niveau sous `src/`, `app/`, `packages/`… — un module = souvent une feature), les points d'entrée utilisateur (routes, commandes, écrans, handlers, jobs), le `CLAUDE.md` et le README. Retiens le vocabulaire métier (« export CSV »), pas le nom technique (`CsvExportService`).

## 2. Prioriser par valeur

Une spec rapporte proportionnellement au nombre de fois où la feature sera rouverte ; le passé le prédit :

```bash
git log --since="12 months ago" --name-only --pretty=format: -- <racine-de-code> \
  | grep -v '^$' | awk -F/ '{print $1"/"$2}' | sort | uniq -c | sort -rn | head -20
```

Adapter la profondeur de l'`awk` à l'arborescence ; restreindre le pathspec à la racine de code, sinon `CHANGELOG.md` et les configs saturent le classement.

Pondérer par : volume de code (un fichier trivial ne mérite pas de spec), complexité du métier (règles implicites, cas limites, arbitrages passés — là où la spec rapporte le plus), fraîcheur de la mémoire de l'utilisateur (une feature dont personne ne se rappelle le pourquoi donnera une spec creuse).

## 3. Présenter

| # | Feature | Répertoire | Modifs (12 mois) | Pourquoi maintenant |
|---|---------|------------|------------------|---------------------|
| 1 | Export CSV | `src/export/` | 38 | Zone la plus retouchée, règles métier implicites |

Exclure les features déjà dans `docs/specs/README.md` ; toutes présentes → le dire en une ligne, le rattrapage est terminé. Terminer par le compte : repérées, spécifiées, restantes. Puis demander laquelle spécifier maintenant.
