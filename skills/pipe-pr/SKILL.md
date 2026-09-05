---
name: pipe-pr
description: Creer ou mettre a jour une Pull Request : titre, description, commentaire d'iteration. Apres /pipe-commit.
argument-hint: [rien — detecte automatiquement la branche courante]
---

## Etape 0 — Verifications

Utilise Read pour charger `.claude/skills/workflow-config/SKILL.md` (si absent, utilise Read pour charger `.claude/skills/tech-stack/SKILL.md` — config legacy). Puis verifie :

- [ ] Le repo a un remote `origin` configure
- [ ] La branche courante n'est pas la branche par defaut (on ne cree pas de PR depuis main/develop)
- [ ] Il y a au moins un commit d'avance sur la branche par defaut

Si une verification echoue, signale-le clairement et arrete-toi.

### Push

Si la branche n'est pas encore poussee sur le remote, pousse-la. Confirme avant de push si c'est le premier push de cette branche. Ne commente pas le push : la sortie de la commande le montre deja.

## Etape 1 — Recuperer le contexte

Rassemble les informations necessaires :

- **Branche courante** — detectee automatiquement
- **Pilotage** — si un fichier `.claude/plans/plan-*.md` correspond a la branche, lis-le : ticket (cle JIRA ou issue), version cible, decisions — c'est la source principale du contexte
- **Ticket lie** — depuis le pilotage, ou l'identifiant dans le nom de branche (`feat/42-...` → issue #42 via MCP GitHub ; `feat/PROJ-42-...` → ticket JIRA via MCP Atlassian)
- **Commits** — la liste des commits de la branche avec leur SHA court (`git log <defaut>..HEAD --format="%h %s"`) : ils alimentent le bloc Changelog du body, chaque entree pointant vers ses commits
- **URL du remote** — `git remote get-url origin`, convertie en HTTPS : c'est la base des liens vers les commits (`<base>/commit/<sha>`)
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

### Changelog

Le body porte un bloc `## Changelog` au format du CHANGELOG du projet : c'est lui qui sera agrege a la release, ecrit maintenant, tant que le contexte est frais. Utilise Read pour charger `${CLAUDE_SKILL_DIR}/../pipe-changelog/reference.md` et applique ses sections « Types d'entrees », « Mapping prefixe de commit → type », « Regles de contenu », « Rediger pour le consommateur » et « Exclusions » :

- une entree = une phrase courte, un effet observable pour le consommateur, jamais un titre de commit recopie
- les commits qui composent le meme changement vu du consommateur donnent une seule entree ; les etats intermediaires de la branche (un fix sur un ajout de la meme branche) sont consolides en etat final
- chaque entree se termine par ses references : liens Markdown explicites vers les commits, SHA court, base URL du remote
- les commits sans impact consommateur (refactor, tests, docs contributeur) n'y figurent pas — la plateforme les liste deja dans l'onglet Commits
- les types apparaissent dans l'ordre impose, sans type vide

En mise a jour, le bloc est reecrit en etat final comme le reste de la description : un nouveau commit qui change un effet deja decrit reecrit son entree, il n'en ajoute pas une nouvelle.

## Etape 4 — Rediger le commentaire d'iteration (mise a jour uniquement)

Cette etape ne s'applique que si une PR existe deja. Sinon, passe directement a l'etape 5.

Recupere la liste complete des commits pushes depuis la derniere mise a jour de la PR. Redige le commentaire en suivant le format defini dans git-conventions.

## Etape 5 — Recapituler et confirmer

Affiche le contenu complet avant de soumettre et demande confirmation.

**Nouvelle PR :**

```
**PR a creer** — [Type] Titre de l'issue (#XX)
`type/XX-description` → `[branche par defaut du projet]`

[body complet]

Je cree cette PR ?
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
PR soumise vers [branche par defaut] — cycle du ticket termine.
Quand assez de features sont mergees : `/pipe-release`, puis `/pipe-tag` apres deploiement.
```

---

## Input utilisateur

$ARGUMENTS
