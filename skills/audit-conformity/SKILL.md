---
name: audit-conformity
description: Auditer la conformite du code a un document de reference (spec, regle, skill, CLAUDE.md) et planifier la remediation.
argument-hint: [document de reference] [perimetre optionnel]
---

Ce skill repond a une seule question : **ce que ce document affirme est-il vrai partout dans le code ?** Le document est la loi, le code est le prevenu — jamais l'inverse. Un ecart se tranche a la fin, pas pendant l'audit.

Il ne modifie aucune ligne de code. Il produit un rapport de conformite, un plan de remediation en lots, et propose leur mise en place dans le pipeline.

## Etape 0 — Verifications

- [ ] Un document de reference est identifie et lisible
- [ ] Utilise Read pour charger `.claude/skills/workflow-config/SKILL.md` s'il existe (stack et conventions du projet : ils cadrent le perimetre)

Sans argument, ou si le document est ambigu, inventorie les candidats (`docs/specs/*.md`, `CLAUDE.md`, `.claude/skills/*/SKILL.md`, `skills/*/SKILL.md`) et demande lequel auditer. **N'en audite jamais plusieurs a la fois** : les grilles se melangeraient et le rapport deviendrait illisible.

Le second argument, optionnel, restreint le perimetre (`src/auth/`, `**/*.tsx`). Sans lui, le perimetre est le projet entier.

## Etape 1 — Extraire la grille de regles (pause)

C'est l'etape qui decide de la valeur de tout le reste : des auditeurs lances sur une interpretation fausse produisent un rapport faux, avec conviction.

Lis le document en entier, puis convertis-le en **regles atomiques numerotees** `R1..Rn`. Le critere d'atomicite : un auditeur doit pouvoir repondre **oui ou non** en regardant un fichier, sans rien interpreter. Les criteres de decoupage, le format de la grille et le tri normatif/non-verifiable sont dans `${CLAUDE_SKILL_DIR}/reference.md`, section « Extraction de la grille ».

Affiche la grille et **attends validation**. L'utilisateur corrige ici les regles mal lues, retire celles qui ne s'appliquent plus, ajoute l'implicite que le document ne dit pas. Sans cette pause, l'audit est une opinion.

## Etape 2 — Cartographier le perimetre

Etablis la liste des fichiers concernes (Glob), exclusions comprises : dependances, artefacts de build, fichiers generes, lockfiles, `.git`.

Decoupe-la en **zones equilibrees** par repertoire ou module — jamais par regle : un auditeur qui ne connait qu'une regle rate les interactions entre elles, et relit le meme fichier n fois.

| Fichiers dans le perimetre | Zones (auditeurs) |
|---|---|
| < 30 | 2 |
| 30 – 150 | 3 a 4 |
| > 150 | 5 a 6 |

Au-dela de 6 zones, elargis chaque zone plutot que le nombre d'agents : la synthese devient le goulot.

Annonce en une ligne : `Perimetre — N fichiers · G zones · R regles`.

## Etape 3 — Auditer (fan-out)

Lance **un sub-agent par zone**, tous dans **un seul message** pour qu'ils tournent en parallele. Outil Agent, type `Explore` (read-only : un auditeur ne corrige rien).

Chaque agent recoit la **grille entiere** et **sa zone seule**. Le protocole de l'auditeur — obligation de preuve `fichier:ligne`, verdict par regle, interdiction de signaler du gout — est dans `${CLAUDE_SKILL_DIR}/reference.md`, section « Protocole de l'auditeur » : il s'adresse aux sub-agents, ne le charge jamais dans le contexte principal.

```
Utilise Read pour charger `[chemin absolu de ${CLAUDE_SKILL_DIR}/reference.md]` et applique la section "Protocole de l'auditeur".

Document de reference : [chemin]
Ta zone : [liste des fichiers ou glob]
Grille a verifier :
[grille R1..Rn validee a l'etape 1]
```

## Etape 4 — Refuter (contre-audit)

Une violation non refutee est une violation supposee. Regroupe les constats par regle, et lance **un refutateur par lot** (Agent, `Explore`, en parallele) — pas un par violation, le cout exploserait sans gain.

Sa consigne : **detruire** le constat, pas le confirmer. Quatre sorties possibles — faux positif, exception legitime, regle mal interpretee, **la regle elle-meme est mauvaise**. En cas de doute, le defaut est `refute`. Protocole complet dans `${CLAUDE_SKILL_DIR}/reference.md`, section « Protocole du refutateur ».

Les constats refutes ne disparaissent pas : ils vont dans une section a part du rapport, avec le motif. C'est ce qui evite de les redecouvrir au prochain audit.

## Etape 5 — Chasser les angles morts

Un audit se juge autant sur ce qu'il n'a pas vu. Lance **un seul** sub-agent critique (Agent, `Explore`), avec la grille, la carte des zones et les rapports agreges. Sa question : quelle regle n'a jamais ete reellement evaluee, quelle zone n'a ete que survolee, quel faux negatif est probable ? Protocole dans `${CLAUDE_SKILL_DIR}/reference.md`, section « Protocole du critique ».

S'il remonte des trous, lance **une** salve ciblee d'auditeurs dessus, puis passe a la suite. Une seule relance : au-dela, c'est la grille qu'il faut revoir, pas le nombre d'agents.

## Etape 6 — Rapport de conformite

Ecris `.claude/audits/audit-<slug>.md` (cree le repertoire si besoin, verifie qu'il est dans `.gitignore` — un rapport d'audit est ephemere, il n'a pas a etre versionne).

Le format du rapport est dans `${CLAUDE_SKILL_DIR}/reference.md`, section « Format du rapport ». A l'ecran, n'affiche que la synthese dense : le tableau des regles avec leur verdict, et le decompte des violations confirmees par severite. Le detail est dans le fichier, l'utilisateur l'ouvre s'il le veut.

Conformite totale est un **resultat valide** : le dire en une ligne, ecrire le rapport, et s'arreter la.

## Etape 7 — Arbitrage humain (pause)

Parcours les violations confirmees, par severite. Pour chacune, trois issues — et la troisieme compte autant que les autres :

- **Corriger le code** — l'ecart part au plan de remediation
- **Amender le document** — c'est la regle qui est fausse, obsolete ou trop large ; la correction va dans le document de reference, pas dans le code
- **Accepter l'ecart** — avec sa raison, consignee dans le rapport ; sans raison ecrite, il reviendra a chaque audit

Ne corrige rien ici, meme trivial : ce skill audite, il n'edite pas. Attends une decision explicite par violation.

## Etape 8 — Plan de remediation et mise en place

Regroupe les ecarts a corriger en **lots coherents** — par zone du code ou par regle, selon ce qui produit le moins de conflits entre eux — ordonnes par severite puis par dependance. Format dans `${CLAUDE_SKILL_DIR}/reference.md`, section « Plan de remediation ».

Chaque lot recoit une route, selon la regle de tri du projet (comportement a valider → cycle ; rien a tester → voie rapide) :

| Nature du lot | Route |
|---|---|
| Mecanique, aucun comportement touche | `/pipe-commit` (voie rapide) |
| Comportement a valider, feature existante | `/pipe-spec` puis le cycle |
| Chantier a suivre dans le tracker | `/create-issue` |

Puis propose la mise en place et **attends confirmation** :

```
Plan — N lots · [x] voie rapide, [y] cycle, [z] issues.
Je mets en place le lot 1 ([route]) ?
```

Enchaine lot par lot, jamais tous d'un coup : chaque lot est un travail complet qui merite son propre cycle.

---

## Input utilisateur

$ARGUMENTS
