---
name: pipe-review
description: Review automatique du code via sub-agent. Verifie patterns, complexite, edge cases et securite. Utiliser apres /pipe-code et avant /pipe-test.
---

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/../_workflow-persona/SKILL.md` avant de commencer.

---

## Etape 0 — Verifications

- [ ] Il y a des changements a reviewer (au moins un commit d'avance sur la branche par defaut)
- [ ] La branche courante n'est pas la branche par defaut

Si rien a reviewer, signale-le et arrete-toi.

## Etape 1 — Collecter le contexte

Rassemble les informations necessaires :

- **Diff complet** de la branche vs branche par defaut (`git diff <branche-defaut>...HEAD`)
- **Liste des fichiers** modifies et crees
- **Issue liee** (depuis le numero dans le nom de branche, ex: `feat/42-...` → issue #42)

## Etape 2 — Lancer la review en sub-agent

Lance un **sub-agent** (Agent tool, type `general-purpose`) pour isoler la review du contexte principal. Passe-lui ce prompt :

```
Tu es un reviewer de code senior. Review les changements sur la branche courante.

Lis chaque fichier modifie ou cree et verifie :

1. **Patterns du projet** — le code suit les conventions existantes, pas de nouvelle abstraction injustifiee
2. **Complexite** — pas de fonction > 40 lignes, pas de nesting > 3 niveaux, logique lisible
3. **Edge cases** — null, vide, erreurs, cas limites couverts
4. **Securite** — pas d'injection, XSS, secrets en dur, donnees sensibles loguees
5. **Code mort** — pas de code commente, imports inutilises, variables orphelines
6. **Taille des fichiers** — aucun fichier > 300 lignes
7. **Nommage** — coherent avec le reste du codebase
8. **Duplication** — pas de copier-coller d'un pattern qui existe deja

Pour chaque probleme, donne :
- Fichier et ligne
- Categorie (pattern, complexite, edge-case, securite, code-mort, taille, nommage, duplication)
- Severite (bloquant, avertissement, suggestion)
- Description precise et correction proposee

Produis un rapport structure avec un statut global : OK, AVERTISSEMENTS, ou BLOQUANT.
```

## Etape 3 — Afficher le rapport

Affiche le rapport du sub-agent dans ce format :

```
## Review — [branche]

### Statut : ✅ OK / ⚠️ Avertissements / ❌ Bloquant

### Problemes bloquants (a corriger avant de continuer)
- `fichier.ts:42` — [categorie] description du probleme
  → Correction proposee

### Avertissements
- `fichier.ts:15` — [categorie] description
  → Suggestion

### Points positifs
- Ce qui est bien fait dans cette implementation
```

## Etape 4 — Corrections et suite

Selon le statut :

- **OK** → propose de lancer `/pipe-test`
- **Avertissements** → propose de corriger les avertissements ou de passer a `/pipe-test` en l'etat
- **Bloquant** → corrige les problemes bloquants, puis relance la review (max 2 iterations de correction)

```
---
Review terminee. Prochaine etape : `/pipe-test` pour verifier que tout passe.
```

---

## Input utilisateur

$ARGUMENTS
