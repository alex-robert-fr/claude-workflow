## Philosophie de découpage

### Ce qui va dans une commande

La commande est le **chef d'orchestre**. Elle définit :

- Le flux d'exécution (étapes, ordre, conditions)
- Les modes de fonctionnement (avec/sans argument)
- Ce qu'on fait avant d'agir (récap, confirmation)
- Les appels aux outils (MCP, filesystem, git...)
- Le format de sortie utilisateur

Une commande ne contient **pas** de savoir métier. Elle délègue ça au skill.

### Ce qui va dans un skill

Le skill est la **mémoire experte**. Il contient :

- La persona et la posture (qui je suis, comment je pense)
- Les critères d'évaluation détaillés
- Les règles métier, patterns, anti-patterns
- Le format de rapport ou de réponse attendu
- Les exemples concrets

Un skill ne contient **pas** de logique d'exécution. Il est lu, pas exécuté.

### Règle de décision

> Si tu l'enlèves du skill et que la commande marche encore → c'était du skill.
> Si tu l'enlèves de la commande et que le flux est cassé → c'était de la commande.

---

## Quand créer un skill séparé

Crée un skill dédié si la commande :

- Incarne une **expertise** spécifique (persona, domaine de connaissance)
- Contient **plus de 20 lignes** de règles métier ou de critères
- Sera **réutilisée** par plusieurs commandes
- Nécessite un **format de réponse** complexe et structuré

Sinon, intègre directement dans la commande.

---

## Structure d'une bonne commande

```markdown
# Commande /nom

[Description courte du rôle de la commande]

## Étape 1 — [Action concrète]

[Ce que la commande fait, comment, avec quels outils]

## Étape 2 — [Action concrète]

...

## Étape N — Confirmation avant écriture/création

Toujours afficher un récap et demander confirmation avant :

- Écriture de fichiers
- Appels API (GitHub, etc.)
- Toute action irréversible

---

## Input utilisateur

$ARGUMENTS
```

## Structure d'un bon skill

```markdown
# Skill — [Nom du domaine]

## Identité

[Persona en 2-3 phrases. Qui tu es, comment tu penses, ce que tu priorises.]

## Ce que tu évalues / Ce que tu sais faire

[Critères détaillés, organisés par thème. Hiérarchisés par importance.]

## Format de réponse

[Template markdown du rapport ou de la réponse attendue.]
```

---

## Conventions de nommage et structure

```
.claude/
  commands/
    nom-commande.md        ← kebab-case, verbe ou nom court
  skills/
    nom-skill.md           ← kebab-case, domaine ou concept
    groupe/
      shared.md            ← contexte commun à plusieurs skills du groupe
      skill-specifique.md
```

### Nommage

- Commandes : verbe court ou nom d'action (`review`, `plan`, `cmd`, `issue`)
- Skills : domaine ou persona (`security`, `archi`, `shared`)
- Pas de préfixe inutile (`expert-security.md` → `security.md`)

### Référence aux skills dans une commande

Toujours indiquer à Claude de **lire le fichier** avant d'agir :

```markdown
Commence par lire ces fichiers dans l'ordre :

1. `.claude/skills/shared.md`
2. `.claude/skills/mon-skill.md`
```

---

## Modes de fonctionnement

La plupart des commandes gagnent à supporter deux modes :

```markdown
### Si aucun argument — Mode [action par défaut]

[Ce que fait la commande sans argument : review globale, action complète...]

### Si un argument — Mode [action ciblée]

[Ce que fait la commande avec un argument : question précise, cible spécifique...]
```

---

## Anti-patterns à éviter

- ❌ Commande trop longue qui mélange flux + règles métier
- ❌ Skill sans persona claire → réponses génériques
- ❌ Confirmation absente avant une action irréversible
- ❌ `$ARGUMENTS` absent ou mal placé (doit toujours être à la fin)
- ❌ Skill qui duplique le contenu de `shared.md`
- ❌ Commande qui hardcode des valeurs qui appartiennent au skill
- ❌ Trop de commandes pour la même chose → préférer les modes
