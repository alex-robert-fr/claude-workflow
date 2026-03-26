---
name: create-issue
description: Creer des issues GitHub structurees avec decoupage intelligent, criteres d'acceptance et labels. Utiliser pour transformer une demande en issues actionnables.
argument-hint: [description de ce qu'il faut faire]
---

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/../_workflow-persona/SKILL.md` avant de commencer.

---

## Etape 0 — Verifications

- [ ] Le repo a un remote `origin` configure
- [ ] L'utilisateur a fourni une description de ce qu'il veut creer

Si une verification echoue, signale-le clairement et arrete-toi.

## Etape 1 — Detecter le repo courant

Utilise le MCP GitHub pour identifier le repo actif a partir du remote Git (`origin`). Toutes les issues seront creees dans ce repo.

## Etape 2 — Analyser la demande

Lis attentivement ce que l'utilisateur decrit. Evalue si c'est **une seule issue ou plusieurs**.

Si la demande couvre plusieurs domaines ou natures, utilise Read pour charger `reference.md` (regles de decoupage).

Principe : en cas de doute, prefere **decouper** — une issue trop petite est moins grave qu'une issue fourre-tout.

## Etape 3 — Rediger les issues

Pour **chaque issue** identifiee, redige un titre et un body structures.

**Titre** : court, precis, en francais. Format : `[Type] Description concise`
Types : `[Bug]`, `[Feature]`, `[Refactor]`, `[Chore]`, `[Docs]`, `[Perf]`

**Body** : utilise Read pour charger `reference.md` (template body avec sections Contexte, Description, Criteres d'acceptance, Notes techniques).

## Etape 4 — Recapituler avant de creer

Affiche le recap de toutes les issues puis demande confirmation : **"Je cree ces N issues sur GitHub ?"**

## Etape 5 — Creer les issues via MCP GitHub

Une fois confirmation recue, cree chaque issue via le MCP GitHub dans l'ordre logique (dependances d'abord).

- Assigne le label correspondant au type (utilise Read pour charger `reference.md` si besoin de la table de correspondance). Si le label n'existe pas encore sur le repo, cree-le.
- Si l'issue depend d'une autre, ajoute `Depend de #X` dans la section Contexte du body
- Affiche l'URL retournee

---

## Input utilisateur

$ARGUMENTS
