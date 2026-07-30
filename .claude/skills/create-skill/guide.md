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

Frontmatter minimal. Ne pas ajouter `allowed-tools`, `effort`, `paths` sauf besoin explicite et justifie. Ne pas utiliser `model` : le champ bascule reellement le modele pour le reste du tour (auto-invocation comprise) et peut retrograder une session qui tourne sur un modele superieur (voir reference.md section `model`).

## Description — cle du routage

Claude lit les descriptions pour decider quel skill charger.

**Mauvais** : `description: Gere les commits`
**Bon** : `description: Convention de messages de commit. Utiliser lors de la creation de commits pour formater avec le bon emoji, type et scope.`

**Plafond : 130 caracteres.** La description est le poste le plus cher du plugin. Le corps d'un `SKILL.md` n'est charge qu'a l'invocation ; la description, elle, est injectee dans le prompt systeme de **chaque session de chaque projet** ou le plugin est actif — y compris les sessions qui n'invoqueront jamais ce skill. Retirer 100 caracteres d'une description vaut donc plus que retirer 1 000 caracteres d'un `reference.md`.

`.claude/scripts/check-skills.sh` verifie ce plafond. C'est de l'outillage local a ce repo, non distribue : aucun skill du pipeline ne peut l'appeler — le lancer a la main apres toute modification de skill.

**Regle de redaction : verbe + objet + declencheur, rien d'autre.** Surtout pas l'enumeration des etapes du skill ni des sections du document qu'il produit — c'est exactement ce qui fait deraper les descriptions, et cela n'apporte aucun pouvoir de declenchement : Claude route sur le domaine et le declencheur, jamais sur un sommaire.

## Fichiers supports

**Declencheur de delegation : ~150 lignes.** Ce n'est pas un plafond dur et le depasser n'est pas une faute — c'est le moment de se demander ce qui n'a rien a faire dans le `SKILL.md`. Le corps d'un skill n'est charge qu'a l'invocation : sa taille coute a l'usage, jamais en permanent. Le vrai risque d'un fichier long n'est donc pas le nombre de tokens mais la **dilution de l'attention** entre la premiere et la derniere instruction — risque d'autant plus reel quand une pause humaine coupe le fichier en son milieu. Un skill de 200 lignes qui a delegue son detail se tient ; un skill de 120 lignes qui melange procedure et tables de reference, non.

Quoi sortir :

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
argument-hint: "[param]"              # [SI le skill accepte des arguments]
user-invocable: false                 # [SI skill expertise (non-invocable)]
context: fork                         # [SI isolation sub-agent necessaire]
agent: Explore | Plan                 # [SI fork + read-only souhaite]
allowed-tools: Bash(git *), Bash(ls *)  # [SI contexte dynamique avec !`cmd`]
---

## Contexte                           # [SI des donnees d'environnement conditionnent les etapes]

- Info1 : !`commande1`
- Info2 : !`commande2`
# Chaque skill definit ses propres commandes selon ses besoins.
# Commandes simples uniquement — pas de redirections (2>/dev/null), pipes (|), ni operateurs (||, &&), ni single quotes ('...').
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
| Non-invocable (expertise) | `user-invocable: false`, pas d'etapes numerotees |
| Des donnees d'environnement conditionnent les etapes | `## Contexte` avec `!`cmd`` en tete |
| Isolation sub-agent | `context: fork` |
| Fork read-only | Ajouter `agent: Explore` ou `agent: Plan` |
| A des prerequis | `## Etape 0 — Verifications` |
| Pipeline sequentiel | Derniere etape = transition vers le skill suivant |
| Contexte dynamique `!`cmd`` | `allowed-tools` avec les patterns Bash necessaires (ex: `Bash(git *)`, `Bash(gh *)`, `Bash(ls *)`) |
| Depasse ~150 lignes | Se demander quoi deleguer dans `reference.md` |

## Grammaire de sortie

Ce que le skill affiche a l'utilisateur est aussi une interface. Elle est **dense par defaut** : un skill qui deroule des paragraphes fait relire a chaque invocation ce qui tenait sur trois lignes.

- **Une ligne de statut en tete**, jamais un en-tete suivi d'un blanc puis d'une metrique : `**Dev termine — PROJ-42** · tests ✅ 34 passent`
- **Un fait par ligne**, libelle en gras puis tiret cadratin : `**Impact** — ...`. Les questions ouvertes (`❓ C'est grave ?`) et les listes a deux niveaux sont du remplissage
- **Ne jamais afficher ce que l'utilisateur a deja sous les yeux** : sortie d'une commande, contenu d'un fichier qu'on vient de lui montrer, recap deja affiche a une etape precedente
- **Aucune phrase d'introduction ni de transition** (« Voici… », « Je vais maintenant… », « Parfait, passons a… »)
- **Tableau des qu'il y a trois colonnes de faits**, liste a puces sinon, prose jamais
- **Fin d'etape = une ligne** : `Suite : <geste> — /commande`. Un bloc de trois lignes pour dire quoi taper est deux lignes de trop
- Le detail que l'utilisateur veut vraiment, il le demande. L'afficher par defaut le fait payer a tout le monde

## Regles strictes

- `## Contexte` avec `!`cmd`` en tete **quand** des donnees d'environnement conditionnent les etapes — section optionnelle, la majorite des skills n'en a pas besoin. Un contexte dynamique qu'aucune etape n'exploite coute une commande shell a chaque invocation pour rien
- Commandes simples dans `!`cmd`` — pas de redirections, pipes, operateurs, ni single quotes
- Ordre : contexte dynamique → etapes
- Les donnees pre-chargees dans `## Contexte` ne doivent pas etre re-cherchees par les etapes. Claude peut utiliser des outils externes uniquement pour des donnees absentes du contexte pre-charge, et seulement si le skill le demande explicitement.
- Frontmatter minimal : pas de `effort`, `paths`, `model` sauf besoin explicite
- `allowed-tools` obligatoire si le skill utilise `!`cmd`` — declarer les commandes du contexte dynamique pour eviter les prompts de permission
- Confirmation obligatoire avant toute action irreversible : `"Je [action] ?"`
- Description : 130 caracteres max, format verbe infinitif + objet + declencheur — jamais l'enumeration des etapes ni des sections produites (verifie par `.claude/scripts/check-skills.sh`)
- Au-dela de ~150 lignes, deleguer le detail dans `reference.md` — declencheur, pas plafond
- Formulation `utilise Read pour charger` (jamais "lis", "consulte", "charge")
