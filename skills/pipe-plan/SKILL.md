---
name: pipe-plan
description: Co-construire le plan d'un ticket (Jira, GitHub, GitLab, Gitea) par questions/reponses, et tenir le pilotage.
argument-hint: [cle JIRA, numéro issue, URL ou texte]
---

**Le plan se construit à deux, et seulement sur ce que le cadrage n'a pas déjà tranché** : il dit comment et dans quel ordre, avec des chemins réels et des signatures, jamais du code.

## Étape 0 — Ticket

Read `${CLAUDE_SKILL_DIR}/ticket.md` et applique-le : plateforme, tracker, formes de l'argument, hiérarchie Jira.

## Étape 1 — Spec

Read `docs/specs/README.md` :

- Spec à jour pour la feature → continue, elle guide l'exploration
- Spec absente ou obsolète (le ticket change comportement, périmètre ou décision structurante) → annonce-le, charge `${CLAUDE_SKILL_DIR}/../pipe-spec/SKILL.md` et reviens ici une fois la spec validée
- Aucune feature concernée (voie rapide, correction sans règle métier, outillage) → `sans objet` dans le pilotage, continue
- Question ouverte (label `question`/`spike`/`investigation`, titre en « Investiguer », « Explorer ») → non planifiable : renvoie vers `/pipe-spec` (ticket d'investigation) et stop
- Pas de `docs/specs/` → propose `/pipe-spec`, continue sans si l'utilisateur décline

## Étape 2 — Classifier

Technique (refactor, migration, perf, CI, lint, deps, infra, dette, tooling) · Métier (fonctionnalité, UX, écran, workflow, export) · Mixte (besoin métier + changement architectural significatif — le cas le plus fréquent). Technique pur = sans impact utilisateur visible ; métier pur = sans nouvelle couche technique. Annonce la classification.

## Étape 3 — Taille

- Trop petit (aucun comportement à tester : typo, libellé, casse, config triviale, bump mineur) → propose la voie rapide : pas de pilotage, pas de tests, correction directe + `/pipe-commit` mode simple. Confirmé → supprime le pilotage s'il existe, applique la correction, stop
- Trop large (> 3 modules, > 2 couches, plusieurs features indépendantes, plus qu'une session `/pipe-code`) → Read `${CLAUDE_SKILL_DIR}/decomposition.md`, propose le découpage, confirme, crée les sous-tickets sur le tracker (MCP), planifie le premier
- Sinon, continue

## Étape 4 — Explorer

Spec d'abord (`docs/specs/<feature>.md` : points d'entrée, dépendances, pièges), puis Read, Glob, Grep de façon ciblée : fichiers et modules concernés, patterns en place, zones impactées. Spec fausse ou incomplète → à signaler pour correction dans la spec, pas à contourner dans le plan.

## Étape 5 — Q/R (plusieurs salves)

Deux registres : métier — seulement les cas limites que la spec ne couvre pas ; architecture — découpage en composants, où vit la logique, réutiliser ou créer.

- Chaque question s'appuie sur l'exploration et propose des options concrètes
- Pas de nommage ni de détail que les conventions du projet tranchent déjà
- Aucune vraie question → le dire et rédiger
- Chaque décision se lit dans le plan (approche retenue, alternative écartée, point d'attention), pas dans un journal à côté

## Étape 6 — Rédiger

Read `${CLAUDE_SKILL_DIR}/template.md` (template et règles). Le plan est actionnable par `/pipe-test` puis `/pipe-code` : chemins réels ou `(à créer)`, signatures concrètes, comportements explicites, ordre = dépendances d'abord. Métier → insiste sur le comportement utilisateur ; technique → contraintes et risques de régression ; mixte → les deux. Ticket décomposé : plan détaillé du premier sous-ticket, 2-3 lignes par suivant (description, fichiers, classification).

## Étape 7 — Pilotage

- Ouvert par `/pipe-spec` → complète sans rien écraser
- Absent → crée `.claude/plans/plan-<identifiant>.md` depuis `${CLAUDE_SKILL_DIR}/../../shared/pilotage-template.md` (nommage et règles dedans), en-tête : ticket, spec (chemin ou `sans objet`)
- Ajoute le plan ; `Spec a jour` cochée (spec validée ou `sans objet`) ; `## Tests` reste à `/pipe-test`
- Présente le plan ; `Plan valide` cochée après accord explicite seulement — sinon itère

## Étape 8 — Suite

```
Plan validé · pilotage `.claude/plans/plan-XX.md`. Suite : `/pipe-test XX` (cette session) ; `/pipe-ship XX` reprend à tout moment.
```

---

## Input utilisateur

$ARGUMENTS
