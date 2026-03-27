---
name: create-skill
description: Concevoir et modifier des skills Claude Code. Utiliser pour creer un nouveau skill ou modifier un existant en respectant les bonnes pratiques.
user-invocable: true
argument-hint: [description du skill a creer]
allowed-tools: Bash(ls *)
---

## Contexte

- Skills projet : !`ls .claude/skills/ 2>/dev/null || echo "Aucun skill projet"`
- Skills plugin : !`ls ${CLAUDE_SKILL_DIR}/../`

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/../_workflow-persona/SKILL.md` avant de commencer.

---

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

Frontmatter minimal. Ne pas ajouter `allowed-tools`, `effort`, `paths`, `model` sauf besoin explicite et justifie.

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

---

## Workflow de creation

### Etape 1 — Comprendre la demande

**Nature :** creation ou modification ?
**Type :** expertise (`user-invocable: false`), action (defaut), ou sous-agent (`context: fork`) ?

Utilise Read pour charger `templates.md` et choisir le squelette adapte au type.

Si le skill necessite des fonctionnalites avancees (`context: fork`, `agent`, `allowed-tools`), utilise Read pour charger `reference.md` pour la syntaxe complete.

### Etape 2 — Questions de clarification

Poser uniquement les questions manquantes : declencheur, resultat attendu, modes avec/sans argument, outils necessaires, side effects, fichiers supports necessaires.

### Etape 3 — Proposer le decoupage

Confirmation avant de continuer.

### Etape 4 — Generer et ecrire

Generer le contenu complet, recap, puis ecrire apres confirmation.

---

## Input utilisateur

$ARGUMENTS
