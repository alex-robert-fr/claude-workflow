---
name: pipe-spec
description: Cadrer une feature dans une spec durable et versionnee (docs/specs/) avant le dev. Sans argument, inventorier l'existant.
argument-hint: [cle JIRA, numéro issue, URL, nom de feature, ou rien pour inventorier l'existant]
---

Une spec repond a « qu'est-ce que cette feature, et pourquoi ? ». Elle vit **dans le repo**, versionnee, et survit au ticket qui l'a fait naitre : c'est le contexte que toute session future charge avant de toucher a la feature, au lieu de relire le code.

**Une spec n'est pas un plan.** Cette frontiere est la règle la plus importante de ce skill ; les critères exacts sont dans `${CLAUDE_SKILL_DIR}/reference.md`.

## Mode inventaire — amorcer un projet existant

**Declencheur : aucun argument.** Un projet dont les features existent déjà n'aura jamais de specs si elles ne s'ecrivent qu'au fil des cycles — il faudrait autant de tickets que de features. Ce mode rattrape l'existant, en commencant par ce qui rapporte le plus.

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/inventaire.md` : il donne la méthode de reperage, le critère de priorisation et le format du tableau.

Presente le classement, puis demande **quelle feature specifier maintenant**. Une fois le choix fait, reprends le flow normal a l'étape 2 en traitant ce nom de feature comme l'argument (pas de ticket, donc pas de pilotage).

Deux règles non negociables :

- **Une feature par passe.** Ne génère jamais plusieurs specs d'affilee : chacune exige le Q/R de l'étape 4, et une spec ecrite sans validation humaine est une doc inventee — le pire resultat possible, puisqu'elle sera lue comme une reference
- **Ne devine pas l'intention.** Sur une feature existante, le code dit le comportement mais **jamais** le pourquoi, le hors-scope ni les alternatives ecartees. Ces sections viennent de l'utilisateur ; si elles restent vides, l'exercice ne vaut pas son cout. Le dire plutot que de meubler

## Étape 0 — Détecter l'environnement et récupérer le ticket

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/../pipe-plan/reference.md` et applique la section « Detection de l'environnement et recuperation du ticket ».

Si l'argument est un nom de feature libre sans ticket (`authentification`, `export CSV`), c'est un usage autonome legitime : on documente une feature existante ou a venir, sans cycle. Passe directement a l'étape 1.

Aucun argument → applique le **mode inventaire** ci-dessus au lieu de cette étape.

## Étape 1 — Trier : cette demande merite-t-elle une spec ?

Une spec se justifie quand il y a une **feature** — un comportement que le produit rend, avec des attentes et un perimetre.

Pas de spec pour : typo, libelle, casse, config triviale, bump de dependance, correction de bug qui ne change aucune règle métier. Dans ces cas, annonce-le en une ligne et renvoie vers la voie rapide (`/pipe-commit`) ou vers `/pipe-plan` si le ticket merite un cycle sans pour autant créer de feature.

Un ticket **technique** (refactor, migration) ne crée généralement pas de spec, mais peut en **modifier** une existante — notamment la section Fonctionnement technique, les points d'entrée et les decisions. Traite-le comme une mise a jour.

### Ticket d'investigation (spike)

Un ticket dont la reponse n'est pas connue — label `question`, `spike` ou `investigation`, titre en « Investiguer », « Explorer », « Comparer », ou l'utilisateur le dit — n'est pas encore une feature a developper : c'est une question a trancher. Son livrable est la **spec** de la feature concernee (creation ou mise a jour, decisions et hors-scope compris), jamais du code livre.

- Le code d'exploration (prototype, stories, variantes d'ecran) vit sur une branche `spike/<identifiant>-<titre-court>`, poussee pour sauvegarde et **jamais mergee**. Il sert a repondre aux questions de l'étape 4, pas a être livre — on ne le nettoie pas pour le garder : un prototype porte les pistes ecartees autant que la piste retenue, et une reecriture depuis la spec coute moins cher que ce tri
- Le cycle est raccourci : cadrage → spec validee → `/pipe-commit` puis `/pipe-pr` de la spec seule, sur une branche `docs/<identifiant>-<titre-court>` créée depuis la branche d'integration. Le pilotage marque les phases de plan, tests, dev et code comme sans objet (étape 2), pour que `/pipe-ship` enchaine directement sur les commits
- Une fois la spec mergee : la branche `spike/` est supprimee, le ticket est clos avec un commentaire qui pointe la spec, et le dev qui en decoule fait l'objet de **nouveaux tickets** (`/create-issue`), lies au ticket d'investigation. Chacun repart de la branche d'integration avec un cycle complet, la spec en main
- Exception : si la reponse tient en un changement évident, pas de nouveau ticket — le ticket d'investigation devient le ticket de dev (label et description mis a jour) et le cycle normal reprend a `/pipe-plan`, sur une branche `feat/` neuve

Annonce le verdict en une ligne : « ticket d'investigation, livrable = spec `<feature>` ».

