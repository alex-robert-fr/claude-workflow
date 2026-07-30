# Index des specs — `docs/specs/README.md`

Point d'entree unique : c'est le seul fichier a charger pour savoir quelles features existent et laquelle ouvrir.

```markdown
# Specs

Une spec par feature : ce qu'elle est, ce qu'on en attend, son perimetre et ses points
d'entree techniques. A lire avant de modifier une feature — c'est le contexte de reference.

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

Regles :

- Trie les lignes par ordre alphabetique de feature
- **La phrase de resume tient en 80 caracteres maximum.** Le hook `SessionStart` injecte cet index dans **chaque** session : c'est le seul poste de contexte qui grossit avec le projet, et une colonne non bornee le fait grossir deux fois — a 50 specs, la prose libre coute plus que l'index entier. La colonne reste, elle permet de choisir la bonne spec sans ouvrir vingt fichiers ; c'est sa longueur qu'on borne
- Le plafond est **outille** : `.claude/scripts/check-specs.sh` le verifie a chaque `/pipe-review`, il ne repose pas sur la vigilance du modele
- La phrase vient de la section « En une phrase » de la spec — reprise telle quelle si elle tient dans le budget, resumee sinon
- **La section « Specs depreciees » doit rester la derniere** et porter ce titre : le hook SessionStart s'arrete a elle pour n'injecter que les features actives. La renommer ou la deplacer reintroduirait les features retirees dans le contexte
- Pas de spec depreciee → omettre la section entierement
