---
name: code
description: Implementer du code a partir d'un plan ou d'une issue. Cree la branche, ecrit le code, commit chaque etape. Utiliser apres /prepare-plan ou avec un numero d'issue.
argument-hint: [numero issue ou rien si plan deja present]
---

Lis `.claude/skills/workflow-persona/SKILL.md` avant de commencer.

---

### Si un plan est present dans la conversation — Mode implementation directe

Utilise le plan produit par `/prepare-plan` dans la conversation courante.

### Si un argument est passe — Mode issue

Recupere l'issue via MCP GitHub (ID, URL ou titre) et lance `/prepare-plan` avant de coder.

---

## Etape 0 — Verifications

Lis `.claude/skills/tech-stack/SKILL.md` puis verifie :

- [ ] Le repo a un remote `origin` configure
- [ ] Le working tree est propre (pas de changements non commites qui bloqueraient un checkout)
- [ ] La branche par defaut definie dans `tech-stack` (section Git) existe localement ou sur le remote

Si une verification echoue, signale-le clairement et arrete-toi. Ne tente pas de contourner.

## Etape 1 — Creer la branche

Lis `.claude/skills/git-conventions/SKILL.md` (section Branches) puis cree une branche depuis la **branche par defaut** definie dans `tech-stack` (section Git) en suivant la convention.

Annonce la branche creee avant de commencer.

## Etape 2 — Implementer

Suis les etapes du plan dans l'ordre. Pour chaque etape :

### Regles de code

Respecte les conventions definies dans le skill `tech-stack` (deja lu).

### Commits atomiques

Chaque etape du plan terminee = un commit. Lis `.claude/skills/git-conventions/SKILL.md` (section Commits) pour le format.

### Progression

Apres chaque etape completee et committee, affiche :

```
Etape [N/total] — [Nom de l'etape]
Commit : emoji type(scope): description
Fichiers modifies :
- chemin/vers/fichier.ts
```

Si une etape revele un probleme non anticipe dans le plan (fichier manquant, dependance absente, incoherence), **stoppe et signale-le** avant de continuer :

```
Probleme detecte — [description precise]
Option A : [approche]
Option B : [approche]
Comment tu veux proceder ?
```

## Etape 3 — Verifications finales

Une fois tout le code ecrit :

- [ ] Pas de `console.log` de debug oublie
- [ ] Pas d'import inutilise
- [ ] Les types TypeScript sont corrects et complets
- [ ] Les fichiers modifies respectent les conventions du projet
- [ ] Si des tests existaient sur les fichiers touches, ils sont toujours valides

Affiche le recap final :

```
## Implementation terminee — #XX

### Fichiers crees
- chemin/fichier.ts

### Fichiers modifies
- chemin/fichier.ts

### Points d'attention
[Ce que le reviewer devrait verifier en priorite, ou ce qui sort de l'ordinaire]
```

## Etape 4 — Push et PR

Affiche un recap avant de pousser :

```
Pret a push :

Branche : feat/42-add-oauth-authentication
Commits : N commits
Remote  : origin

Je push sur le remote ?
```

Une fois confirmation recue, pousse la branche puis propose de lancer `/create-pr`.

---

## Input utilisateur

$ARGUMENTS
