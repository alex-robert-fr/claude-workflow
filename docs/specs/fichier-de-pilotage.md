# Fichier de pilotage

> **Statut** : active
> **Tickets** : #52

## En une phrase

Un document de travail ephemere qui porte l'etat, les decisions et le plan d'un ticket, et permet de reprendre son cycle dans une session neuve.

## Intention

Le cycle d'un ticket traverse plusieurs sessions, chacune avec un contexte propre. Sans support externe, chaque reprise repart de zero : reexpliquer le ticket, retrouver ce qui a ete decide, deviner ce qui reste.

Reussi si `/pipe-ship <ticket>` suffit a reprendre exactement la ou on s'est arrete.

## Philosophie

**Porter l'etat, pas le savoir.** Ce qui est durable vit dans les specs ; le pilotage ne garde que ce qui meurt avec le ticket. Critere de tri : est-ce que quelqu'un en aura besoin apres le merge ? Si oui, ca va ailleurs.

## Comportement attendu

- Un pilotage par ticket, dans `.claude/plans/plan-<identifiant>.md`
- Il existe de l'ouverture du cadrage jusqu'a la creation de la PR, puis est supprime
- La premiere case non cochee de la section Etat designe la phase courante
- Chaque phase coche sa case en fin de phase, jamais en avance
- Les cases de review humaine ne se cochent qu'apres validation explicite de l'utilisateur
- La section Decisions est un journal : on ajoute, on ne reecrit pas
- Plusieurs pilotages coexistent (tickets paralleles) ; sans argument, l'ambiguite se leve par une question
- Un cycle bascule en voie rapide supprime le sien

## Hors scope

- **Etre versionne ou archive** — conserver les pilotages recree une doc morte
- **Documenter la feature** — role de `docs/specs/` ; le pilotage n'en porte que le chemin
- **Remplacer le tracker** — pas de statut, d'assignation ni d'estimation
- **Journal de bord exhaustif** — seules les decisions qui engagent la suite du cycle

## Fonctionnement technique

Markdown a sections fixes : Ticket, Spec, Etat, Branche, Decisions, Plan, Tests, Notes de reprise. Les skills lisent par section, jamais par position.

Localisation commune a tous les skills : argument fourni → `plan-<identifiant>.md` ; sinon glob sur `.claude/plans/plan-*.md`. `/pipe-ship` s'en sert comme d'une machine a etats — il lit l'Etat et charge le skill de la premiere case non cochee.

Cycle de vie : ouverture par `/pipe-spec` (en-tete seul), enrichissement par chaque phase, suppression par `/pipe-pr`.

## Dependances

- **Internes** : les specs (`docs/specs/`), dont il porte le chemin ; les conventions de branches
- **Externes** : le `.gitignore` du projet cible ; les MCP de tracker qui alimentent son en-tete
- **Dependants** : tous les skills `pipe-*`, et `setup` qui prepare son repertoire

## Decisions

| Version | Ticket | Decision | Raison | Alternative ecartee |
|---------|--------|----------|--------|---------------------|
| 1.5.0 | #52 | Gitignore plutot que versionne | Un document de travail versionne devient une doc morte | Le committer avec la feature |
| 1.5.0 | #52 | Etat en cases a cocher, pas en champ `phase:` | Montre d'un coup d'oeil ce qui est fait et ce qui reste | Un champ de statut unique |
| 1.6.0 (a venir) | — | Ouvert par `/pipe-spec`, non par `/pipe-plan` | Rend le cadrage reprenable par `/pipe-ship` comme les autres phases | Laisser `/pipe-plan` le creer, au prix d'un angle mort pendant le cadrage |

## Points d'entree

| Fichier | Role |
|---------|------|
| `skills/pipe-plan/reference.md` | Template et regles de tenue — source de verite du format |
| `skills/pipe-spec/SKILL.md` | Ouverture du pilotage |
| `skills/pipe-ship/SKILL.md` | Lecture de l'Etat, table Etat → skill |
| `skills/pipe-pr/SKILL.md` | Suppression en fin de cycle |
| `skills/setup/SKILL.md` | Creation de `.claude/plans/` et de la regle `.gitignore` |

## Pieges et zones sensibles

- **Ajouter une case a l'Etat impose de mettre a jour la table de `/pipe-ship`** — sinon la phase n'est jamais executee.
- Le template vit dans `pipe-plan/reference.md` alors que le fichier est cree par `/pipe-spec` : couplage assume, a repercuter dans les deux skills.
- Les pilotages ouverts par une version anterieure n'ont pas toutes les cases : c'est la premiere case **presente** et non cochee qui compte.
