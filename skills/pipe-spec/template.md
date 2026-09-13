# Spec — template et règles de rédaction

Chargé par `/pipe-spec` à la rédaction et par l'agent `spec-critic`.

Interdit dans une spec (c'est du plan) : étapes d'implémentation, listes de fichiers à créer ou modifier, blocs de code, signatures, extraits de diff, TODO, estimations, référence au sprint ou au ticket en cours dans le corps, toute formulation au futur.

## Template de spec

```markdown
# <Nom de la feature>

> **Statut** : active | expérimentale | dépréciée
> **Retrait** : 2.1.0 — raison en une ligne _(uniquement si dépréciée)_

## En une phrase

Ce que la feature fait, du point de vue de celui qui l'utilise. Une phrase — elle remonte dans l'index.

## Intention

Le problème résolu et à quoi on reconnaît que c'est réussi. 3-5 lignes, en puces. Pas d'histoire du projet.

## Philosophie

Le principe qui tranche les arbitrages futurs, en une puce : « ici on privilégie X sur Y ». Rien ne s'impose → supprimer la section (cas le plus fréquent).

## Comportement attendu

Les garanties observables, une ligne chacune, en langage simple : règles métier, cas limites, comportement en erreur.
Exception : plusieurs endpoints de forme parallèle se documentent en tableau `Endpoint | Réponse | Cas d'échec`, les règles transverses (auth, quota) en puces dessous.

## Hors scope

Ce que la feature ne fait pas, avec la raison — une ligne par exclusion.

## Fonctionnement technique

Le mécanisme réel, en prose dense, jargon du projet autorisé : seule section écrite pour qui va toucher le code. 5-15 lignes.
Un diagramme Mermaid (` ```mermaid flowchart TD ``` `) remplace la prose quand le mécanisme est un enchaînement de décisions binaires parallèles : un diagramme par mécanisme, nœuds enchaînés verticalement (jamais deux branches côte à côte), seulement ce qui bifurque réellement, sans reproduire le tableau du comportement attendu.
Les fichiers n'y figurent pas — liste complète dans Points d'entrée.

## Dépendances

- **Internes** : autres features dont celle-ci dépend → [nom-feature.md](nom-feature.md)
- **Externes** : services, APIs, librairies structurantes, schéma de base
- **Dépendants** : features qui reposent sur celle-ci

## Décisions

Journal — on ajoute, on ne réécrit pas. Uniquement les arbitrages non évidents.

| Version | Ticket | Décision | Raison | Alternative écartée |
|---------|--------|----------|--------|---------------------|
| 1.4.0 | PROJ-42 | ... | ... | ... |
| 1.6.0 (à venir) | PROJ-58 | ... | ... | ... |

## Points d'entrée

| Fichier | Rôle |
|---------|------|
| [reel.ts](../../chemin/reel.ts) | Ce qu'on y trouve, en quelques mots |

## Pièges et zones sensibles

Uniquement le non-devinable : couplage invisible, invariant à maintenir ailleurs. Pas de conseil général.
- **Idée clé en gras** — le reste de l'explication
```

## Règles de rédaction

- Budget 40-80 lignes ; une spec qui gonfle contient du plan, du code ou du bavardage. Vérifié par `check-specs.sh`
- Une info, un seul endroit : pas de reformulation entre sections. Chaque phrase apporte ce qu'on ne peut pas déduire du reste ; pas d'introduction ni de transition
- Sections vides ou faibles supprimées, jamais « N/A ». Obligatoires : En une phrase, Comportement attendu, Points d'entrée
- Points d'entrée : chemins réels vérifiés pendant l'exploration, ou `(à créer)` juste après le lien. Un fichier se cite par son nom seul, en lien markdown relatif à `docs/specs/` (`[nom.ts](../../chemin/nom.ts)`), jamais le chemin en texte visible — dans Points d'entrée comme ailleurs
- Pas de dates : les repères sont la version et le ticket, dans le journal
- Colonne Version : ticket parent de version sur le tracker > version en préparation (`Unreleased` du CHANGELOG, ou version courante incrémentée si elle est déjà publiée) notée `X.Y.Z (à venir)` > `—`. Une version passée ne se devine pas. À la release, `(à venir)` disparaît — seule modification autorisée d'une ligne du journal
- Cellule Décision affirmative, sans négation : l'alternative rejetée a sa colonne
- Fichier en `kebab-case` du nom de feature, sans préfixe ni numéro de ticket. Une spec = une feature, ni un module ni un ticket : deux specs qui se citent en permanence n'en font qu'une
- Dépendance ajoutée entre deux specs : reportée dans les deux fichiers (`Dépendants` d'un côté, `Internes` de l'autre)
