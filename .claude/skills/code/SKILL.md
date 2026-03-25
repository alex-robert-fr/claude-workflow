---
name: code
description: Implementer du code a partir d'un plan ou d'une issue. Cree la branche, ecrit le code, commit chaque etape. Utiliser apres /prepare-plan ou avec un numero d'issue.
argument-hint: [numero issue ou rien si plan deja present]
---

Lis `.claude/skills/_workflow-persona/SKILL.md` avant de commencer.

---

### Resolution du plan

Le plan peut venir de trois sources (par ordre de priorite) :

1. **Fichier de plan** — cherche dans `.claude/plans/` un fichier correspondant a l'issue ou au contexte. Si trouve, lis-le et utilise-le.
2. **Conversation courante** — si `/prepare-plan` a ete lance dans cette session, le plan est dans la conversation.
3. **Argument issue** — si un numero d'issue est passe et qu'aucun plan n'existe, lance `/prepare-plan` d'abord.

---

## Etape 0 — Verifications

Lis `.claude/skills/tech-stack/SKILL.md` puis verifie :

- [ ] Le repo a un remote `origin` configure
- [ ] Le working tree est propre (pas de changements non commites qui bloqueraient un checkout)
- [ ] La branche par defaut definie dans `tech-stack` (section Git) existe localement ou sur le remote
- [ ] Un plan est disponible (fichier, conversation ou issue a planifier)

Si une verification echoue, signale-le clairement et arrete-toi. Ne tente pas de contourner.

## Etape 1 — Creer la branche

Lis `.claude/skills/git-conventions/SKILL.md` (section Branches) puis cree une branche depuis la **branche par defaut** definie dans `tech-stack` (section Git) en suivant la convention.

Annonce la branche creee avant de commencer.

## Etape 2 — Implementer

Suis les etapes du plan dans l'ordre. Pour chaque etape :

### Regles de code

Respecte les conventions definies dans le skill `tech-stack` (deja lu).

Ne fais PAS de verification de style ou de formatage — c'est le role des hooks PostToolUse (lint/format automatique apres chaque ecriture) et de `/review` (verification par sub-agent).

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

## Etape 3 — Recap final

Une fois tout le code ecrit, affiche le recap :

```
## Implementation terminee — #XX

### Fichiers crees
- chemin/fichier.ts

### Fichiers modifies
- chemin/fichier.ts

### Commits
- emoji type(scope): description
- emoji type(scope): description
```

Propose la suite du pipeline :

```
---
Code termine. Prochaine etape : `/review` pour la review automatique.
```

---

## Input utilisateur

$ARGUMENTS
