---
name: pipe-spec
description: Cadrer une feature dans une spec durable et versionnee (docs/specs/) avant de planifier le dev. Decrit ce que la feature est, ce qu'on en attend, sa philosophie, son hors-scope, ses dependances et ses points d'entree techniques. Sert de contexte central aux sessions suivantes. Utiliser en tout debut de cycle, avant /pipe-plan — ou sans argument pour inventorier et rattraper les features deja livrees d'un projet existant.
argument-hint: [cle JIRA, numero issue, URL, nom de feature, ou rien pour inventorier l'existant]
---

Une spec repond a « qu'est-ce que cette feature, et pourquoi ? ». Elle vit **dans le repo**, versionnee, et survit au ticket qui l'a fait naitre : c'est le contexte que toute session future charge avant de toucher a la feature, au lieu de relire le code.

**Une spec n'est pas un plan.** Le plan (`/pipe-plan`) dit ce qu'on va faire, dans quel ordre, dans quels fichiers — il est ephemere et meurt a la PR. La spec dit ce qui **est** — elle est durable. Cette frontiere est la regle la plus importante de ce skill ; les criteres exacts sont dans `reference.md`.

## Mode inventaire — amorcer un projet existant

**Declencheur : aucun argument.** Un projet dont les features existent deja n'aura jamais de specs si elles ne s'ecrivent qu'au fil des cycles — il faudrait autant de tickets que de features. Ce mode rattrape l'existant, en commencant par ce qui rapporte le plus.

Applique la section « Inventaire des features non specifiees » de `${CLAUDE_SKILL_DIR}/reference.md` (charge-le avec Read) : elle donne la methode de reperage, le critere de priorisation et le format du tableau.

Presente le classement, puis demande **quelle feature specifier maintenant**. Une fois le choix fait, reprends le flow normal a l'etape 2 en traitant ce nom de feature comme l'argument (pas de ticket, donc pas de pilotage).

Deux regles non negociables :

- **Une feature par passe.** Ne genere jamais plusieurs specs d'affilee : chacune exige le Q/R de l'etape 4, et une spec ecrite sans validation humaine est une doc inventee — le pire resultat possible, puisqu'elle sera lue comme une reference
- **Ne devine pas l'intention.** Sur une feature existante, le code dit le comportement mais **jamais** le pourquoi, le hors-scope ni les alternatives ecartees. Ces sections viennent de l'utilisateur ; si elles restent vides, l'exercice ne vaut pas son cout. Le dire plutot que de meubler

## Etape 0 — Detecter l'environnement et recuperer le ticket

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/../pipe-plan/reference.md` et applique la section « Detection de l'environnement et recuperation du ticket ».

Si l'argument est un nom de feature libre sans ticket (`authentification`, `export CSV`), c'est un usage autonome legitime : on documente une feature existante ou a venir, sans cycle. Passe directement a l'etape 1.

Aucun argument → applique le **mode inventaire** ci-dessus au lieu de cette etape.

## Etape 1 — Trier : cette demande merite-t-elle une spec ?

Une spec se justifie quand il y a une **feature** — un comportement que le produit rend, avec des attentes et un perimetre.

Pas de spec pour : typo, libelle, casse, config triviale, bump de dependance, correction de bug qui ne change aucune regle metier. Dans ces cas, annonce-le en une ligne et renvoie vers la voie rapide (`/pipe-commit`) ou vers `/pipe-plan` si le ticket merite un cycle sans pour autant creer de feature.

Un ticket **technique** (refactor, migration) ne cree generalement pas de spec, mais peut en **modifier** une existante — notamment la section Fonctionnement technique, les points d'entree et les decisions. Traite-le comme une mise a jour.

## Etape 2 — Identifier la feature et ouvrir le pilotage

Utilise Read pour charger `docs/specs/README.md` (l'index). S'il n'existe pas, aucune spec n'a encore ete ecrite : c'est une creation.

Determine si la demande concerne une feature **deja specifiee** :

- Correspondance evidente dans l'index → **mise a jour** de cette spec
- Aucune correspondance → **creation** d'une nouvelle spec
- Correspondance ambigue, ou la demande chevauche plusieurs specs → propose ton interpretation et demande confirmation avant de continuer

Une feature n'est pas un ticket : plusieurs tickets alimentent la meme spec au fil du temps. Prefere toujours enrichir une spec existante plutot que d'en creer une quasi-doublon.

Annonce le verdict en une ligne : creation ou mise a jour, et de quel fichier.

### Ouvrir le pilotage

**Uniquement dans un cycle** (l'argument identifie un ticket). En usage autonome, saute cette section : pas de ticket, pas de pilotage.

Le cadrage peut s'etaler sur plusieurs sessions. Ouvrir le pilotage **maintenant**, avant le Q/R, est ce qui rend cette phase reprenable par `/pipe-ship` : sans lui, une session interrompue en plein cadrage laisse le cycle invisible.

- Le pilotage existe deja (reprise) → lis-le, ne l'ecrase pas, et reprends le cadrage la ou il en est
- Sinon → cree `.claude/plans/plan-<identifiant>.md` depuis le template « Fichier de pilotage » de `${CLAUDE_SKILL_DIR}/../pipe-plan/reference.md` (charge-le avec Read)

A ce stade, ne remplis **que** l'en-tete : Ticket (source, version cible, epic, lien), Spec (chemin vise) et l'Etat, toutes cases decochees. Le reste — branche, plan, tests — appartient aux skills suivants : ne les invente pas.

Cree `.claude/plans/` si necessaire et verifie que le repertoire est dans `.gitignore`.

## Etape 3 — Explorer

**En mise a jour** : lis la spec existante en entier. Elle porte deja l'intention et les points d'entree — utilise-les pour cibler ton exploration du code au lieu de partir de zero. C'est exactement le gain que la spec est censee produire.

**En creation** : explore le codebase (Read, Glob, Grep) pour reperer ce qui existe deja autour de la feature, les patterns en place et les modules qu'elle touchera.

Dans les deux cas, l'exploration sert a poser de **vraies** questions a l'etape 4, et a remplir les sections Fonctionnement technique, Dependances et Points d'entree.

## Etape 4 — Cadrer avec l'utilisateur (questions/reponses)

La spec se construit **a deux**. C'est ici qu'on aligne les attentes, avant tout dev. Plusieurs salves sont possibles.

Les registres, dans l'ordre d'importance :

- **Intention** : quel probleme cette feature resout, pour qui, pourquoi maintenant ("a quoi on reconnait que c'est reussi ?")
- **Philosophie** : le principe directeur qui tranchera les arbitrages futurs ("on privilegie la simplicite d'usage ou l'exhaustivite ?")
- **Perimetre et hors-scope** : ce que la feature ne fera pas, et pourquoi — la section la plus utile a long terme
- **Regles metier et cas limites** : le comportement attendu, y compris quand ca se passe mal

Regles :

- Chaque question s'appuie sur l'exploration (etape 3) et propose des options concretes quand c'est possible
- **Pas de questions d'implementation** (nommage, decoupage en modules, ou vit la logique) — elles appartiennent a `/pipe-plan`. Si une question porte sur le « comment coder », elle n'a pas sa place ici
- En mise a jour, ne rejoue pas ce qui est deja cadre : ne questionne que le delta apporte par le ticket
- Chaque arbitrage tranche ici va dans la section Decisions de la spec, avec sa raison

## Etape 5 — Rediger la spec

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/reference.md` — il contient le template de spec, les regles de redaction, la frontiere spec/plan et le format de l'index.

Ecris ou mets a jour `docs/specs/<feature>.md` (`kebab-case`, cree `docs/specs/` si necessaire).

**En mise a jour** : modifie les sections concernees, **n'ecrase jamais** la section Decisions — elle s'ajoute, elle ne se reecrit pas. Ajoute la reference du ticket dans l'en-tete. Si le delta contredit une decision passee, garde l'ancienne et note qu'elle est remplacee, avec la raison.

Puis mets a jour l'index `docs/specs/README.md` (cree-le s'il manque) selon le format de `reference.md`.

