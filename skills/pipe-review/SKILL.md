---
name: pipe-review
description: Review automatique du code via sub-agent. Analyse bugs, securite, performance, architecture et types avec rapport structure. Utiliser apres /pipe-code et avant /pipe-test.
model: sonnet
---

## Contexte

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/../_workflow-persona/SKILL.md` avant de commencer.

---

## Etape 0 — Verifications

- [ ] La branche courante n'est pas la branche par defaut
- [ ] Il y a au moins un commit d'avance sur la branche par defaut

Si rien a reviewer, signale-le et arrete-toi.

## Etape 1 — Charger le contexte projet

- Utilise Read pour charger `CLAUDE.md` a la racine du repo (si absent, continue sans)
- Utilise Read pour charger `.claude/_review-persona.md` (si present — personnalisation projet-specifique du style de review)

## Etape 2 — Collecter le contexte

Rassemble les informations necessaires :

- **Diff complet** de la branche vs branche par defaut (`git diff <branche-defaut>...HEAD`)
- **Liste des fichiers** modifies et crees
- **Contenu integral** de chaque fichier modifie via Read (pas seulement le diff — le reviewer a besoin du contexte complet)
- **Issue liee** (depuis le numero dans le nom de branche, ex: `feat/42-...` → issue #42)

## Etape 3 — Lancer la review en sub-agent

Lance un **sub-agent** (Agent tool, type `general-purpose`, model `sonnet`) pour isoler la review du contexte principal. Passe-lui le diff, la liste des fichiers, le contenu de `CLAUDE.md` (si charge) et le contenu de `_review-persona.md` (si charge). Le sub-agent lit chaque fichier modifie en entier via Read.

Prompt du sub-agent :

```
Tu es un reviewer expert. Ton role est de detecter les vrais problemes et de les signaler directement, au bon endroit, de facon actionnable.

Lis chaque fichier modifie dans son integralite via Read, puis analyse les changements en profondeur.

Pour chaque fichier, cherche activement :

**Bugs et correctness**
- Logique incorrecte, cas limites non geres, conditions inversees
- Race conditions, mutations inattendues, effets de bord
- Promesses non awaited, erreurs silencieuses

**Securite**
- Injection (SQL, commande, XSS), donnees non validees cote serveur
- Secrets exposes, permissions trop larges, IDOR

**Performance**
- N+1 queries, appels redondants en boucle
- Chargements bloquants inutiles, fuites memoire

**Architecture et maintenabilite**
- Violation des conventions du projet (voir CLAUDE.md ci-dessous si fourni)
- Couplage fort, responsabilites melangees
- Duplication de logique metier critique

**Types et contrats**
- `any` injustifie, assertions forcees (`as`, `!`) sans garde
- Props/parametres mal types, retours inconsistants

Pour chaque probleme, donne :
- Fichier et ligne
- Severite : BLOQUANT (bug, faille, regression) / AVERTISSEMENT (dette significative) / SUGGESTION (lisibilite, robustesse)
- Description en 1-2 phrases centree sur l'impact
- Correction proposee

**Ce que tu ne fais PAS :**
- Pas de commentaire sur le style ou le formatting (c'est le role de Biome/ESLint)
- Pas de reformulation de ce que fait le code
- Pas de compliments generiques
- Pas de rapport exhaustif de tous les changements

**Style** : ecris comme si tu parlais a un developpeur competent. Une phrase pour le probleme, une pour la correction — pas plus. L'impact doit etre immediatement comprehensible (ex: "ca peut crasher si X est null" plutot que "violation du principe de null-safety").

Produis un rapport structure avec statut global : OK, AVERTISSEMENTS, ou BLOQUANT.
```

## Etape 4 — Afficher le rapport

Affiche le rapport du sub-agent dans ce format :

```
## Review — [branche]

### Statut : OK / Avertissements / Bloquant

### Problemes bloquants (a corriger avant de continuer)
- `fichier.ts:42` description du probleme
  → Correction proposee

### Avertissements
- `fichier.ts:15` description
  → Suggestion

### Suggestions
- `fichier.ts:8` description
  → Suggestion
```

Si aucun probleme dans une categorie, ne pas afficher la section (pas de liste vide).

## Etape 5 — Synthese et revue interactive

### Phase 1 — Synthese rapide

Apres l'affichage du rapport (etape 4), produis un recap condense :

```
### Synthese

- X bloquant(s)
- Y avertissement(s)
- Z suggestion(s)
```

Ne rien corriger a ce stade.

**Si statut OK** (aucun probleme) → propose directement `/pipe-test`. Fin du skill.

**Si des problemes sont trouves** → demande a l'utilisateur :

```
Tu veux passer en revue les problemes un par un ? (oui / non — si non, on passe directement a `/pipe-test`)
```

Si l'utilisateur decline, propose `/pipe-test` et termine.

### Phase 2 — Revue interactive

Parcours chaque probleme dans l'ordre de severite (bloquants d'abord, puis avertissements, puis suggestions).

Pour chaque probleme :

1. **Explique en detail** : contexte, impact, code concerne (lis le fichier via Read pour montrer le code exact)
2. **Propose la correction concrete** telle que decrite dans le rapport du sub-agent
3. **Attends la decision de l'utilisateur** :
   - **corriger** → relis d'abord le fichier via Read (les corrections precedentes ont pu modifier les lignes), puis applique la correction
   - **adapter** → demande la modification souhaitee a l'utilisateur, relis le fichier via Read, puis applique
   - **ignorer** → passe au probleme suivant sans rien modifier

Ne jamais corriger automatiquement sans validation explicite de l'utilisateur.

### Cloture

Si au moins un probleme a ete traite en phase 2, affiche un recap des actions :

```
### Recap review interactive

- X probleme(s) corrige(s)
- Y probleme(s) ignore(s)
- Z probleme(s) adapte(s)
```

Si l'utilisateur a decline la revue (phase 2 non executee), saute le recap.

Si des bloquants ont ete ignores, signale-le explicitement avant de proposer `/pipe-test` :

```
⚠️ Attention : X bloquant(s) ont ete ignores. Ces problemes peuvent causer des bugs ou regressions.
```

Puis propose la suite :

```
---
Review terminee. Prochaine etape : `/pipe-test` pour verifier que tout passe.
```

---

## Input utilisateur

$ARGUMENTS
