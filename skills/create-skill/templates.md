# Template canonique unifie

Un seul template. Les sections conditionnelles sont marquees `[SI condition]`.

```yaml
---
name: prefixe-nom
description: [Verbe infinitif] [objet]. [Contexte/contrainte]. Utiliser [quand].
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
- Frontmatter minimal : pas de `effort`, `paths`, `model` sauf besoin explicite
- `allowed-tools` obligatoire si le skill utilise `!`cmd`` — declarer les commandes du contexte dynamique pour eviter les prompts de permission
- Confirmation obligatoire avant toute action irreversible : `"Je [action] ?"`
- Description : 20-50 mots, format verbe infinitif + objet + declencheur
- Formulation `utilise Read pour charger` (jamais "lis", "consulte", "charge")