## Etape 6 — Elaguer

Avant de presenter, relis ce que tu viens d'ecrire et coupe. Une spec verbeuse coute les tokens qu'elle est censee economiser — et personne ne la relit.

Supprime tout ce qui releve du plan :

- [ ] Aucune etape d'implementation, aucun « creer / modifier / ajouter le fichier X »
- [ ] Aucun bloc de code, aucun TODO, aucune estimation
- [ ] Tout est ecrit au **present**, comme si la feature existait deja — pas de « on va », pas de reference au sprint ou au ticket courant dans le corps

Puis tout ce qui n'apprend rien :

- [ ] **Budget tenu : 40-80 lignes.** Au-dela, couper — ne pas negocier avec soi-meme
- [ ] Aucune phrase deductible du nom de la feature ou d'une autre section (la redondance entre sections est le premier facteur de verbosite)
- [ ] Aucun paragraphe d'introduction ou de transition
- [ ] Les sections faibles sont **supprimees**, pas meublees — seules « En une phrase », « Comportement attendu » et « Points d'entree » sont obligatoires

Enfin :

- [ ] Les chemins des points d'entree existent reellement, ou sont marques `(a creer)`

## Etape 7 — Validation humaine

Presente la spec a l'utilisateur (ou, en mise a jour, le diff des sections touchees). C'est le moment ou l'on verifie que les attentes sont bien celles-la — avant que la moindre ligne de code soit ecrite.

Itere jusqu'a son accord explicite.

Une fois l'accord obtenu, et **seulement alors**, mets le pilotage a jour (s'il existe) : coche `Spec a jour`, renseigne le chemin de la spec dans sa section Spec, et consigne en `[spec]` les arbitrages de cadrage qui engagent la suite du cycle.

## Etape 8 — Proposer la suite

**Dans un cycle (ticket)** :

```
---
Spec [creee | mise a jour] : `docs/specs/<feature>.md`.
Pilotage : `.claude/plans/plan-<identifiant>.md`.
Phase suivante : planifier le dev — `/pipe-plan <ticket>`, dans cette session.
A tout moment : `/pipe-ship <ticket>` reprend le cycle la ou il en est.
```

**Usage autonome (sans ticket)** :

```
---
Spec [creee | mise a jour] : `docs/specs/<feature>.md`.
Elle sera committee avec le prochain changeset (`/pipe-commit`).
```

**En mode inventaire**, ajoute le reste a faire — c'est ce qui permet de reprendre le rattrapage plus tard :

```
Rattrapage : N feature(s) specifiee(s) sur M reperees.
Suivante par ordre de valeur : [nom]. Relance `/pipe-spec` sans argument.
```

---

## Input utilisateur

$ARGUMENTS
