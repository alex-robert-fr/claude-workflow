---
name: pipe-plan
description: Planifier une demande metier depuis un ticket (JIRA, GitHub, GitLab, Gitea). Co-construit le plan avec l'utilisateur par questions/reponses orientees metier et architecture, puis cree le fichier de pilotage qui suit le cycle jusqu'a la PR. Utiliser en debut de cycle, avant /pipe-test.
argument-hint: [cle JIRA, numero issue, URL ou texte]
---

## Etape 0 — Detecter l'environnement

### Plateforme git

Recupere l'URL du remote origin (`git remote get-url origin`) et deduis la plateforme :

| Domaine | Plateforme | MCP |
|---------|-----------|-----|
| `github.com` | GitHub | `mcp__github__` |
| `gitlab.com` ou `gitlab.*` | GitLab | `mcp__gitlab__` |
| Autre | Gitea | `mcp__gitea__` |

Si `.claude/skills/workflow-config/SKILL.md` existe, sa configuration a priorite sur la detection automatique.

### Tracker externe (optionnel)

Si l'argument ressemble a une cle de projet externe ou si le workflow-config mentionne un tracker, utilise le MCP correspondant :

| Pattern | Tracker | MCP |
|---------|---------|-----|
| `ABC-123` (lettres majuscules-chiffres) | JIRA | `mcp__atlassian__` |
| URL `*.atlassian.net/*` | JIRA | `mcp__atlassian__` |
| URL `linear.app/*` | Linear | MCP Linear si disponible |

Si aucun tracker externe n'est detecte, le ticket vient de la plateforme git.

### Verifications

Avant de continuer, verifie :

- [ ] Le repo a un remote `origin` configure
- [ ] L'argument permet d'identifier un ticket (numero, URL, cle ou texte)
- [ ] Le MCP necessaire est disponible (sinon, signale-le et propose des alternatives)

Si une verification echoue, signale-le clairement et arrete-toi.

## Etape 1 — Recuperer le ticket et sa hierarchie

L'argument peut prendre plusieurs formes :

- `42` ou `#42` → issue sur la plateforme git detectee, via le MCP correspondant
- `https://github.com/org/repo/issues/42` → extrais plateforme, org, repo, numero depuis l'URL
- `https://gitlab.com/org/repo/-/issues/42` → idem pour GitLab
- `https://org.atlassian.net/browse/PROJ-42` → ticket JIRA via MCP Atlassian
- `PROJ-42` → cle JIRA, utilise le MCP Atlassian
- Texte libre → recherche dans les issues ouvertes du repo, confirme avec l'utilisateur si ambigu

Recupere le ticket complet (titre, body, labels/tags, commentaires pertinents).

### Hierarchie JIRA

Les tickets JIRA sont souvent organises en epic → ticket de version (ex: `0.5.2`) → demandes metier. Si le tracker est JIRA, remonte la hierarchie du ticket :

- **Version cible** : le ticket parent, si son nom ressemble a une version
- **Epic** : l'epic de rattachement, si elle existe

Ces deux informations vont dans le fichier de pilotage (etape 7) et serviront a la PR.

## Etape 2 — Classifier le ticket

Utilise Read pour charger `reference.md` — il contient les criteres de classification, le template de plan et le template du fichier de pilotage.

Determine la nature du ticket selon les criteres de `reference.md` :

- **Technique** : dette, refactoring, perf, infra, CI/CD, migration, tooling
- **Metier** : fonctionnalite utilisateur, user story, besoin business, UX/UI
- **Mixte** : besoin metier qui implique des changements techniques significatifs

Annonce la classification a l'utilisateur — elle oriente le plan.

## Etape 3 — Evaluer la taille et decomposer si necessaire

Evalue si le ticket est implementable en un seul cycle (tests → dev → review). Consulte les criteres de decomposition dans `reference.md`.

**Si le ticket est trop petit pour le cycle** — aucun comportement a tester (typo, libelle, casse, config triviale, bump mineur de dependance) : propose la **voie rapide** au lieu du cycle. Correction directe + `/pipe-commit` (mode simple), micro-PR ou push direct selon la protection de branche — pas de pilotage, pas de tests dedies. Si l'utilisateur confirme, applique la correction et arrete-toi la.

**Si le ticket est trop large :**

