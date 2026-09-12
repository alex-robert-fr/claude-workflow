# Fichier de pilotage — template

Template partage, charge par `/pipe-spec` (qui crée le fichier) et par `/pipe-plan` (qui le complète). Depuis un skill du plugin : `${CLAUDE_SKILL_DIR}/../../shared/pilotage-template.md`.

Le fichier `.claude/plans/plan-<identifiant>.md` pilote tout le cycle d'un ticket. Il est gitignore (document de travail), mis a jour par chaque skill du pipeline, et supprime par `/pipe-pr` a la creation de la PR. C'est lui qui permet la reprise dans une session neuve.

Il est **ouvert par `/pipe-spec`** des que la feature est identifiee — avant meme le cadrage, pour que cette phase soit elle aussi reprenable par `/pipe-ship`. A ce stade, seul l'en-tete est rempli (ticket, spec visee, etat vierge). `/pipe-plan` le complète ensuite, ou le crée lui-meme si le ticket ne passe pas par une spec.

```markdown
# Pilotage — [PROJ-42] Titre du ticket

## Ticket
PROJ-42 | #42

## Spec
`docs/specs/<feature>.md` — créée | mise a jour | sans objet (aucune feature concernee)

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
[le plan technique — template « Template de plan technique » de /pipe-plan]

## Tests
[a completer par /pipe-test — comportements couverts par fichier, un par ligne]

## Notes de reprise
- **3 lignes max.** Uniquement ce qui ne figure nulle part ailleurs (pas de redite du plan ni de ses Points d'attention) et qui sert a la session suivante
```

Nommage : issue git → `plan-42.md` ; ticket JIRA → `plan-PROJ-42.md` ; texte libre → `plan-<slug>.md`.

Règles :

- La section Ticket ne porte que l'identifiant. Titre, lien, version cible, epic : tout cela vit sur le tracker et s'y relit au moment utile (journal des specs, Pull Request) — recopie dans le pilotage, ca vieillit avec le ticket sans que personne ne le voie. La classification vit dans l'en-tete du plan
- Chaque skill coche les cases de l'etat **en fin de phase**, jamais en avance
- Les cases de review humaine (`Tests valides`, `Code valide`) ne se cochent qu'apres validation explicite de l'utilisateur
- Pas de journal de decisions dans le pilotage. Une decision qui survit au merge va dans le journal de la spec ; une decision qui ne concerne que ce cycle **corrige le plan en place** (approche, étape ou point d'attention). Un journal a cote du plan ne fait que le dupliquer, puis le contredire
- Notes de reprise : 3 lignes max, jamais une redite du plan ou de ses Points d'attention
- La section `## Tests` n'est remplie que par `/pipe-test`, jamais par `/pipe-plan` (qui rédige déjà sa propre section Tests **a l'interieur** du plan) — doublon sinon
- `Spec a jour` est cochee par `/pipe-spec` apres validation humaine de la spec, ou par `/pipe-plan` quand le ticket ne concerne aucune feature (`sans objet`). Le contenu de la spec vit dans `docs/specs/`, jamais recopie ici — le pilotage n'en porte que le chemin
- Un pilotage ouvert par `/pipe-spec` est **supprime** si `/pipe-plan` bascule ensuite le ticket en voie rapide : pas de cycle, pas de pilotage
- Ticket d'investigation (spike) : `/pipe-spec` coche d'office `Plan valide`, `Tests ecrits`, `Tests valides`, `Dev termine` et `Code valide` avec la mention `(sans objet — spike)`, et la section Branche porte les deux branches — `spike/` pour l'exploration jetable, `docs/` pour la livraison de la spec. `/pipe-ship` enchaine alors du cadrage aux commits
