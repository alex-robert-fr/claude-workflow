# Fichier de pilotage — template

`.claude/plans/plan-<identifiant>.md`, gitignoré. Ouvert par `/pipe-spec` (en-tête seul), ou par `/pipe-plan` s'il n'existe pas ; mis à jour par chaque skill du cycle ; supprimé par `/pipe-pr` à la création de la PR, ou par `/pipe-plan` si le ticket bascule en voie rapide. Nommage : issue git → `plan-42.md`, ticket externe → `plan-PROJ-42.md`, texte libre → `plan-<slug>.md`.

```markdown
# Pilotage — [PROJ-42] Titre du ticket

## Ticket
PROJ-42 | #42

## Spec
`docs/specs/<feature>.md` — créée | mise à jour | sans objet (aucune feature concernée)

## Etat
- [ ] Spec a jour
- [ ] Plan valide
- [ ] Tests ecrits
- [ ] Tests valides (review humaine)
- [ ] Dev termine (tests verts)
- [ ] Code valide (review agent + humaine)
- [ ] Commits créés
- [ ] PR créée

## Branche
`feat/PROJ-42-titre-court` (créée par /pipe-test)

## Plan
[template « Plan technique » de /pipe-plan]

## Tests
[rempli par /pipe-test — un fichier par ligne en backticks, ses comportements en puces dessous]

`src/module/fichier.spec.ts`
- quand [situation], alors [comportement]

## Notes de reprise
- 3 lignes max, uniquement ce qui n'est nulle part ailleurs et sert à la session suivante
```

## Règles

- Les libellés des cases de l'état sont des identifiants, lus tels quels par `/pipe-ship` et par le hook `protect-tests.sh` : ne pas les reformuler ni les accentuer
- Ticket : l'identifiant seul. Titre, lien, version cible, epic vivent sur le tracker ; la classification vit dans l'en-tête du plan
- Spec : le chemin seul, jamais le contenu. `Spec a jour` est cochée par `/pipe-spec` après validation humaine, ou par `/pipe-plan` quand le ticket ne concerne aucune feature (`sans objet`)
- Chaque skill coche ses cases en fin de phase ; `Tests valides` et `Code valide` seulement après accord explicite de l'utilisateur
- Pas de journal de décisions ici : une décision qui survit au merge va dans le journal de la spec ; une décision propre au cycle corrige le plan en place (approche, étape ou point d'attention)
- `## Tests` n'est rempli que par `/pipe-test` (le plan porte déjà sa propre section Tests). Son format est un contrat : un fichier par ligne, en backticks, chemin relatif à la racine — c'est ce que lit `protect-tests.sh` pour verrouiller les tests validés tant que `Code valide` n'est pas coché
- Ticket d'investigation (spike) : `/pipe-spec` coche d'office `Plan valide`, `Tests ecrits`, `Tests valides`, `Dev termine` et `Code valide` avec la mention `(sans objet — spike)`, et la section Branche porte `spike/…` (exploration jetable) et `docs/…` (livraison de la spec) ; `/pipe-ship` enchaîne alors du cadrage aux commits
