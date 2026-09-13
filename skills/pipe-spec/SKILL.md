---
name: pipe-spec
description: Cadrer une feature dans une spec durable et versionnee (docs/specs/) avant le dev. Sans argument, inventorier l'existant.
argument-hint: [cle JIRA, numéro issue, URL, nom de feature, ou rien pour inventorier l'existant]
---

**Une spec dit ce que la feature est et pourquoi, jamais comment on va la coder** : si une phrase devient fausse une fois le ticket mergé, elle n'y a pas sa place. Elle vit dans `docs/specs/<feature>.md`, versionnée, alimentée par plusieurs tickets, et n'est jamais écrite sans validation humaine.

## Étape 0 — Ticket ou feature

- Aucun argument → mode inventaire : Read `${CLAUDE_SKILL_DIR}/inventaire.md`, puis reprends à l'étape 2 avec la feature choisie (pas de ticket, pas de pilotage)
- Nom de feature libre (`export CSV`) → usage autonome : étape 1 directement, sans pilotage
- Ticket → Read `${CLAUDE_SKILL_DIR}/../pipe-plan/reference.md`, section « Detection de l'environnement et recuperation du ticket »

## Étape 1 — Trier

- Feature (un comportement que le produit rend, avec un périmètre) → spec
- Typo, libellé, config triviale, bump, bug sans règle métier → pas de spec : une ligne, renvoi vers `/pipe-commit` (voie rapide) ou `/pipe-plan`
- Ticket technique (refactor, migration) → met à jour une spec existante (fonctionnement technique, points d'entrée, décisions), n'en crée pas — sauf s'il expose un nouveau contrat observable (endpoint, commande, format) : proposer, laisser l'utilisateur trancher
- Ticket d'investigation (label `question`/`spike`/`investigation`, titre en « Investiguer », « Explorer », « Comparer ») → Read `${CLAUDE_SKILL_DIR}/spike.md` et applique-le en plus des étapes ci-dessous

## Étape 2 — Identifier la feature, ouvrir le pilotage

- Read `docs/specs/README.md` (absent → première spec) : correspondance évidente → mise à jour ; aucune → création ; ambiguë → propose, demande confirmation. Enrichir une spec existante plutôt qu'en créer une quasi-doublon
- Annonce en une ligne : création ou mise à jour, quel fichier
- Ticket seulement : pilotage `.claude/plans/plan-<identifiant>.md` — existant → le lire, reprendre là où il en est ; sinon le créer depuis `${CLAUDE_SKILL_DIR}/../../shared/pilotage-template.md` avec l'en-tête seul (Ticket, Spec visée, État vierge) ; `.claude/plans/` dans `.gitignore`

## Étape 3 — Explorer

- Mise à jour : lis la spec en entier, elle cible l'exploration
- Création : Read, Glob, Grep autour de la feature — existant, patterns, modules touchés
- But : de vraies questions pour l'étape 4, et de quoi remplir Fonctionnement technique, Dépendances, Points d'entrée

## Étape 4 — Cadrer avec l'utilisateur (Q/R, plusieurs salves)

Registres, par importance : intention (problème, pour qui, à quoi on reconnaît que c'est réussi) ; philosophie (le principe qui tranchera les arbitrages) ; périmètre et hors-scope ; règles métier et cas limites.

- Chaque question s'appuie sur l'exploration et propose des options concrètes
- Aucune question d'implémentation (nommage, découpage, où vit la logique) : c'est `/pipe-plan`
- Mise à jour : ne questionne que le delta du ticket
- Chaque arbitrage rejoint la section Décisions, avec sa raison
- Sur une feature existante, le code dit le comportement, jamais le pourquoi ni le hors-scope : s'ils restent vides, le dire plutôt que meubler

## Étape 5 — Rédiger

Read `${CLAUDE_SKILL_DIR}/template.md` (template et règles de rédaction). Écris ou mets à jour `docs/specs/<feature>.md` (kebab-case, sans numéro de ticket).

- Mise à jour : les sections concernées seulement ; Décisions s'ajoute, ne se réécrit pas — une décision contredite est conservée et marquée remplacée, avec la raison ; ticket ajouté dans l'en-tête
- Puis l'index `docs/specs/README.md` selon `${CLAUDE_SKILL_DIR}/index-format.md` (Read)

## Étape 6 — Relecture indépendante

Lance l'agent `claude-workflow:spec-critic` (Agent tool) avec le chemin de la spec et celui de `${CLAUDE_SKILL_DIR}/template.md`. Applique les corrections retenues, puis vérifie : 40–80 lignes, sections obligatoires présentes (En une phrase, Comportement attendu, Points d'entrée), sections faibles supprimées, chemins des points d'entrée réels ou `(à créer)`.

## Étape 7 — Validation humaine (pause)

Présente la spec (ou le diff des sections touchées en mise à jour). Itère jusqu'à accord explicite. Alors seulement, si un pilotage existe : coche `Spec a jour` et renseigne le chemin dans sa section Spec.

## Étape 8 — Suite

- Cycle : `Spec [créée | mise à jour] docs/specs/<feature>.md · pilotage .claude/plans/plan-<id>.md. Suite : /pipe-plan <ticket> (cette session) ; /pipe-ship <ticket> reprend à tout moment.`
- Autonome : `Spec [créée | mise à jour] — committée avec le prochain changeset (/pipe-commit).`
- Inventaire : ajoute `Rattrapage : N spécifiée(s) sur M repérées. Suivante : [nom] — relance /pipe-spec sans argument.`
- Ticket d'investigation : la suite est dans `${CLAUDE_SKILL_DIR}/spike.md`

---

## Input utilisateur

$ARGUMENTS
