---
name: pipe-plan
description: Co-construire le plan d'un ticket (Jira, GitHub, GitLab, Gitea) par questions/reponses, et tenir le pilotage.
argument-hint: [cle JIRA, numéro issue, URL ou texte]
---

## Étape 0 — Détecter l'environnement et récupérer le ticket

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/reference.md` — il contient la procédure de detection et de recuperation du ticket, les critères de classification et le template de plan.

Applique sa section « Detection de l'environnement et recuperation du ticket » : plateforme git, tracker externe, verifications, formes de l'argument, hierarchie JIRA.

## Étape 1 — S'assurer que la feature est specifiee

Le plan decoule du cadrage : avant de planifier le **comment**, le **quoi** et le **pourquoi** doivent être poses.

Consulte l'index `docs/specs/README.md` :

- **Spec a jour pour la feature concernee** → continue, et charge-la a l'exploration (étape 4)
- **Spec absente ou obsolete** (le ticket change le comportement, le perimetre ou une decision structurante) → annonce-le et lance `/pipe-spec` en chargeant `${CLAUDE_SKILL_DIR}/../pipe-spec/SKILL.md`, puis reviens ici une fois la spec validee
- **Le ticket ne concerne aucune feature** (voie rapide, correction sans règle métier, chantier purement outillage) → note `sans objet` dans le pilotage et continue
- **Le ticket est une question ouverte** (label `question`, `spike` ou `investigation`, titre en « Investiguer », « Explorer ») → il n'est pas planifiable : rien a decouper tant que la reponse n'existe pas. Renvoie vers `/pipe-spec`, qui le traite en ticket d'investigation (livrable = spec, code d'exploration jetable), et arrete-toi la

Si le projet n'a pas de repertoire `docs/specs/`, ne bloque pas : propose la creation de la spec via `/pipe-spec`, et continue sans si l'utilisateur decline.

## Étape 2 — Classifier le ticket

Determine la nature du ticket selon les critères de `${CLAUDE_SKILL_DIR}/reference.md` :

- **Technique** : dette, refactoring, perf, infra, CI/CD, migration, tooling
- **Métier** : fonctionnalité utilisateur, user story, besoin business, UX/UI
- **Mixte** : besoin métier qui implique des changements techniques significatifs

Annonce la classification a l'utilisateur — elle oriente le plan.

## Étape 3 — Evaluer la taille et decomposer si nécessaire

Evalue si le ticket est implementable en un seul cycle (tests → dev → review). Consulte les critères de decomposition dans `${CLAUDE_SKILL_DIR}/reference.md`.

**Si le ticket est trop petit pour le cycle** :

- Condition : aucun comportement a tester (typo, libelle, casse, config triviale, bump mineur de dependance)
- Action : propose la **voie rapide** — pas de pilotage, pas de tests dedies (correction directe + `/pipe-commit` mode simple, micro-PR ou push direct selon protection de branche)
- Si confirmation : supprime le pilotage s'il en existe un (`/pipe-spec` a pu l'ouvrir), applique la correction, arrete-toi la

**Si le ticket est trop large :**

1. Propose un decoupage en sous-tickets (voir guide dans `${CLAUDE_SKILL_DIR}/reference.md`)
2. Demande confirmation a l'utilisateur
3. Cree les sous-tickets sur le tracker detecte via le MCP correspondant
4. Continue en planifiant le premier sous-ticket

**Si le ticket est de taille raisonnable**, passe directement a la suite.

## Étape 4 — Explorer le codebase

**Si une spec existe pour la feature, lis-la d'abord** (`docs/specs/<feature>.md`) : ses points d'entrée, ses dependances et ses pieges disent ou regarder. Explore ensuite de facon ciblee au lieu de parcourir le projet.

Explore la structure du projet avec Read, Glob, Grep pour :

- Identifier les fichiers et modules concernes
- Comprendre les patterns en place (conventions, architecture, abstractions)
- Repérer les dependances et les zones impactees

Si la spec s'avere fausse ou incomplete pendant l'exploration, signale-le : c'est un ecart a corriger dans la spec, pas a contourner dans le plan.

## Étape 5 — Co-construire le plan (questions/reponses)

Le plan se construit **a deux**. Avant de rediger, pose tes questions a l'utilisateur — plusieurs salves sont possibles, tant que chaque question a un vrai intérêt pour la fonctionnalité ou le fix.

Deux registres, et seulement ceux-la :

- **Métier** : comportement attendu, perimetre exact, cas limites, priorités ("que se passe-t-il si X ?", "cette règle s'applique aussi a Y ?")
- **Architecture et organisation** : decoupage en composants/modules, ou vit la logique, reutiliser l'existant ou créer ("un composant unique ou un decoupage en N ?", "cette logique va dans le service existant ou un nouveau ?")

Règles :

- **Ne rejoue pas le cadrage.** Ce que la spec tranche déjà (intention, perimetre, hors-scope, règles métier) est acquis : le registre métier se limite ici aux cas limites que la spec ne couvre pas. Le gros des questions porte sur l'architecture
- Chaque question s'appuie sur l'exploration (étape 4) et propose des options concretes quand c'est possible
- Pas de questions de bas niveau (nommage, details d'implementation que les conventions du projet tranchent déjà)
- Si l'exploration ne souleve aucune vraie question, le dire et passer a la rédaction
- Chaque decision prise se lit dans le plan lui-meme (approche retenue, alternative ecartee, point d'attention) — pas de journal a cote

## Étape 6 — Rediger le plan

Structure le plan selon le template dans `${CLAUDE_SKILL_DIR}/reference.md`. Le plan doit être **actionnable par `/pipe-test` puis `/pipe-code`** : chemins reels, signatures concretes, comportements explicites.

### Concision

Un plan est une **feuille de route**, pas du code.

- **Budget : 80-120 lignes** pour un ticket simple, jusqu'a 150 pour un ticket decompose
- **Pas de code implemente** dans le plan — regles du bloc de signatures dans `${CLAUDE_SKILL_DIR}/reference.md` (section Règles)
- **La section Tests du plan compte double** : c'est elle que `/pipe-test` transforme en tests unitaires — comportements attendus et cas limites y sont explicites
- **Tableau recapitulatif des fichiers** (nom lie | action | description courte) a la fin du plan, **seulement au-dela de 4-5 fichiers** — en-deca, les en-tetes des étapes (`#### N. [fichier] — action`) portent déjà la meme info, le tableau ferait doublon