Exception : un ticket technique qui **expose un nouveau contrat observable** (endpoint public, commande, format d'export) merite une spec malgre l'absence d'impact utilisateur direct — le comportement attendu, les cas limites et les couplages avec d'autres features restent a documenter, meme quand personne d'autre que la CI ou le monitoring ne consomme ce contrat. Ne pas trancher seul dans ce cas : proposer l'option et laisser l'utilisateur decider, plutot que de presumer que « technique » vaut « sans spec ».

## Étape 2 — Identifier la feature et ouvrir le pilotage

Utilise Read pour charger `docs/specs/README.md` (l'index). S'il n'existe pas, aucune spec n'a encore ete ecrite : c'est une creation.

Determine si la demande concerne une feature **déjà specifiee** :

- Correspondance évidente dans l'index → **mise a jour** de cette spec
- Aucune correspondance → **creation** d'une nouvelle spec
- Correspondance ambigue, ou la demande chevauche plusieurs specs → propose ton interpretation et demande confirmation avant de continuer

Une feature n'est pas un ticket : plusieurs tickets alimentent la meme spec au fil du temps. Prefere toujours enrichir une spec existante plutot que d'en créer une quasi-doublon.

Annonce le verdict en une ligne : creation ou mise a jour, et de quel fichier.

### Ouvrir le pilotage

**Uniquement dans un cycle** (l'argument identifie un ticket). En usage autonome, saute cette section : pas de ticket, pas de pilotage.

Le cadrage peut s'etaler sur plusieurs sessions. Ouvrir le pilotage **maintenant**, avant le Q/R, est ce qui rend cette phase reprenable par `/pipe-ship` : sans lui, une session interrompue en plein cadrage laisse le cycle invisible.

- Le pilotage existe déjà (reprise) → lis-le, ne l'ecrase pas, et reprends le cadrage la ou il en est
- Sinon → crée `.claude/plans/plan-<identifiant>.md` depuis `${CLAUDE_SKILL_DIR}/../../shared/pilotage-template.md` (charge-le avec Read)

A ce stade, ne remplis **que** l'en-tete : Ticket (l'identifiant seul), Spec (chemin vise) et l'Etat, toutes cases decochees. Le reste — branche, plan, tests — appartient aux skills suivants : ne les invente pas.

**Ticket d'investigation** : coche d'office `Plan valide`, `Tests ecrits`, `Tests valides`, `Dev termine` et `Code valide` avec la mention `(sans objet — spike)`, et renseigne la section Branche avec les deux branches : `spike/<identifiant>-<titre-court>` pour l'exploration, `docs/<identifiant>-<titre-court>` pour la livraison de la spec. Seules `Spec a jour`, `Commits créés` et `PR créée` restent a cocher.

Cree `.claude/plans/` si nécessaire et verifie que le repertoire est dans `.gitignore`.

## Étape 3 — Explorer

**En mise a jour** : lis la spec existante en entier. Elle porte déjà l'intention et les points d'entrée — utilise-les pour cibler ton exploration du code au lieu de partir de zero. C'est exactement le gain que la spec est censee produire.

**En creation** : explore le codebase (Read, Glob, Grep) pour repérer ce qui existe déjà autour de la feature, les patterns en place et les modules qu'elle touchera.

Dans les deux cas, l'exploration sert a poser de **vraies** questions a l'étape 4, et a remplir les sections Fonctionnement technique, Dependances et Points d'entrée.

**En ticket d'investigation**, l'exploration peut passer par du code jetable sur la branche `spike/` : prototype, stories, variantes d'ecran a comparer. Chaque piste essayee nourrit la spec — la retenue dans Comportement attendu, les ecartees dans Decisions avec leur raison. Commite l'exploration sur `spike/` au fil de l'eau (validation humaine comme pour tout commit, body facultatif : rien n'est livre), pour que la spec puisse partir seule sur `docs/` a l'étape 8.

## Étape 4 — Cadrer avec l'utilisateur (questions/reponses)

La spec se construit **a deux**. C'est ici qu'on aligne les attentes, avant tout dev. Plusieurs salves sont possibles.

Les registres, dans l'ordre d'importance :

- **Intention** : quel problème cette feature resout, pour qui, pourquoi maintenant ("a quoi on reconnait que c'est reussi ?")
- **Philosophie** : le principe directeur qui tranchera les arbitrages futurs ("on privilegie la simplicite d'usage ou l'exhaustivite ?")
- **Perimetre et hors-scope** : ce que la feature ne fera pas, et pourquoi — la section la plus utile a long terme
- **Règles métier et cas limites** : le comportement attendu, y compris quand ca se passe mal

Règles :

- Chaque question s'appuie sur l'exploration (étape 3) et propose des options concretes quand c'est possible
- **Pas de questions d'implementation** (nommage, decoupage en modules, ou vit la logique) — elles appartiennent a `/pipe-plan`. Si une question porte sur le « comment coder », elle n'a pas sa place ici
- En mise a jour, ne rejoue pas ce qui est déjà cadre : ne questionne que le delta apporte par le ticket
- Chaque arbitrage tranche ici va dans la section Decisions de la spec, avec sa raison

## Étape 5 — Rediger la spec

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/reference.md` — il contient le template de spec, les règles de rédaction et la frontiere spec/plan.

Ecris ou mets a jour `docs/specs/<feature>.md` (`kebab-case`, crée `docs/specs/` si nécessaire).

**En mise a jour** : modifie les sections concernees, **n'ecrase jamais** la section Decisions — elle s'ajoute, elle ne se reecrit pas. Ajoute la reference du ticket dans l'en-tete. Si le delta contredit une decision passee, garde l'ancienne et note qu'elle est remplacee, avec la raison.

Puis mets a jour l'index `docs/specs/README.md` (crée-le s'il manque) selon `${CLAUDE_SKILL_DIR}/index-format.md` (charge-le avec Read).

## Étape 6 — Vérifier, puis élaguer

Une relecture par le même modèle qui vient d'écrire la spec est complaisante par construction — il ne voit pas ses propres angles morts. La vérification qualitative passe par un **sub-agent indépendant** (Agent tool, type `general-purpose`), qui n'a pas écrit ce fichier et n'a donc aucune raison de le ménager.

Prompt du sub-agent :

```
Utilise Read pour charger `[chemin absolu de docs/specs/<feature>.md]`, puis
`[chemin absolu de ${CLAUDE_SKILL_DIR}/reference.md]` et applique les sections
« Règles de rédaction » et « Template de spec ».

Juge ce fichier selon 3 critères, sans complaisance :

a) Budget et redondance — phrases déductibles du reste, sections qui répètent une
   autre section, tout ce qui relève du plan (étapes, code, TODO)
