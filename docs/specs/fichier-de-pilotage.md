# Fichier de pilotage

> **Statut** : active
> **Tickets** : #52

## En une phrase

Le document ephemere qui porte l'etat d'un ticket et rend son cycle reprenable en session neuve.

## Intention

Le cycle d'un ticket traverse plusieurs sessions, chacune avec un contexte propre. Sans support externe, chaque reprise repart de zero : reexpliquer le ticket, retrouver ce qui a ete decide, deviner ce qui reste.

Reussi si `/pipe-ship <ticket>` suffit a reprendre exactement la ou on s'est arrete.

## Philosophie

**Porter l'etat, pas le savoir.** Ce qui est durable vit dans les specs ; le pilotage ne garde que ce qui meurt avec le ticket. Critère de tri : est-ce que quelqu'un en aura besoin apres le merge ? Si oui, ca va ailleurs.

## Comportement attendu

- Un pilotage par ticket, dans `.claude/plans/plan-<identifiant>.md`
- La section Ticket ne porte que l'identifiant : titre, lien, version cible et epic se relisent sur le tracker
- Il existe de l'ouverture du cadrage jusqu'a la creation de la PR, puis est supprime
- La première case non cochee de la section Etat designe la phase courante
- Chaque phase coche sa case en fin de phase, jamais en avance
- Les cases de review humaine ne se cochent qu'apres validation explicite de l'utilisateur
- Aucun journal de decisions : une decision durable va dans la spec, une decision de cycle corrige le plan en place
- Plusieurs pilotages coexistent (tickets paralleles) ; sans argument, l'ambiguite se leve par une question
- Un cycle bascule en voie rapide supprime le sien

## Hors scope

- **Être versionne ou archive** — conserver les pilotages recree une doc morte
- **Documenter la feature** — rôle de `docs/specs/` ; le pilotage n'en porte que le chemin
- **Remplacer le tracker** — pas de statut, d'assignation ni d'estimation
- **Journal de bord** — le plan corrige en place dit ce qui a ete decide ; un journal a cote le duplique puis le contredit

## Fonctionnement technique

Markdown a sections fixes : Ticket, Spec, Etat, Branche, Plan, Tests, Notes de reprise. Les skills lisent par section, jamais par position.

Localisation commune a tous les skills : argument fourni → `plan-<identifiant>.md` ; sinon glob sur `.claude/plans/plan-*.md`. `/pipe-ship` s'en sert comme d'une machine a etats — il lit l'Etat et charge le skill de la première case non cochee.

Cycle de vie : ouverture par `/pipe-spec` (en-tete seul), enrichissement par chaque phase, suppression par `/pipe-pr`.

## Dependances

- **Internes** : les specs (`docs/specs/`), dont il porte le chemin ; les conventions de branches
- **Externes** : le `.gitignore` du projet cible ; le tracker, ou l'identifiant renvoie
- **Dependants** : tous les skills `pipe-*`, et `setup` qui prepare son repertoire

## Decisions

| Version | Ticket | Decision | Raison | Alternative ecartee |
|---------|--------|----------|--------|---------------------|
| 1.5.0 | #52 | Gitignore plutot que versionne | Un document de travail versionne devient une doc morte | Le committer avec la feature |
| 1.5.0 | #52 | Etat en cases a cocher, pas en champ `phase:` | Montre d'un coup d'oeil ce qui est fait et ce qui reste | Un champ de statut unique |
| 1.6.0 | — | Ouvert par `/pipe-spec`, non par `/pipe-plan` | Rend le cadrage reprenable par `/pipe-ship` comme les autres phases | Laisser `/pipe-plan` le créer, au prix d'un angle mort pendant le cadrage |
| 1.6.0 | — | Template sorti dans `shared/pilotage-template.md` | `/pipe-spec` chargeait deux fois `pipe-plan/reference.md` dans une seule invocation, pour ~2 500 tokens jetes | Le laisser chez `pipe-plan`, qui n'est pas le createur du fichier |
| 1.8.0 (a venir) | — | Le pilotage n'a pas de journal de decisions | Les entrées `[spec]` recopiaient le journal de la spec et les entrées `[plan]` repetaient le plan quelques lignes plus bas ; une decision de cycle corrige le plan, une decision durable va dans la spec | Journal `- [tag] **Decision** : raison`, alimente par chaque phase |
| 1.8.0 (a venir) | — | La section Ticket ne porte que l'identifiant | Titre, lien, version cible et epic vieillissent avec le ticket sans que personne ne le voie ; le tracker reste la seule source, relue au moment utile | En-tete complet recopie depuis le tracker (source, lien, version cible, epic, classification) |

## Points d'entrée

| Fichier | Rôle |
|---------|------|
| `shared/pilotage-template.md` | Template et règles de tenue — source de vérité du format |
| `skills/pipe-spec/SKILL.md` | Ouverture du pilotage |
| `skills/pipe-ship/SKILL.md` | Lecture de l'Etat, table Etat → skill |
| `skills/pipe-pr/SKILL.md` | Suppression en fin de cycle |
| `skills/setup/SKILL.md` | Creation de `.claude/plans/` et de la règle `.gitignore` |

## Pieges et zones sensibles

- **Ajouter une case a l'Etat impose de mettre a jour la table de `/pipe-ship`** — sinon la phase n'est jamais exécutée.
- Le template vit dans `shared/`, hors de `skills/` : un repertoire sans `SKILL.md` n'a pas de frontmatter, donc aucun cout de contexte permanent. Ses deux consommateurs (`/pipe-spec` qui crée le fichier, `/pipe-plan` qui le complète) le chargent par un chemin qualifie.
- Les pilotages ouverts par une version anterieure n'ont pas toutes les cases : c'est la première case **presente** et non cochee qui compte.