### Decomposition

Quand le ticket est decompose en sous-tickets (étape 3) :
- **Plan detaille uniquement pour le 1er sous-ticket** (celui qu'on implemente next)
- **Resume en 2-3 lignes pour chaque sous-ticket suivant** : description + fichiers principaux + classification
- Les sous-tickets suivants seront planifies a leur tour via `/pipe-plan`

### Niveau de detail selon la classification

- **Métier** → insiste sur le comportement attendu cote utilisateur
- **Technique** → insiste sur les contraintes d'implementation et risques de regression
- **Mixte** → couvre les deux aspects

## Étape 7 — Completer le fichier de pilotage

Il a normalement ete ouvert par `/pipe-spec` — dans ce cas, **complète-le sans rien ecraser** (l'en-tete et les cases déjà cochees restent).

S'il n'existe pas (le ticket ne concernait aucune feature, ou `/pipe-plan` a ete invoque seul), crée `.claude/plans/plan-<identifiant>.md` selon `${CLAUDE_SKILL_DIR}/../../shared/pilotage-template.md` (charge-le avec Read) :

- Issue git : `plan-42.md` ; ticket JIRA : `plan-PROJ-42.md` ; texte libre : `plan-<slug>.md`
- Cree `.claude/plans/` si nécessaire et verifie que le repertoire est dans `.gitignore` (document de travail ephemere — jamais versionne, supprime a la creation de la PR)
- Remplis l'en-tete : ticket (l'identifiant seul) et spec liee (chemin, ou `sans objet`)

Dans les deux cas, ajoute le plan rédigé a l'étape 6, puis assure-toi que `Spec a jour` est cochee : soit la spec est validee, soit le ticket ne concerne aucune feature. Ne recopie jamais le contenu de la spec dans le pilotage — seulement son chemin.

La section `## Tests` du pilotage (distincte de la section Tests **a l'interieur** du plan rédigé a l'étape 6) reste `[a completer par /pipe-test]` : c'est `/pipe-test` qui la remplit avec les fichiers reellement ecrits, jamais `/pipe-plan` — la remplir ici ferait doublon avec la section Tests du plan.

Presente le plan a l'utilisateur. Coche `Plan valide` dans l'etat **uniquement apres son accord explicite** — sinon itere.

## Étape 8 — Proposer la suite

```
---
Plan valide · pilotage `.claude/plans/plan-XX.md`.
Suite : les tests — `/pipe-test XX` (cette session). `/pipe-ship XX` reprend le cycle a tout moment.
```

---

## Input utilisateur

$ARGUMENTS
