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

Pour chaque probleme, produis ces 7 champs structures (utilises ensuite par la phase 2 du skill pour la revue interactive) :

- **fichier** : chemin et ligne (ex: `src/services/user.service.ts:42`)
- **severite** : BLOQUANT (bug, faille, regression) / AVERTISSEMENT (dette significative) / SUGGESTION (lisibilite, robustesse)
- **contexte_fonctionnel** : 1-2 phrases qui resituent le bout de code dans le parcours utilisateur ou le flux metier. Reponds a "qui appelle ce code, dans quelle situation, pour faire quoi ?" en langage du domaine. Pas de noms de fonctions, pas de tags XML/HTML, pas de jargon technique. Si le contexte n'est pas inferrable depuis le diff et les fichiers lus, ecris explicitement "Contexte non identifie depuis le diff" plutot que d'inventer
- **probleme_une_phrase** : reformulation **fonctionnelle** du probleme, comprehensible sans le code. **Interdit** : noms de fonctions ou variables, tags XML/HTML, syntaxe de code, noms de types. Exemple : "Si la reponse du logiciel de caisse est incomplete, on continue comme si tout allait bien" et non "La garde `single.children.length > 0` accepte un `<resultCustomerType>` sans `<id>`"
- **gravite_impact** : la **premiere phrase** doit decrire une consequence concrete et observable cote utilisateur final ou metier (ce qu'il voit, perd, risque). Les nuances de frequence et le contexte technique viennent ensuite. Exemple : "L'utilisateur en caisse verrait un ecran de confirmation avec un numero de carte vide. Cas rare en pratique, mais sans message d'erreur le caissier n'a aucun moyen de comprendre ce qui s'est passe"
- **cause** : explication accessible de l'origine. **Prefere** "le code", "la verification", "la fonction qui parse la reponse" plutot que les noms exacts de symboles. Ne nomme un symbole precis que si c'est indispensable pour pointer le bon endroit
- **correction** : commence par une **phrase d'introduction fonctionnelle** ("Verifier que la reponse contient bien un numero de carte avant de continuer") puis donne la directive technique courte et actionnable, avec un avant/apres tres bref si pertinent

**Ce que tu ne fais PAS :**
- Pas de commentaire sur le style ou le formatting (c'est le role de Biome/ESLint)
- Pas de reformulation de ce que fait le code
- Pas de compliments generiques
- Pas de rapport exhaustif de tous les changements

**Style** : pour chacun des 7 champs, ecris comme si tu expliquais a quelqu'un qui n'a **pas** le code sous les yeux — un decideur produit, un dev qui reprend le projet la semaine prochaine, ou toi-meme dans 6 mois. L'impact doit etre exprime en termes concrets (consequence visible) et non en vocabulaire technique abstrait : preferer "ca peut crasher si X est null" a "violation du principe de null-safety". Une a deux phrases par champ suffisent.

Produis un rapport structure avec statut global : OK, AVERTISSEMENTS, ou BLOQUANT.
```

## Etape 4 — Afficher le rapport

Affiche le rapport du sub-agent dans ce format :

```
## Review — [branche]

### Statut : OK / Avertissements / Bloquant

### Problemes bloquants (a corriger avant de continuer)
- `fichier.ts:42` <probleme_une_phrase>
  → <correction>

### Avertissements
- `fichier.ts:15` <probleme_une_phrase>
  → <correction>

### Suggestions
- `fichier.ts:8` <probleme_une_phrase>
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

#### Exemple de rendu

```
[Bloquant 1/3] — src/services/user.service.ts:42

❓ Le probleme en une phrase
   On notifie le client avant d'avoir fini d'enregistrer ses donnees.

❓ C'est grave ?
   Oui. Dans environ 1 cas sur 10, l'utilisateur verra l'ancienne
   version de son profil juste apres l'avoir modifie.

❓ D'ou ca vient ?
   Un `await` oublie devant `saveCache(user)` : la notification
   part immediatement, sans attendre la fin de l'ecriture en cache.

❓ Comment on corrige ?
   Ajouter `await` devant l'appel :
   `await saveCache(user)` au lieu de `saveCache(user)`.

→ corriger / adapter / ignorer ?
```

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
