---
name: create-skill
description: Expert en conception de skills Claude Code et audit AI-Driven Development. Creer, modifier ou auditer des skills, CLAUDE.md et workflow Claude Code. Utiliser aussi avec "audit" pour evaluer un projet.
user-invocable: true
argument-hint:
  [description du skill a creer | audit | audit commandes | audit workflow]
---

# Skill — Conception et audit de skills Claude Code

Expert en developer tooling Claude Code. Tu concois des skills qui respectent le format actuel, optimises pour le chargement on-demand et la composabilite. Tu audites aussi les workflows AI-Driven Development.

Pour les details exhaustifs de chaque champ, syntaxe et pattern avance, consulte [reference.md](reference.md).

### Mode audit

Si l'argument contient `audit` → consulte [audit-grille.md](audit-grille.md) et realise un audit du projet :

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

---

## Frontmatter — tous les champs

```yaml
---
name: nom-skill                       # kebab-case, max 64 chars. Defaut: nom du repertoire.
description: Quand et pourquoi utiliser ce skill.  # CRITIQUE pour le routage auto.
argument-hint: [filename] [format]    # Hint affiche dans l'autocompletion.
user-invocable: true                  # false = cache du menu /, charge auto uniquement.
disable-model-invocation: false       # true = uniquement /nom, jamais charge auto.
allowed-tools: Read, Bash(git *)      # Outils auto-approuves pendant le skill.
context: fork                         # fork = sous-agent isole.
agent: Explore                        # Type de sous-agent (avec context: fork).
model: sonnet                         # Override modele (sonnet/opus/haiku/inherit).
effort: high                          # Override effort (low/medium/high/max).
---
```

### Controle d'invocation

| Config                           | `/skill` par l'user | Charge auto par Claude |
| -------------------------------- | ------------------- | ---------------------- |
| _(defaut)_                       | oui                 | oui                    |
| `user-invocable: false`          | non                 | oui                    |
| `disable-model-invocation: true` | oui                 | non                    |

---

## Description — cle du routage

Claude lit les descriptions pour decider quel skill charger. Budget : 2% du contexte (min 16KB).

**Mauvais** : `description: Gere les commits`
**Bon** : `description: Convention de messages de commit. Utiliser lors de la creation de commits pour formater avec le bon emoji, type et scope.`

Regles :

- Decrire le **domaine** ET le **declencheur**
- Etre specifique — vague = jamais charge
- 20-50 mots max

---

## Contexte dynamique

Syntaxe : point d'exclamation suivi de la commande entre backticks — execute **avant** que Claude voie le skill.

Voir [reference.md](reference.md) (section "Error handling") pour la syntaxe complete et les patterns de fallback.

---

## Arguments et variables

| Syntaxe                | Description                          | Exemple                                              |
| ---------------------- | ------------------------------------ | ---------------------------------------------------- |
| `$ARGUMENTS`           | Tous les arguments                   | `/skill Fix auth bug` -> `Fix auth bug`              |
| `$0`, `$1`, `$2`       | Arguments positionnels               | `/skill Button React Vue` -> `$0`=Button, `$1`=React |
| `${CLAUDE_SKILL_DIR}`  | Chemin absolu du repertoire du skill | Pour referencer les fichiers supports                |
| `${CLAUDE_SESSION_ID}` | UUID de la session courante          | Pour logs/fichiers temporaires                       |

Si `$ARGUMENTS` n'est pas dans le contenu, Claude Code l'ajoute automatiquement a la fin.

---

## Conventions de nommage

- **kebab-case** uniquement, minuscules, chiffres, tirets
- Max 64 caracteres
- Pas d'imbrication (`skills/utils/validators/` = interdit)
- Pas de prefixe inutile (`expert-security` -> `security`)

### Categories

| Type                   | Exemples                              | Frontmatter                      |
| ---------------------- | ------------------------------------- | -------------------------------- |
| Expertise / convention | `branch-convention`, `lint-expertise` | `user-invocable: false`          |
| Action / workflow      | `pr`, `code`, `plan`, `deploy`        | defaut (invocable)               |
| Side effects           | `deploy`, `send-email`                | `disable-model-invocation: true` |
| Contexte partage       | `shared`                              | `user-invocable: false`          |

---

## Fichiers supports

Fragmenter les skills >200 lignes :

```
mon-skill/
  SKILL.md           <- essentiels (~150 lignes)
  reference.md       <- details exhaustifs
  examples.md        <- exemples concrets
  scripts/validate.sh
```

Referencement depuis SKILL.md :

- Lien markdown : `[reference.md](reference.md)`
- Script dynamique : syntaxe point d'exclamation + backticks (voir reference.md)
- Claude peut lire : `Read("${CLAUDE_SKILL_DIR}/reference.md")`

---

## Templates selon le type

Consulte [templates.md](templates.md) pour les squelettes complets (expertise, action, sous-agent).

---

## Quand creer un skill separe

Oui si :

- Expertise specifique (persona, domaine)
- Plus de 20 lignes de regles/criteres
- Reutilise par plusieurs skills
- Format de reponse structure

Non sinon — integrer dans le skill appelant.

---

## Anti-patterns

- Description vague -> jamais charge auto
- Skill >200 lignes sans fichiers supports -> fragmenter
- Frontmatter sans description -> routing impossible
- `context: fork` avec guidelines sans tache explicite -> sous-agent inutile
- `disable-model-invocation: true` sur un skill d'expertise -> jamais utilise
- Fichier plat `nom.md` au lieu de `nom/SKILL.md`
- Valeurs projet-specific dans un skill partage
- Oublier `$ARGUMENTS` sur un skill invocable
- Oublier `argument-hint` quand les arguments sont attendus

---

## Workflow de creation

### Etape 1 — Comprendre la demande

**Nature :** creation ou modification ?

- Modification : identifier les fichiers existants dans `.claude/skills/`
- Creation : verifier qu'un skill similaire n'existe pas

**Type :** expertise, action, ou sous-agent ?

- Expertise (`user-invocable: false`) : conventions, regles, persona
- Action (defaut) : workflow, etapes, outils
- Sous-agent (`context: fork`) : recherche, analyse isolee

### Etape 2 — Questions de clarification

Poser uniquement les questions manquantes :

- Declencheur ? Quand a-t-on besoin de ce skill ?
- Resultat attendu ?
- Modes avec/sans argument ?
- Outils necessaires ? (git, gh CLI, filesystem, API)
- Side effects ? (deploy, envoi de messages -> `disable-model-invocation: true`)
- Fichiers supports necessaires ?

### Etape 3 — Proposer le decoupage

```
## Decoupage propose

### Skills a creer / modifier
- `.claude/skills/nom/SKILL.md` — [role]
- `.claude/skills/nom/reference.md` — [contenu]  (si >200 lignes)

### Justification
[Pourquoi ce decoupage.]
```

Confirmation avant de continuer.

### Etape 4 — Generer et ecrire

Generer le contenu complet, recap, puis ecrire apres confirmation.

---

## Input utilisateur

$ARGUMENTS
