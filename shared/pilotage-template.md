# Fichier de pilotage — template

Template partage, charge par `/pipe-spec` (qui cree le fichier) et par `/pipe-plan` (qui le complete). Depuis un skill du plugin : `${CLAUDE_SKILL_DIR}/../../shared/pilotage-template.md`.

Le fichier `.claude/plans/plan-<identifiant>.md` pilote tout le cycle d'un ticket. Il est gitignore (document de travail), mis a jour par chaque skill du pipeline, et supprime par `/pipe-pr` a la creation de la PR. C'est lui qui permet la reprise dans une session neuve.

Il est **ouvert par `/pipe-spec`** des que la feature est identifiee — avant meme le cadrage, pour que cette phase soit elle aussi reprenable par `/pipe-ship`. A ce stade, seul l'en-tete est rempli (ticket, spec visee, etat vierge). `/pipe-plan` le complete ensuite, ou le cree lui-meme si le ticket ne passe pas par une spec.

```markdown
# Pilotage — [PROJ-42] Titre du ticket

## Ticket
- **Source** : JIRA PROJ-42 | GitHub #42 — [lien]
- **Version cible** : 0.5.2 (ticket parent, si connue)
- **Epic** : nom de l'epic, si connue
- **Classification** : technique | metier | mixte

## Spec
`docs/specs/<feature>.md` — creee | mise a jour | sans objet (aucune feature concernee)

## Etat
- [ ] Spec a jour
- [ ] Plan valide
- [ ] Tests ecrits
- [ ] Tests valides (review humaine)
- [ ] Dev termine (tests verts)
- [ ] Code valide (review agent + humaine)
- [ ] Commits crees
- [ ] PR creee

## Branche
`feat/PROJ-42-titre-court` (creee par /pipe-test)

## Decisions
- [spec] **Arbitrage de cadrage** : reporte dans la section Decisions de la spec
- [plan] **Decision prise pendant le Q/R** : sa raison en une ligne
- [tests] **Decision prise pendant la review humaine des tests** : sa raison
- [dev] **Decision prise face a un probleme non anticipe** : sa raison
- [review] **Decision prise pendant la review humaine du code** : sa raison

## Plan
[le plan technique — template « Template de plan technique » de /pipe-plan]

## Tests
- `chemin/fichier.spec.ts` — comportements couverts, en une ligne

## Notes de reprise
- **3 lignes max.** Uniquement ce qui ne figure nulle part ailleurs (pas de redite de Decisions ou Points d'attention) et qui sert a la session suivante
```

Nommage : issue git → `plan-42.md` ; ticket JIRA → `plan-PROJ-42.md` ; texte libre → `plan-<slug>.md`.

Regles :

- Chaque skill coche les cases de l'etat **en fin de phase**, jamais en avance
- Les cases de review humaine (`Tests valides`, `Code valide`) ne se cochent qu'apres validation explicite de l'utilisateur
- La section Decisions est un journal : on ajoute, on ne reecrit pas
- Format d'une decision : `- [tag] **Decision en quelques mots** : raison en une ligne`. Le gras porte le choix, les deux-points introduisent le pourquoi — jamais de paragraphe, jamais le contexte deja connu (le ticket, la stack) rappele en toutes lettres
- Notes de reprise : 3 lignes max, jamais une redite de Decisions ou de Points d'attention
- `Spec a jour` est cochee par `/pipe-spec` apres validation humaine de la spec, ou par `/pipe-plan` quand le ticket ne concerne aucune feature (`sans objet`). Le contenu de la spec vit dans `docs/specs/`, jamais recopie ici — le pilotage n'en porte que le chemin
- Un pilotage ouvert par `/pipe-spec` est **supprime** si `/pipe-plan` bascule ensuite le ticket en voie rapide : pas de cycle, pas de pilotage
