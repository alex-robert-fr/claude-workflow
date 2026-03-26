# Templates selon le type de skill

## Expertise (`user-invocable: false`)

```yaml
---
name: mon-domaine
description: Description precise du domaine et quand l'utiliser.
user-invocable: false
---

## Regles / Criteres
[Par theme, hierarchises par importance.]

## Format de reponse
[Template attendu.]
```

## Action (`user-invocable: true`)

```yaml
---
name: mon-action
description: Description precise de l'action et quand l'utiliser.
argument-hint: [argument attendu]
allowed-tools: Read, Bash(git *)
---

## Contexte
- Info : !`commande`

## Etape 0 — Verifications
Verifier les preconditions. Arreter si echec.

## Etape 1 — [Action]
[Quoi, comment, quels outils]

## Etape N — Confirmation
Recap + confirmation avant toute action irreversible.

## Input utilisateur
$ARGUMENTS
```

## Sous-agent isole (`context: fork`)

```yaml
---
name: mon-research
description: Description de la recherche.
context: fork
agent: Explore
allowed-tools: Read, Grep, Glob, Bash(gh *)
---

## Tache
[Instructions explicites — un sous-agent a besoin d'une TACHE, pas que des guidelines.]

$ARGUMENTS
```