1. Propose un decoupage en sous-tickets (voir guide dans `reference.md`)
2. Demande confirmation a l'utilisateur
3. Cree les sous-tickets sur le tracker detecte via le MCP correspondant
4. Continue en planifiant le premier sous-ticket

**Si le ticket est de taille raisonnable**, passe directement a la suite.

## Etape 4 — Explorer le codebase

Explore la structure du projet avec Read, Glob, Grep pour :

- Identifier les fichiers et modules concernes
- Comprendre les patterns en place (conventions, architecture, abstractions)
- Reperer les dependances et les zones impactees

## Etape 5 — Co-construire le plan (questions/reponses)

Le plan se construit **a deux**. Avant de rediger, pose tes questions a l'utilisateur — plusieurs salves sont possibles, tant que chaque question a un vrai interet pour la fonctionnalite ou le fix.

Deux registres, et seulement ceux-la :

- **Metier** : comportement attendu, perimetre exact, cas limites, priorites ("que se passe-t-il si X ?", "cette regle s'applique aussi a Y ?")
- **Architecture et organisation** : decoupage en composants/modules, ou vit la logique, reutiliser l'existant ou creer ("un composant unique ou un decoupage en N ?", "cette logique va dans le service existant ou un nouveau ?")

Regles :

- Chaque question s'appuie sur l'exploration (etape 4) et propose des options concretes quand c'est possible
- Pas de questions de bas niveau (nommage, details d'implementation que les conventions du projet tranchent deja)
- Si l'exploration ne souleve aucune vraie question, le dire et passer a la redaction
- Chaque decision prise est consignee dans la section Decisions du fichier de pilotage (etape 7), avec sa raison en une ligne

## Etape 6 — Rediger le plan

Structure le plan selon le template dans `reference.md`. Le plan doit etre **actionnable par `/pipe-test` puis `/pipe-code`** : chemins reels, signatures concretes, comportements explicites.

### Concision

Un plan est une **feuille de route**, pas du code.

- **Budget : 80-120 lignes** pour un ticket simple, jusqu'a 150 pour un ticket decompose
- **Pas de blocs de code** dans le plan. Les signatures de fonctions, noms de types et descriptions textuelles suffisent
- **La section Tests du plan compte double** : c'est elle que `/pipe-test` transforme en tests unitaires — comportements attendus et cas limites y sont explicites
- **Terminer par un tableau recapitulatif** des fichiers (chemin | action | description courte) — scannable en 5 secondes

### Decomposition

Quand le ticket est decompose en sous-tickets (etape 3) :
- **Plan detaille uniquement pour le 1er sous-ticket** (celui qu'on implemente next)
- **Resume en 2-3 lignes pour chaque sous-ticket suivant** : description + fichiers principaux + classification
- Les sous-tickets suivants seront planifies a leur tour via `/pipe-plan`

### Niveau de detail selon la classification

- **Metier** → insiste sur le comportement attendu cote utilisateur
- **Technique** → insiste sur les contraintes d'implementation et risques de regression
- **Mixte** → couvre les deux aspects

## Etape 7 — Creer le fichier de pilotage

Le pilotage est le fil rouge du cycle : chaque session suivante (tests, dev, review) le relit pour savoir ou on en est et ce qui a ete decide. Cree `.claude/plans/plan-<identifiant>.md` selon le template "Fichier de pilotage" de `reference.md` :

- Issue git : `plan-42.md` ; ticket JIRA : `plan-PROJ-42.md` ; texte libre : `plan-<slug>.md`
- Cree `.claude/plans/` si necessaire et verifie que le repertoire est dans `.gitignore` (document de travail ephemere — jamais versionne, supprime a la creation de la PR)
- Remplis : ticket (source, version cible, epic, lien), etat des phases, decisions du Q/R, et le plan redige a l'etape 6

Presente le plan a l'utilisateur. Coche `Plan valide` dans l'etat **uniquement apres son accord explicite** — sinon itere.

## Etape 8 — Proposer la suite

```
---
Plan valide, pilotage cree : `.claude/plans/plan-XX.md`.
Phase suivante : ecrire les tests — `/pipe-test XX`, dans cette session.
A tout moment : `/pipe-ship XX` reprend le cycle la ou il en est.
```

---

## Input utilisateur

$ARGUMENTS
