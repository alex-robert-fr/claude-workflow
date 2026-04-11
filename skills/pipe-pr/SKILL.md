---
name: pipe-pr
description: Creer ou mettre a jour une Pull Request GitHub. Genere titre, description et commentaire d'iteration selon les conventions. Utiliser apres /pipe-code ou pour soumettre une branche.
model: sonnet
argument-hint: [rien — detecte automatiquement la branche courante]
---

## Contexte

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/../_workflow-persona/SKILL.md` avant de commencer.

---

## Etape 0 — Verifications

Utilise Read pour charger `.claude/skills/tech-stack/SKILL.md` puis verifie :

- [ ] Le repo a un remote `origin` configure
- [ ] La branche courante n'est pas la branche par defaut (on ne cree pas de PR depuis main/develop)
- [ ] Il y a au moins un commit d'avance sur la branche par defaut

Si une verification echoue, signale-le clairement et arrete-toi.

### Push

Si la branche n'est pas encore poussee sur le remote, pousse-la :

```
Push vers origin/[branche-courante]...
```

Confirme avant de push si c'est le premier push de cette branche.

## Etape 1 — Recuperer le contexte

Rassemble les informations necessaires :

- **Branche courante** — detectee automatiquement
- **Issue liee** — recupere-la via MCP GitHub (depuis le numero dans le nom de branche, ex: `feat/42-...` → issue #42)
- **Diff** — analyse les fichiers crees et modifies pour comprendre ce qui a reellement ete implemente

## Etape 2 — Verifier si une PR existe deja

Verifie via MCP GitHub si une PR ouverte existe deja sur la branche courante. Le resultat determine si on cree une nouvelle PR ou si on met a jour l'existante.

## Etape 3 — Rediger la description

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/../git-conventions/SKILL.md` (section Pull Requests) puis redige la description.

Que ce soit pour une nouvelle PR ou une mise a jour, la description suit le format defini dans git-conventions et doit toujours refleter l'etat actuel complet de la PR — jamais de mention "ajoute", "mis a jour" ou "nouveau". C'est le role du commentaire d'iteration (etape 4).

### Auto-close des issues (obligatoire)

Le body de la PR doit **toujours** contenir `Closes #XX` dans la section Contexte pour chaque issue liee. Cela ferme automatiquement les issues au merge.

- Une issue : `Closes #42`
- Plusieurs issues : `Closes #12, Closes #15`

Si aucune issue n'est identifiable depuis le nom de branche, demande le numero a l'utilisateur avant de continuer — ne jamais omettre cette ligne.

## Etape 4 — Rediger le commentaire d'iteration (mise a jour uniquement)

Cette etape ne s'applique que si une PR existe deja. Sinon, passe directement a l'etape 5.

Recupere la liste complete des commits pushes depuis la derniere mise a jour de la PR. Redige le commentaire en suivant le format defini dans git-conventions.

## Etape 5 — Recapituler et confirmer

Affiche le contenu complet avant de soumettre et demande confirmation.

**Nouvelle PR :**

```
---
Pull Request a creer :

Titre : [Type] Titre de l'issue (#XX)
Base  : [branche par defaut du projet]
Head  : type/XX-description

[body complet]
---
Je cree cette PR sur GitHub ?
```

**Mise a jour :** affiche la description reecrite + le commentaire d'iteration, puis demande confirmation.

## Etape 6 — Soumettre via MCP GitHub

Une fois confirmation recue :

**Nouvelle PR :**

- Cree la PR via MCP GitHub (base: branche par defaut definie dans `tech-stack`, head: branche courante)

```
PR creee : [URL]
```

**Mise a jour :**

- Mets a jour la description et poste le commentaire d'iteration via MCP GitHub

```
PR mise a jour : [URL]
```

Propose la suite :

```
---
PR soumise. Prochaines etapes :
- Apres merge sur main : `/pipe-tag [vX.Y.Z]` pour creer le tag de release.
- Ou directement : `/pipe-notifier` pour envoyer la notification de review.
```

---

## Input utilisateur

$ARGUMENTS
