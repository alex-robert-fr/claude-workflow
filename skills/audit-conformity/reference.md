# Audit de conformité — grille, rapport, plan de remédiation

Chargé par `/audit-conformity` (contexte principal). Les protocoles des auditeurs, réfutateurs et du critique sont les agents `auditor`, `refuter` et `gap-finder` du plugin.

## Extraction de la grille

Une règle est atomique quand un auditeur peut y répondre par oui ou non en regardant un fichier, sans interpréter. Ce qui demande un jugement se découpe jusqu'à ce que ce soit vrai, ou sort de la grille.

- Une phrase contenant « et », « sauf », « sauf si » porte presque toujours plusieurs règles : les séparer
- Une règle en « bien », « proprement », « au mieux » n'est pas vérifiable : la traduire en critère observable, ou la ranger dans les intentions
- Une règle avec exception explicite garde son exception dans l'énoncé, sinon les exceptions remonteront comme violations

Chaque règle : énoncé impératif en une phrase, portée (`tous`, une extension, un répertoire), citation source.

```
| # | Règle | Portée | Source |
|---|---|---|---|
| R1 | Chaque skill est un répertoire `nom/SKILL.md` avec frontmatter | `skills/**` | « Chaque skill est un répertoire… » |
```

Sous la grille, les intentions non vérifiables (« rester concis », « penser au lecteur ») : elles disent ce que l'audit ne couvrira pas, et signalent parfois que le document mérite d'être précisé.

## Format du rapport

Fichier `.claude/audits/audit-<slug>.md` :

```markdown
# Audit de conformité — <document de référence>

Périmètre : N fichiers · G zones · R règles · <date>

## Verdict par règle

| # | Règle | Verdict | Violations |
|---|---|---|---|
| R1 | <énoncé court> | ✅ conforme | — |
| R2 | <énoncé court> | ❌ violée | 3 (1 bloquant) |
| R3 | <énoncé court> | — sans objet | — |

## Violations confirmées

### R2 — <énoncé>

- `src/auth/session.ts:41` — BLOQUANT · <écart en une phrase>
  > <ligne fautive citée>

## Constats réfutés

| Règle | Fichier | Motif |
|---|---|---|
| R5 | `src/legacy/pdf.ts:12` | Exception légitime : module isolé, exclu par la règle |

## Écarts acceptés

| Règle | Fichier | Raison (décidée le <date>) |
|---|---|---|

## Non couvert

- <intentions non vérifiables de la grille>
- <trous signalés par le critique et non résolus>
```

La section « Constats réfutés » évite que le prochain audit remonte les mêmes faux positifs et les fasse réarbitrer.

## Plan de remédiation

Un lot est un travail complet et livrable seul : il ne laisse pas le projet à moitié conforme à une règle.

```markdown
## Lot 1 — <intitulé> · <route>

- Règles : R2, R7
- Fichiers : N (`src/auth/`)
- Sévérité max : BLOQUANT
- Dépend de : —
```

- Par règle quand la correction est mécanique et répétée (même geste sur N fichiers) ; par zone quand elle demande de comprendre le module — sinon le même fichier est repris dans trois lots
- Ordre : sévérité, puis dépendance (un lot qui déplace des fichiers passe avant celui qui les modifie)
- Plus de ~15 fichiers → redécouper, il ne sera pas relisible
