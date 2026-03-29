# Guide de conception des skills

## Structure obligatoire

Chaque skill est un **repertoire** avec `SKILL.md` comme point d'entree :

```
.claude/skills/
  nom-skill/
    SKILL.md              <- obligatoire
    reference.md          <- fichiers supports optionnels
    scripts/helper.sh
```

Un fichier plat `.claude/skills/nom.md` n'est **pas valide**.

## Frontmatter essentiel

```yaml
---
name: nom-skill                       # kebab-case, max 64 chars
description: Quand et pourquoi utiliser ce skill.  # CRITIQUE pour le routage auto
argument-hint: [filename] [format]    # Hint affiche dans l'autocompletion
user-invocable: false                 # uniquement si skill expertise (non-invocable)
context: fork                         # uniquement si isolation sub-agent necessaire
agent: Explore | Plan                 # uniquement si fork + read-only
---
```

Frontmatter minimal. Ne pas ajouter `allowed-tools`, `effort`, `paths` sauf besoin explicite et justifie. Ajouter `model` pour indiquer le tier recommande (voir reference.md section `model`).

## Description — cle du routage

Claude lit les descriptions pour decider quel skill charger.

**Mauvais** : `description: Gere les commits`
**Bon** : `description: Convention de messages de commit. Utiliser lors de la creation de commits pour formater avec le bon emoji, type et scope.`

Regles : decrire le **domaine** ET le **declencheur**, 20-50 mots max.

## Fichiers supports

Fragmenter les skills >150 lignes :

- `reference.md` — details exhaustifs, tables, exemples
- `scripts/` — scripts utilitaires

Referencement : lien markdown `[reference.md](reference.md)` ou `Read("${CLAUDE_SKILL_DIR}/reference.md")`.

## Regle de chargement de fichiers

Toute instruction demandant a Claude de charger un fichier (skill, reference, config) doit utiliser la formulation **`utilise Read pour charger`**.

Ne jamais utiliser : `Lis`, `Consulte`, `Charge`, `Regarde`, ou tout autre verbe implicite. Ces formulations ne garantissent pas l'utilisation explicite de l'outil Read et cassent le progressive disclosure.

## Quand creer un skill separe

Oui si : expertise specifique, plus de 20 lignes de regles, reutilise par plusieurs skills, format de reponse structure.

Non sinon — integrer dans le skill appelant.

## Pattern sub-agents pour analyse multi-fichiers

Quand un skill doit analyser ou auditer **plus de 3 fichiers** (skills, configs, modules), ne pas tout charger dans le contexte principal. Utiliser des sub-agents pour decouper le travail :

1. **Le skill principal orchestre** : collecte la liste des fichiers, dispatche vers des sub-agents, agregue les resultats
2. **Chaque sub-agent analyse un fichier ou groupe** : charge le fichier, applique les criteres, retourne un rapport partiel
3. **Le skill principal synthetise** : combine les rapports partiels en rapport final

### Quand appliquer

- Skills `audit-*` qui evaluent plusieurs fichiers/skills
- Skills d'analyse qui parcourent un repertoire entier
- Toute operation de review multi-fichiers

### Comment implementer

Le skill principal utilise l'outil Agent avec `subagent_type: "Explore"` (read-only) ou `"general-purpose"` (si ecriture necessaire) pour chaque fichier. Les sub-agents tournent en parallele quand les analyses sont independantes.

---

## Template canonique unifie

Un seul template. Les sections conditionnelles sont marquees `[SI condition]`.

```yaml
---
name: prefixe-nom
description: [Verbe infinitif] [objet]. [Contexte/contrainte]. Utiliser [quand].
model: sonnet                         # opus si complexe, haiku si simple
argument-hint: "[param]"              # [SI le skill accepte des arguments]
user-invocable: false                 # [SI skill expertise (non-invocable)]
context: fork                         # [SI isolation sub-agent necessaire]
agent: Explore | Plan                 # [SI fork + read-only souhaite]
allowed-tools: Bash(git *), Bash(ls *)  # [SI contexte dynamique avec !`cmd`]
---

## Contexte                           # obligatoire (optionnel si expertise)

- Info1 : !`commande1`
- Info2 : !`commande2`
# Chaque skill definit ses propres commandes selon ses besoins.
# Commandes simples uniquement — pas de redirections (2>/dev/null), pipes (|), ni operateurs (||, &&), ni single quotes ('...').

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/../_workflow-persona/SKILL.md` avant de commencer.
                                      # [SI skill pipeline — pas expertise, pas fork]
---

## Etape 0 — Verifications            # [SI prerequis]

Avant de commencer, verifie :

- [ ] Prerequis 1
- [ ] Prerequis 2

Si une verification echoue, signale-le clairement et arrete-toi.

## Etape 1 — [Action principale]

...

## Etape N — [Transition]             # [SI pipeline, guide vers le skill suivant]

---

## Input utilisateur                  # [SI user-invocable]

$ARGUMENTS
```

## Conditions d'inclusion

| Condition | Sections / champs concernes |
|---|---|
| Tout skill | `model` avec le tier recommande (`opus`, `sonnet`, `haiku`) |
| Accepte des arguments | `argument-hint` + `## Input utilisateur` + `$ARGUMENTS` |
| Non-invocable (expertise) | `user-invocable: false`, pas d'etapes numerotees, `## Contexte` optionnel |
| Isolation sub-agent | `context: fork`, pas de chargement persona |
| Fork read-only | Ajouter `agent: Explore` ou `agent: Plan` |
| A des prerequis | `## Etape 0 — Verifications` |
| Pipeline sequentiel | Derniere etape = transition vers le skill suivant |
| Contexte dynamique `!`cmd`` | `allowed-tools` avec les patterns Bash necessaires (ex: `Bash(git *)`, `Bash(gh *)`, `Bash(ls *)`) |
| Depasse ~100 lignes | Deleguer le detail dans `reference.md` |

## Regles strictes

- `## Contexte` avec `!`cmd`` en tete de chaque skill (optionnel pour expertise)
- Commandes simples dans `!`cmd`` — pas de redirections, pipes, operateurs, ni single quotes
- Ordre : contexte dynamique → persona (Read) → etapes
- Les donnees pre-chargees dans `## Contexte` ne doivent pas etre re-cherchees par les etapes. Claude peut utiliser des outils externes uniquement pour des donnees absentes du contexte pre-charge, et seulement si le skill le demande explicitement.
- Frontmatter minimal : pas de `effort`, `paths` sauf besoin explicite
- Chaque skill doit inclure `model` avec le tier recommande (`opus`, `sonnet`, `haiku`)
- `allowed-tools` obligatoire si le skill utilise `!`cmd`` — declarer les commandes du contexte dynamique pour eviter les prompts de permission
- Confirmation obligatoire avant toute action irreversible : `"Je [action] ?"`
- Description : 20-50 mots, format verbe infinitif + objet + declencheur
- Formulation `utilise Read pour charger` (jamais "lis", "consulte", "charge")
