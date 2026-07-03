---
name: pipe-review
description: Review automatique du code via sub-agent. Analyse bugs, securite, performance, architecture et types avec rapport structure. Utiliser apres /pipe-code et avant /pipe-test.
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

Lance un **sub-agent** (Agent tool, type `general-purpose`, model `sonnet`) pour isoler la review du contexte principal. Le protocole complet du reviewer (7 champs structures, categories d'analyse, style) est dans `reference.md` — **ne le charge pas dans le contexte principal**, c'est le sub-agent qui le lit.

Prompt du sub-agent :

```
Utilise Read pour charger `[chemin absolu de ${CLAUDE_SKILL_DIR}/reference.md]` et applique la section "Protocole du reviewer".

Contexte de la review :
- Branche : [branche courante] (diff vs [branche par defaut])
- Fichiers modifies : [liste des fichiers]
- CLAUDE.md du projet : [chemin, ou "absent"]
- Persona de review projet : [chemin de .claude/_review-persona.md, ou "absent"]

Lis chaque fichier modifie dans son integralite via Read, ainsi que CLAUDE.md et le persona s'ils existent.

[diff complet]
```

Remplace les crochets par les valeurs reelles avant de lancer le sub-agent.

## Etape 4 — Afficher le rapport

Affiche le rapport du sub-agent dans ce format :

```
## Review — [branche]

### Statut : OK / Avertissements / Bloquant

### Problemes bloquants (a corriger avant de continuer)
- `fichier.ts:42` <probleme_une_phrase>
  · <contexte_fonctionnel>
  → <correction>

### Avertissements
- `fichier.ts:15` <probleme_une_phrase>
  · <contexte_fonctionnel>
  → <correction>

### Suggestions
- `fichier.ts:8` <probleme_une_phrase>
  · <contexte_fonctionnel>
  → <correction>
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

`N/Total` = position du probleme dans la liste globale triee par severite, sur le nombre total de problemes toutes severites confondues (ex: si 2 bloquants + 1 suggestion, le premier bloquant est `1/3`, la suggestion est `3/3`).

Pour chaque probleme, **affiche-le dans le format Question/Reponse pedagogique suivant**, en te basant sur les 7 champs produits par le sub-agent a l'etape 3.

```
[Severite N/Total] — <fichier>:<ligne>

❓ De quoi on parle ?
   <contexte_fonctionnel>

❓ Le probleme en une phrase
   <probleme_une_phrase>

❓ C'est grave ?
   <gravite_impact>

❓ D'ou ca vient ?
   <cause>
   [extrait de code pertinent si necessaire]

❓ Comment on corrige ?
   <correction>

→ corriger / adapter / ignorer ?
```

Puis **attends la decision de l'utilisateur** :

- **corriger** → relis d'abord le fichier via Read (les corrections precedentes ont pu modifier les lignes), puis applique la correction
- **adapter** → demande la modification souhaitee a l'utilisateur, relis le fichier via Read, puis applique
- **ignorer** → passe au probleme suivant sans rien modifier

Ne jamais corriger automatiquement sans validation explicite de l'utilisateur.

Si besoin d'un exemple complet de rendu, utilise Read pour charger `reference.md` (section "Exemple de rendu Question/Reponse").

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
