---
name: pipe-pr
description: Creer ou mettre a jour une Pull Request. Genere titre, description et commentaire d'iteration selon les conventions, avec les infos du ticket (JIRA ou issue), la version cible et les changesets. Utiliser apres /pipe-commit ou pour soumettre une branche.
argument-hint: [rien — detecte automatiquement la branche courante]
---

## Etape 0 — Verifications

Utilise Read pour charger `.claude/skills/workflow-config/SKILL.md` (si absent, utilise Read pour charger `.claude/skills/tech-stack/SKILL.md` — config legacy). Puis verifie :

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
- **Pilotage** — si un fichier `.claude/plans/plan-*.md` correspond a la branche, lis-le : ticket (cle JIRA ou issue), version cible, decisions — c'est la source principale du contexte
- **Ticket lie** — depuis le pilotage, ou l'identifiant dans le nom de branche (`feat/42-...` → issue #42 via MCP GitHub ; `feat/PROJ-42-...` → ticket JIRA via MCP Atlassian)
- **Commits** — la liste des commits de la branche : ce sont les changesets, ils structurent la partie technique du body
- **Diff** — analyse les fichiers crees et modifies pour verifier que la description reflete ce qui a reellement ete implemente

## Etape 2 — Verifier si une PR existe deja

Verifie via MCP GitHub si une PR ouverte existe deja sur la branche courante. Le resultat determine si on cree une nouvelle PR ou si on met a jour l'existante.

## Etape 3 — Rediger la description

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/../git-conventions/SKILL.md` (section Pull Requests) puis redige la description.

Que ce soit pour une nouvelle PR ou une mise a jour, la description suit le format defini dans git-conventions et doit toujours refleter l'etat actuel complet de la PR — jamais de mention "ajoute", "mis a jour" ou "nouveau". C'est le role du commentaire d'iteration (etape 4).

### Reference au ticket (obligatoire)

Chaque PR reference son ticket dans la section Contexte, selon le tracker :

- **Issue native de la plateforme git** : `Closes #42` (ferme automatiquement l'issue au merge ; plusieurs issues → `Closes #12, Closes #15`)
- **Ticket JIRA** : pas d'auto-close — reference la cle avec son lien (`Ticket : [PROJ-42](url)`), et si le pilotage indique une version cible, ajoute `Version cible : 0.5.2`

Si aucun ticket n'est identifiable, demande-le a l'utilisateur avant de continuer — ne jamais omettre cette reference.

### Changesets

Le body liste les commits de la branche (titre de chaque commit) — c'est le sommaire technique de la PR : le lecteur qui veut le detail ouvre le commit correspondant.

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

- Cree la PR via MCP GitHub (base: branche par defaut definie dans `workflow-config`, head: branche courante)

```
PR creee : [URL]
```

**Mise a jour :**

- Mets a jour la description et poste le commentaire d'iteration via MCP GitHub

```
PR mise a jour : [URL]
```

### Fin de cycle

Si un fichier de pilotage existe pour cette branche, **supprime-le** apres la creation de la PR (c'etait un document de travail — le cycle du ticket est termine) et signale-le en une ligne.

Propose la suite :

```
---
PR soumise vers [branche par defaut]. Cycle du ticket termine.
Quand assez de features sont mergees : `/pipe-release` pour preparer la release
vers la branche de production, puis `/pipe-tag` apres merge et deploiement.
```

---

## Input utilisateur

$ARGUMENTS
