---
name: create-issue
description: Creer des issues GitHub structurees depuis une demande : decoupage, critères d'acceptance, labels.
argument-hint: [description de ce qu'il faut faire]
---

## Étape 0 — Verifications

- [ ] Le repo a un remote `origin` configure
- [ ] L'utilisateur a fourni une description de ce qu'il veut créer

Si une verification echoue, signale-le clairement et arrete-toi.

## Étape 1 — Détecter le repo courant

Utilise le MCP GitHub pour identifier le repo actif a partir du remote Git (`origin`). Toutes les issues seront créées dans ce repo.

## Étape 2 — Analyser la demande

Lis attentivement ce que l'utilisateur decrit. Evalue si c'est **une seule issue ou plusieurs**.

Si la demande couvre plusieurs domaines ou natures, utilise Read pour charger `${CLAUDE_SKILL_DIR}/reference.md` (règles de decoupage).

Principe : en cas de doute, prefere **decouper** — une issue trop petite est moins grave qu'une issue fourre-tout.

## Étape 3 — Rediger les issues

Pour **chaque issue** identifiee, rédige un titre et un body structures.

**Titre** : court, précis, en français. Format : `[Type] Description concise`
Types : `[Bug]`, `[Feature]`, `[Refactor]`, `[Chore]`, `[Docs]`, `[Perf]`

**Body** : utilise Read pour charger `${CLAUDE_SKILL_DIR}/reference.md` (template body avec sections Contexte, Description, Critères d'acceptance, Notes techniques).

## Étape 4 — Recapituler avant de créer

Affiche le recap de toutes les issues puis demande confirmation : **"Je crée ces N issues sur GitHub ?"**

## Étape 5 — Creer les issues via MCP GitHub

Une fois confirmation recue, crée chaque issue via le MCP GitHub dans l'ordre logique (dependances d'abord).

- Assigne le label correspondant au type (utilise Read pour charger `${CLAUDE_SKILL_DIR}/reference.md` si besoin de la table de correspondance). Si le label n'existe pas encore sur le repo, crée-le.
- Si l'issue depend d'une autre, ajoute `Depend de #X` dans la section Contexte du body
- Affiche l'URL retournee

---

## Input utilisateur

$ARGUMENTS
