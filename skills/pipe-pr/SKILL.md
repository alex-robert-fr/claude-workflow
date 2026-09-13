---
name: pipe-pr
description: Créer ou mettre à jour une Pull Request : titre, description, commentaire d'itération. Après /pipe-commit.
disable-model-invocation: true
argument-hint: [rien — détecte automatiquement la branche courante]
allowed-tools:
  - Bash(bash "${CLAUDE_SKILL_DIR}/../../shared/scripts/find-plan.sh" *)
  - Bash(git status *)
  - Bash(git log *)
  - Bash(git remote get-url origin)
  - Bash(gh pr list *)
  - Bash(gh pr view *)
---

**La description d'une PR est un sommaire de son état complet** — contexte, ce qui a été fait, bloc Changelog, à vérifier à la main — jamais un delta ni la doc technique, qui vit dans les commits. Règles : `${CLAUDE_SKILL_DIR}/../git-conventions/SKILL.md`, section Pull Requests (Read).

## Étape 0 — Vérifications

- Read `.claude/skills/workflow-config/SKILL.md` (à défaut `.claude/skills/tech-stack/SKILL.md`, config legacy)
- Remote `origin` ; branche courante ≠ branche par défaut ; au moins un commit d'avance. Sinon : une ligne, stop
- Branche non poussée → pousse-la (confirmation au premier push), sans commenter la sortie

## Étape 1 — Contexte

- Pilotage : `bash "${CLAUDE_SKILL_DIR}/../../shared/scripts/find-plan.sh"` → identifiant du ticket, plan et points d'attention
- Ticket : depuis le pilotage, sinon l'identifiant du nom de branche (`feat/42-…` → issue #42 via MCP GitHub ; `feat/PROJ-42-…` → Jira via MCP Atlassian) ; aucun ticket identifiable → demande-le avant de continuer
- Commits : `git log <défaut>..HEAD --format="%h %s"` ; URL HTTPS du remote pour les liens `<base>/commit/<sha>`
- Diff : vérifie que la description reflète ce qui a réellement été implémenté
- PR ouverte sur la branche (MCP GitHub, sinon `gh pr list --head <branche> --state open`) ? → mise à jour, sinon création

## Étape 2 — Description

Titre `[Type] Titre de l'issue (#XX)`. Body :

```markdown
## Contexte

Lien vers l'issue et pourquoi ce changement est nécessaire, en 1-2 phrases.

Closes #XX            ← ou `Ticket : [PROJ-42](url)` ; Jira avec ticket parent de version : ajouter `Version cible : 0.5.2`

## Ce qui a été fait

L'approche en prose courte : le comment et les arbitrages, pas la liste des fichiers ni des commits.

## Changelog

### Added
- Effet observable pour le consommateur, une phrase ([`abc1234`](url/commit/abc1234), [`def5678`](url/commit/def5678))

### Fixed
- Effet observable pour le consommateur, une phrase ([`9a8b7c6`](url/commit/9a8b7c6))

## À vérifier à la main

Uniquement ce que ni les tests ni la CI ne couvrent (rendu navigateur, media query, parcours réel). Section omise s'il n'y a rien.
```

Bloc Changelog : Read `${CLAUDE_SKILL_DIR}/../pipe-changelog/entree.md` et applique-le — types Keep a Changelog, une phrase par effet observable, références vers les commits en fin de ligne ; un commit ajouté en itération réécrit l'entrée concernée, les commits sans impact consommateur n'y figurent pas.

## Étape 3 — Commentaire d'itération (mise à jour seulement)

Read `${CLAUDE_SKILL_DIR}/iteration.md` et applique son format aux commits poussés depuis la dernière mise à jour.

## Étape 4 — Confirmer puis soumettre

Canal : MCP GitHub ; absent → `gh pr create` / `gh pr edit` + `gh pr comment` (body par `--body-file`) ; ni l'un ni l'autre → affiche le body final et stop.

Affiche le contenu complet — création : `**PR à créer** — [Type] Titre (#XX)` / `type/XX-description → [branche par défaut]` / body / `Je crée cette PR ?` ; mise à jour : description réécrite + commentaire. Confirmé → crée (base : branche par défaut de workflow-config) ou met à jour et poste le commentaire ; affiche `PR créée : [URL]` ou `PR mise à jour : [URL]`. Body avec de vrais sauts de ligne.

Fin de cycle : supprime le pilotage de la branche s'il existe, dis-le en une ligne, puis :

```
PR soumise vers [branche par défaut] — cycle du ticket terminé.
Quand assez de features sont mergées : `/pipe-release`, puis `/pipe-tag` après déploiement.
```

---

## Input utilisateur

$ARGUMENTS
