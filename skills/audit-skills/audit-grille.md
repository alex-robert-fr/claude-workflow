# Grille d'audit AI-Driven Development

Criteres d'evaluation bases sur la philosophie AI-Driven Development.
Principe central : **la qualite est garantie par le process, pas par la discipline de l'agent ou du developpeur**.

## Pipeline de reference

```
/setup → /pipe-hello → /pipe-plan → /pipe-code → /pipe-review → /pipe-test → /pipe-changelog → /pipe-pr → [merge] → /pipe-tag
```

Chaque etape est un skill invocable independamment. L'humain decide quand passer a l'etape suivante.

---

## Axes d'evaluation

### 1. Process — Pipeline sequentiel avec gates (poids: critique)

**Criteres :**
- [ ] Le workflow est sequentiel avec des gates explicites entre chaque etape
- [ ] Chaque etape est un skill invocable independamment par slash command
- [ ] Chaque skill guide vers l'etape suivante ("Prochaine etape : /xxx")
- [ ] Le plan est persiste dans un fichier (`.claude/plans/`), pas juste dans la conversation
- [ ] Il existe un skill `/setup` qui scaffolde la config projet en une passe

**Anti-patterns :**
- Skill monolithique qui fait planifier+coder+tester+PR en une seule commande
- Plan uniquement dans la conversation (impossible de reprendre en session fraiche)
- Pas de gate de validation entre code et PR (l'agent enchaine sans review ni test)
- Agent Teams pour du dev feature classique (overkill, imprevisible, 7x plus cher)

### 2. Qualite — Par defaut, pas par effort (poids: critique)

**Criteres :**
- [ ] Le formatage et le linting sont geres par des hooks PostToolUse, pas par des instructions au LLM
- [ ] Il existe une etape de review automatique via sub-agent (contexte isole)
- [ ] Il existe une etape de test avec boucle corrective bornee (max N tentatives)
- [ ] Les commandes destructives sont bloquees par des hooks PreToolUse
- [ ] Un hook Stop verifie les tests avant de considerer une tache terminee
- [ ] L'agent signale les problemes structurels a l'humain au lieu de boucler indefiniment

**Anti-patterns :**
- "Assure-toi que le code est bien formatte" dans un skill (c'est le job d'un hook)
- "Pas de console.log", "Pas d'import inutilise" dans les instructions (c'est le job du linter)
- Pas de boucle corrective bornee (l'agent boucle indefiniment sur un test qui fail)
- Review et tests dans le contexte principal (pollution du contexte)

### 3. Architecture — Plugin + Config projet (poids: eleve)

**Criteres :**
- [ ] Separation nette plugin (generique, versionne) / config projet (specifique, dans le repo)
- [ ] Le plugin ne contient aucune info specifique a un projet (stack, URLs, chemins)
- [ ] Il existe un fichier `workflow-config` standardise lu par tous les skills (commandes lint/test/build, plateforme, notifications)
- [ ] CLAUDE.md est minimal (<50 lignes) — uniquement les conventions universelles du projet
- [ ] Les patterns contextuels sont dans `.claude/rules/` et se chargent a la demande selon les fichiers touches

**Anti-patterns :**
- CLAUDE.md obese (>50 lignes de regles — l'instruction-following se degrade)
- Rules dans CLAUDE.md (patterns specifiques a certains fichiers codes en dur au lieu de `.claude/rules/`)
- Config projet dans le plugin (chemins, noms de stack, URLs en dur dans les skills)
- CLAUDE.md qui contient des conventions de code style (c'est le job du linter/formatter)

### 4. Contexte — Ressource rare (poids: eleve)

**Criteres :**
- [ ] Les skills utilisent le progressive disclosure (frontmatter leger, details dans `reference.md`)
- [ ] Les sub-agents sont utilises pour isoler review et tests du contexte principal
- [ ] SKILL.md < 150 lignes — au-dela, fragmenter en fichiers supports
- [ ] Max 3 fichiers charges en cascade par un skill (via "utilise Read pour charger" `.claude/skills/...` ou `${CLAUDE_SKILL_DIR}/...`)
- [ ] Les plans sont dans des fichiers, pas dans la conversation

**Anti-patterns :**
- Skill >200 lignes sans fichiers supports
- Sub-agents hyper-specialises avec contexte cache (preferer le pattern Master-Clone)
- Tout inline dans le SKILL.md (exemples, templates, tables de reference)

### 5. Permissions et autonomie (poids: eleve)

**Criteres :**
- [ ] L'agent a les permissions ouvertes (acceptEdits minimum, idealement bypass)
- [ ] Les garde-fous sont des hooks deterministes, pas des restrictions de permissions
- [ ] L'agent corrige lui-meme les problemes mineurs (lint, tests simples)
- [ ] L'agent signale les problemes structurels au lieu de boucler
- [ ] Il y a un nombre max d'iterations correctives pour eviter les boucles infinies

**Anti-patterns :**
- Limiter les permissions au lieu de poser des hooks (degrade les resultats de maniere disproportionnee)
- Pas de PreToolUse hook pour bloquer les commandes dangereuses (rm -rf, push force main, DROP TABLE)

### 6. Skills — Qualite de conception (poids: moyen)

**Criteres :**
- [ ] Separation stricte orchestration (skill action) vs expertise (skill convention)
- [ ] `$ARGUMENTS` toujours present en fin de skill invocable
- [ ] `argument-hint` present quand des arguments sont attendus
- [ ] Description precise (domaine + declencheur, 20-50 mots)
- [ ] Confirmation avant toute action irreversible (push, creation GitHub, ecriture)
- [ ] Flux lineaire lisible (etapes numerotees)
- [ ] Persona coherente via `_workflow-persona`

**Anti-patterns :**
- Description vague (jamais charge auto)
- Frontmatter sans description (routing impossible)
- Skill d'expertise avec `disable-model-invocation: true` (jamais utilise)
- Fichier plat `nom.md` au lieu de `nom/SKILL.md`
- Duplication de contenu entre skills

### 7. Replicabilite (poids: moyen)

**Criteres :**
- [ ] Le meme plugin fonctionne sur n'importe quel projet (backend, frontend, fullstack)
- [ ] La config projet se scaffolde via `/setup` en quelques minutes
- [ ] Les commit messages suivent les conventional commits
- [ ] Les branches suivent une convention configurable par projet
- [ ] Les PR ont une structure de description standardisee mais configurable
- [ ] Source unique de verite (plugin ou claude-workflow repo) avec distribution automatisee

**Anti-patterns :**
- Editer les skills directement dans un projet (ecrase au prochain sync/update)
- Templates qui ecrasent les personnalisations existantes
- Pas de distribution automatisee (drift entre projets)

---

## Systeme de scoring

| Score | Signification |
|-------|---------------|
| 9-10  | Excellence — workflow de reference, optimisations mineures possibles |
| 7-8   | Solide — bonnes pratiques en place, quelques ameliorations |
| 5-6   | Correct — ca fonctionne mais des gains significatifs sont possibles |
| 3-4   | Insuffisant — problemes structurels, perte de temps/qualite |
| 1-2   | Critique — workflow contre-productif, refonte necessaire |

## Format de rapport

```markdown
# Audit AI-Driven Development

## Score global : X/10

## Resume executif
[2-3 phrases : etat general, forces principales, axe d'amelioration prioritaire]

## Scores par axe
| Axe | Score | Commentaire |
|-----|-------|-------------|
| Process | X/10 | ... |
| Qualite | X/10 | ... |
| Architecture | X/10 | ... |
| Contexte | X/10 | ... |
| Permissions | X/10 | ... |
| Skills | X/10 | ... |
| Replicabilite | X/10 | ... |

## Points forts
- [Ce qui fonctionne bien et qu'il faut garder]

## Problemes critiques
### [Titre du probleme]
- **Constat** : ce qui ne va pas
- **Impact** : pourquoi c'est un probleme
- **Solution** : comment corriger, avec exemple concret

## Ameliorations recommandees
### [Titre] — Priorite [P0/P1/P2]
- **Quoi** : description
- **Pourquoi** : gain attendu
- **Comment** : etapes concretes
- **Effort** : faible / moyen / eleve

## Plan d'action
[Top 5 des actions par ordre de priorite]
```
