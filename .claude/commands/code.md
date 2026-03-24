Commence par lire `.claude/skills/shared/SKILL.md`.

---

### Si un plan est présent dans la conversation — Mode implémentation directe

Utilise le plan produit par `/plan` dans la conversation courante.

### Si un argument est passé — Mode issue

Récupère l'issue via MCP GitHub (ID, URL ou titre) et lance `/plan` avant de coder.

---

## Étape 0 — Vérifications

Lis `.claude/skills/code-conventions/SKILL.md` puis vérifie :

- [ ] Le repo a un remote `origin` configuré
- [ ] Le working tree est propre (pas de changements non commités qui bloqueraient un checkout)
- [ ] La branche par défaut définie dans `code-conventions` (section Git) existe localement ou sur le remote

Si une vérification échoue, signale-le clairement et arrête-toi. Ne tente pas de contourner.

## Étape 1 — Créer la branche

Lis `.claude/skills/branch-convention/SKILL.md` puis crée une branche depuis la **branche par défaut** définie dans `code-conventions` (section Git) en suivant la convention.

Annonce la branche créée avant de commencer.

## Étape 2 — Implémenter

Lis `.claude/skills/commit-convention/SKILL.md` puis suis les étapes du plan dans l'ordre. Pour chaque étape :

### Règles de code

Respecte les conventions définies dans le skill `code-conventions` (déjà lu).

### Convention de commit

Chaque étape du plan terminée = un commit. Respecte le format défini dans le skill `commit-convention` (déjà lu).

### Progression

Après chaque étape complétée et committée, affiche :

```
✅ Étape [N/total] — [Nom de l'étape]
Commit : emoji type(scope): description
Fichiers modifiés :
- chemin/vers/fichier.ts
```

Si une étape révèle un problème non anticipé dans le plan (fichier manquant, dépendance absente, incohérence), **stoppe et signale-le** avant de continuer :

```
⚠️ Problème détecté — [description précise]
Option A : [approche]
Option B : [approche]
Comment tu veux procéder ?
```

## Étape 3 — Vérifications finales

Une fois tout le code écrit :

- [ ] Pas de `console.log` de debug oublié
- [ ] Pas d'import inutilisé
- [ ] Les types TypeScript sont corrects et complets
- [ ] Les fichiers modifiés respectent les conventions du projet
- [ ] Si des tests existaient sur les fichiers touchés, ils sont toujours valides

Affiche le récap final :

```
## ✅ Implémentation terminée — #XX

### Fichiers créés
- chemin/fichier.ts

### Fichiers modifiés
- chemin/fichier.ts

### Points d'attention
[Ce que le reviewer devrait vérifier en priorité, ou ce qui sort de l'ordinaire]
```

## Étape 4 — Confirmer et push

Affiche un récap avant de pousser :

```
📤 Prêt à push :

Branche : feat/42-add-oauth-authentication
Commits : N commits
Remote  : origin

Je push sur le remote ?
```

Une fois confirmation reçue, pousse la branche :

```bash
git push -u origin <nom-de-branche>
```

## Étape 5 — PR

Vérifie via MCP GitHub si une PR ouverte existe déjà sur la branche courante :

- **Pas de PR existante** → propose de lancer `/pr` pour en créer une
- **PR existante** → lance `/pr` automatiquement pour mettre à jour la description et poster le commentaire d'itération

---

## Input utilisateur

$ARGUMENTS