b) Schéma vs prose — un paragraphe de « Fonctionnement technique » qui énumère un
   enchaînement de decisions binaires parallèles gagnerait-il à devenir un diagramme
   Mermaid (règle exacte donnée dans « Template de spec », section « Fonctionnement
   technique ») ?
c) Duplication vs lien — un passage qui recopie en prose ce qu'un fichier réel dit
   déjà devrait devenir un lien vers ce fichier (Points d'entrée ou Dependances), pas
   une reformulation dans le corps

Sortie : une liste de corrections concrètes, format Question/Réponse court (pas de
prose) — « section concernée -> ce qu'il faut couper/transformer/lier ». Ne réécris
rien : propose seulement, le fichier reste inchangé.
```

Remplace les crochets par les valeurs réelles avant de lancer le sub-agent.

Applique les corrections retenues (Edit) — le sub-agent propose, ce skill reste maître de l'édition finale ; l'Étape 7 reste le point de validation humaine.

Puis, filet de sécurité mécanique (checklist, aucun jugement requis) :

- [ ] **Budget tenu : 40-80 lignes.** Au-delà, couper — ne pas négocier avec soi-même
- [ ] Sections obligatoires présentes (« En une phrase », « Comportement attendu », « Points d'entrée ») ; les sections faibles sont **supprimées**, pas meublées
- [ ] Les chemins des points d'entrée existent réellement, ou sont marqués `(a créer)`

## Étape 7 — Validation humaine

Presente la spec a l'utilisateur (ou, en mise a jour, le diff des sections touchees). C'est le moment ou l'on verifie que les attentes sont bien celles-la — avant que la moindre ligne de code soit ecrite.

Itere jusqu'a son accord explicite.

Une fois l'accord obtenu, et **seulement alors**, mets le pilotage a jour (s'il existe) : coche `Spec a jour` et renseigne le chemin de la spec dans sa section Spec. Les arbitrages de cadrage vivent dans le journal de la spec, jamais recopies dans le pilotage.

## Étape 8 — Proposer la suite

**Dans un cycle (ticket)** :

```
---
Spec [créée | mise a jour] `docs/specs/<feature>.md` · pilotage `.claude/plans/plan-<identifiant>.md`.
Suite : le plan — `/pipe-plan <ticket>` (cette session). `/pipe-ship <ticket>` reprend le cycle a tout moment.
```

**Ticket d'investigation** :

```
---
Spec [créée | mise a jour] `docs/specs/<feature>.md` — livrable du ticket d'investigation · pilotage `.claude/plans/plan-<identifiant>.md`.
Suite : `git switch -c docs/<identifiant>-<titre-court> <branche d'integration>` (la spec non commitee suit), puis `/pipe-commit` et `/pipe-pr`.
Une fois la spec mergee : supprimer `spike/<identifiant>-<titre-court>`, clore le ticket en pointant la spec, créer les tickets de dev (`/create-issue`).
```

**Usage autonome (sans ticket)** :

```
---
Spec [créée | mise a jour] `docs/specs/<feature>.md` — sera committee avec le prochain changeset (`/pipe-commit`).
```

**En mode inventaire**, ajoute le reste a faire — c'est ce qui permet de reprendre le rattrapage plus tard :

```
Rattrapage : N feature(s) specifiee(s) sur M reperees.
Suivante par ordre de valeur : [nom]. Relance `/pipe-spec` sans argument.
```

---

## Input utilisateur

$ARGUMENTS
