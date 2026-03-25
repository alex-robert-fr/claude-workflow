---
name: test
description: Executer les tests du projet avec boucle corrective bornee (max 3 tentatives). Utiliser apres /review et avant /create-pr.
argument-hint: [rien ou fichier/pattern specifique]
---

Lis `.claude/skills/_workflow-persona/SKILL.md` avant de commencer.

---

## Etape 0 — Verifications

Lis `.claude/skills/workflow-config/SKILL.md` pour identifier la commande de test du projet.

- [ ] Une commande de test est configuree dans `workflow-config`
- [ ] La commande de test est executable (`which` ou `--version` sur l'outil)

Si pas de commande de test configuree → signale-le et arrete-toi :

```
Pas de commande de test configuree dans workflow-config.
Configure la section "Test" de `.claude/skills/workflow-config/SKILL.md` puis relance /test.
```

## Etape 1 — Executer les tests

Lance la commande de test definie dans `workflow-config`.

Si un argument est passe (fichier ou pattern), restreins les tests a ce scope si la commande le supporte.

## Etape 2 — Boucle corrective (max 3 tentatives)

Si tous les tests passent → va directement a l'etape 3.

Si des tests echouent, pour chaque tentative (max 3) :

1. **Analyse l'erreur** — lis le output du test, identifie la cause root
2. **Classifie le probleme** :
   - **Corrigeable** : typo, import manquant, assertion a mettre a jour, mock incomplet, type incorrect
   - **Structurel** : logique metier fausse, architecture incompatible, dependance externe cassee, test obsolete qui ne correspond plus au besoin
3. **Si corrigeable** → corrige, commite la correction (`🐛 fix(scope): correction test — [description]`), relance les tests
4. **Si structurel** → signale et arrete-toi immediatement :

```
⚠️ Probleme structurel detecte — intervention humaine requise.

Fichier(s) : [fichiers concernes]
Erreur : [description precise]
Cause probable : [analyse]

Ce probleme ne peut pas etre corrige automatiquement parce que [raison].
```

Apres 3 tentatives sans succes :

```
⚠️ Tests en echec apres 3 tentatives de correction.

Tentative 1 : [ce qui a ete tente] → [resultat]
Tentative 2 : [ce qui a ete tente] → [resultat]
Tentative 3 : [ce qui a ete tente] → [resultat]

Probleme persistant : [description]
Action requise : intervention humaine necessaire.
```

## Etape 3 — Rapport

```
## Tests — [branche]

### Statut : ✅ Tous passent / ❌ Echecs

Commande : [commande executee]
Tests executes : N
Tests passes : N
Tests echoues : N

### Corrections appliquees (si applicable)
- Tentative N : `fichier.ts` — [description de la correction]
```

Si tous les tests passent, propose la suite :

```
---
Tests OK. Prochaine etape : `/create-pr` pour soumettre la branche.
```

---

## Input utilisateur

$ARGUMENTS
