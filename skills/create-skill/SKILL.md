---
name: create-skill
description: Expert en conception de skills Claude Code et audit AI-Driven Development. Creer, modifier ou auditer des skills, CLAUDE.md et workflow Claude Code. Utiliser aussi avec "audit" pour evaluer un projet.
user-invocable: true
argument-hint:
  [description du skill a creer | audit | audit commandes | audit workflow]
---

### Mode audit

Si l'argument contient `audit` → utilise Read pour charger `audit-grille.md` et realise un audit du projet :

1. Explorer : `.claude/` (skills, settings), `CLAUDE.md`, hooks, conventions
2. Lire chaque skill et verifier la coherence
3. Evaluer selon la grille (7 axes, scoring 1-10)
4. Produire le rapport au format defini dans la grille
5. Proposer des corrections par priorite

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

### Etape 2 — Questions de clarification

Poser uniquement les questions manquantes : declencheur, resultat attendu, modes avec/sans argument, outils necessaires, side effects, fichiers supports necessaires.

### Etape 3 — Proposer le decoupage

Confirmation avant de continuer.

### Etape 4 — Generer et ecrire

Generer le contenu complet, recap, puis ecrire apres confirmation.

---

## Input utilisateur

$ARGUMENTS
