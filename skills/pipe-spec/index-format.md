# Index des specs — `docs/specs/README.md`

Seul fichier à charger pour savoir quelles features existent et laquelle ouvrir ; injecté dans chaque session par le hook `SessionStart`. Chargé par `/pipe-spec` et `/setup`.

```markdown
# Specs

Une spec par feature : ce qu'elle est, ce qu'on en attend, son périmètre et ses points
d'entrée techniques. À lire avant de modifier une feature — c'est le contexte de référence.

Écrites et maintenues par `/pipe-spec`, vérifiées à chaque `/pipe-review`.

| Feature | Spec | En une phrase |
|---------|------|---------------|
| Export CSV | [`export-csv.md`](export-csv.md) | Résumé issu de la section « En une phrase » |

## Specs depreciees

Features retirées. Conservées pour l'historique — **ne pas les traiter comme du contexte actif**.

| Feature | Spec | Retrait |
|---------|------|---------|
| Import XML | [`import-xml.md`](import-xml.md) | 2.1.0 — remplacé par l'import CSV |
```

- Lignes triées par ordre alphabétique de feature
- Au-delà d'une dizaine de specs, sections thématiques (`## Cycle d'un ticket`, `## Publication`…), chacune avec son tableau trié ; en dessous, un seul tableau. Les sections sont un découpage de lecture : elles ne changent ni les noms de fichiers ni les liens
- Une spec est un fichier à plat dans `docs/specs/`, jamais un répertoire ni un nom préfixé d'un numéro : le nom de fichier est cité par les autres specs et par l'index, un numéro le rendrait mutable. Pièces jointes à plat dans `docs/specs/assets/`
- La phrase de résumé tient en 80 caractères : reprise de « En une phrase » telle quelle si elle tient, résumée sinon. Plafond vérifié par `check-specs.sh`
- La section « Specs depreciees » reste la dernière et garde ce titre exact : le hook `SessionStart` s'y arrête pour n'injecter que l'actif. Aucune spec dépréciée → section omise
