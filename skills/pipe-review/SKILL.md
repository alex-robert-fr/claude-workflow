---
name: pipe-review
description: Review du code en session dediee : checks outilles (format, lint, tests), review par agent a haute valeur, pause pour la review humaine du code, puis controle de fraicheur de la spec de la feature. Ne remonte que ce qui compte — un rapport vide est un resultat valide. Utiliser dans une nouvelle session apres /pipe-code.
argument-hint: [cle du ticket ou rien si un seul cycle en cours]
---

## Etape 0 — Verifications

Utilise Read pour charger `.claude/skills/workflow-config/SKILL.md`, puis localise le fichier de pilotage :

- Argument fourni → `.claude/plans/plan-<identifiant>.md`
- Sans argument → cherche `.claude/plans/plan-*.md` : un seul fichier → le prendre ; plusieurs → demander lequel

**Avec pilotage** : verifie que `Dev termine` est coche, place-toi sur la branche du pilotage, lis plan + decisions + notes de reprise.

**Sans pilotage** (usage autonome) : verifie que la branche courante n'est pas la branche par defaut.

S'il n'y a aucun changement a reviewer (ni commits d'avance, ni working tree modifie), signale-le et arrete-toi.

## Etape 1 — Checks outilles

La qualite mecanique passe par les vrais outils, pas par un agent. Lance dans l'ordre, avec les commandes de `workflow-config` :

1. **Format** — applique le formatage
2. **Lint**
3. **Tests**

Si le lint ou les tests echouent : corrige (max 3 tentatives), en respectant la regle du contrat — **ne jamais modifier un test valide** pour le faire passer ; si le probleme semble venir d'un test, stoppe et signale-le. Apres 3 tentatives sans succes, stoppe avec le detail de ce qui a ete tente.

Affiche un recap une ligne :

```
Format : ✅ | Lint : ✅ | Tests : ✅ N passent
```

Si une commande n'est pas configuree dans `workflow-config`, signale-le en une ligne et continue.

## Etape 2 — Collecter le contexte

Rassemble les informations necessaires :

- **Diff complet** vs branche par defaut, **y compris le travail non commite** : `git diff <branche-defaut>` + fichiers non trackes (`git status`)
- **Liste des fichiers** modifies et crees
- **Contenu integral** de chaque fichier modifie via Read (pas seulement le diff — le reviewer a besoin du contexte complet)
- **Ticket lie** (depuis le pilotage, ou le nom de branche)

## Etape 3 — Lancer la review en sub-agent

Lance un **sub-agent** (Agent tool, type `general-purpose`, model `sonnet`) pour isoler la review du contexte principal. Le protocole complet du reviewer (barre de valeur, 7 champs structures, categories d'analyse, style) est dans `reference.md` — **ne le charge pas dans le contexte principal**, c'est le sub-agent qui le lit.

Prompt du sub-agent :

```
Utilise Read pour charger `[chemin absolu de ${CLAUDE_SKILL_DIR}/reference.md]` et applique la section "Protocole du reviewer".

Contexte de la review :
- Branche : [branche courante] (diff vs [branche par defaut], travail non commite inclus)
- Fichiers modifies : [liste des fichiers]
- CLAUDE.md du projet : [chemin, ou "absent"]
- Persona de review projet : [chemin de .claude/_review-persona.md, ou "absent"]

Lis chaque fichier modifie dans son integralite via Read, ainsi que CLAUDE.md et le persona s'ils existent.

[diff complet]
```

Remplace les crochets par les valeurs reelles avant de lancer le sub-agent.

## Etape 4 — Afficher le rapport

**Si le statut est OK** (rien a signaler), affiche une seule ligne — c'est un resultat valide, pas un echec de la review :

```
## Review — [branche]

Rien a signaler : pas de bug detecte, l'organisation du projet est respectee.
```

Sinon, affiche le rapport du sub-agent dans ce format (ne pas afficher les sections vides) :

```
## Review — [branche]

### Statut : Avertissements / Bloquant

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

## Etape 5 — Review humaine du code (pause)

C'est la pause du cycle : l'utilisateur relit le code lui-meme, avec le rapport comme guide. Presente-lui de quoi demarrer :

```
### A relire

- `chemin/fichier.ts` — [ce que le fichier apporte, une ligne]

Checks : Format ✅ | Lint ✅ | Tests ✅ N passent
Rapport : X bloquant(s), Y avertissement(s), Z suggestion(s) — ou "rien a signaler"
```

Puis traite les retours, dans l'ordre :

- **Problemes du rapport** : parcours-les par severite (bloquants d'abord) au format Question/Reponse pedagogique, en te basant sur les 7 champs produits par le sub-agent :

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

❓ Comment on corrige ?
   <correction>

→ corriger / adapter / ignorer ?
```

Attends la decision pour chaque probleme : **corriger** (relis le fichier via Read avant d'appliquer), **adapter** (demande la modification souhaitee puis applique), **ignorer** (passe au suivant). Si besoin d'un exemple complet de rendu, utilise Read pour charger `reference.md` (section "Exemple de rendu Question/Reponse").

- **Retours de l'utilisateur** sur le code qu'il relit : applique-les de la meme facon.
- Apres toute correction : relance les tests (et le lint) pour verifier que rien ne casse.
- Ne jamais corriger sans validation explicite de l'utilisateur.

Si des bloquants ont ete ignores, signale-le explicitement :

```
⚠️ Attention : X bloquant(s) ont ete ignores. Ces problemes peuvent causer des bugs ou regressions.
```

Quand l'utilisateur valide le code : consigne les decisions notables dans la section Decisions du pilotage, puis passe a l'etape 6.

## Etape 6 — Fraicheur de la spec

Le code est fige : c'est le moment de verifier que la doc de la feature ne ment pas. Une spec fausse coute plus cher que pas de spec — c'est le contexte que les sessions suivantes chargeront a la place du code.

Identifie les specs concernees : dans `docs/specs/`, celles dont un **point d'entree** apparait dans le diff, plus celle liee au pilotage. Aucune spec (`sans objet`, ou projet sans `docs/specs/`) → passe a l'etape 7 sans rien signaler.

Pour chaque spec concernee, applique la section « Verification de fraicheur » de `${CLAUDE_SKILL_DIR}/../pipe-spec/reference.md` (charge-la avec Read) : comportement attendu, hors scope, points d'entree, decisions prises pendant le dev.

Si des ecarts existent, presente-les et applique les corrections apres validation :

```
### Spec — `docs/specs/<feature>.md`

- [section] <ecart constate> → <correction proposee>
```

Regles :

- La spec reste une spec : corriger, ce n'est pas y verser le detail de l'implementation ni les etapes du plan
- Une decision structurante prise pendant le dev (ecart au plan, arbitrage metier) rejoint le journal Decisions de la spec, avec le ticket
- Aucun ecart est un resultat valide — le dire en une ligne et passer a la suite
- La spec modifiee fait partie du travail a committer : elle sera rattachee au changeset de la feature par `/pipe-commit`

Puis coche `Code valide` dans le pilotage.

## Etape 7 — Proposer la suite

```
---
Code valide. Phase suivante : `/pipe-commit [ticket]` pour decouper le travail en commits (meme session).
```

---

## Input utilisateur

$ARGUMENTS
