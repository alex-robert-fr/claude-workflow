# Index des specs — `docs/specs/README.md`

Point d'entrée unique : c'est le seul fichier a charger pour savoir quelles features existent et laquelle ouvrir.

```markdown
# Specs

Une spec par feature : ce qu'elle est, ce qu'on en attend, son perimetre et ses points
d'entrée techniques. A lire avant de modifier une feature — c'est le contexte de reference.

Ecrites et maintenues par `/pipe-spec`, verifiees a chaque `/pipe-review`.

| Feature | Spec | En une phrase |
|---------|------|---------------|
| Export CSV | [`export-csv.md`](export-csv.md) | Resume issu de la section « En une phrase » |

## Specs depreciees

Features retirees. Conservees pour l'historique — **ne pas les traiter comme du contexte actif**.

| Feature | Spec | Retrait |
|---------|------|---------|
| Import XML | [`import-xml.md`](import-xml.md) | 2.1.0 — remplace par l'import CSV |
```

Règles :

- Trie les lignes par ordre alphabetique de feature
- **Au-dela d'une dizaine de specs, regroupe-les en sections thematiques** (`## Cycle d'un ticket`, `## Publication`...), chacune avec son propre tableau, tri alphabetique a l'interieur. En dessous, un seul tableau sans section — un regroupement de trois lignes n'organise rien et coute trois en-tetes de contexte. Les sections sont un decoupage de **lecture** : elles ne changent ni les noms de fichiers, ni l'arborescence, ni les liens entre specs, et restent donc gratuites a reorganiser
- **Une spec est un fichier a plat dans `docs/specs/`**, jamais un repertoire, jamais prefixee d'un numéro. Le nom de fichier est l'identite : il est cite par les autres specs, par les points d'entrée et par cet index. Un numéro le rend mutable — inserer une feature renommerait la suite et casserait toutes ces references. Le besoin d'organisation visuelle se traite par les sections ci-dessus ; une piece jointe (schema, capture) va a plat dans `docs/specs/assets/`
- **La phrase de resume tient en 80 caracteres maximum.** Le hook `SessionStart` injecte cet index dans **chaque** session : c'est le seul poste de contexte qui grossit avec le projet, et une colonne non bornee le fait grossir deux fois — a 50 specs, la prose libre coute plus que l'index entier. La colonne reste, elle permet de choisir la bonne spec sans ouvrir vingt fichiers ; c'est sa longueur qu'on borne
- Le plafond est **outille** : `.claude/scripts/check-specs.sh` le verifie a chaque `/pipe-review`, il ne repose pas sur la vigilance du modele
- La phrase vient de la section « En une phrase » de la spec — reprise telle quelle si elle tient dans le budget, resumee sinon
- **La section « Specs depreciees » doit rester la dernière** et porter ce titre : le hook SessionStart s'arrete a elle pour n'injecter que les features actives. La renommer ou la deplacer reintroduirait les features retirees dans le contexte
- Pas de spec depreciee → omettre la section entièrement
