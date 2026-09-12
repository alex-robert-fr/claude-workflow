---
name: pipe-pr
description: Creer ou mettre a jour une Pull Request : titre, description, commentaire d'iteration. Apres /pipe-commit.
argument-hint: [rien — detecte automatiquement la branche courante]
---

## Étape 0 — Verifications

Utilise Read pour charger `.claude/skills/workflow-config/SKILL.md` (si absent, utilise Read pour charger `.claude/skills/tech-stack/SKILL.md` — config legacy). Puis verifie :

- [ ] Le repo a un remote `origin` configure
- [ ] La branche courante n'est pas la branche par defaut (on ne crée pas de PR depuis main/develop)
- [ ] Il y a au moins un commit d'avance sur la branche par defaut

Si une verification echoue, signale-le clairement et arrete-toi.

### Push

Si la branche n'est pas encore poussee sur le remote, pousse-la. Confirme avant de push si c'est le premier push de cette branche. Ne commente pas le push : la sortie de la commande le montre déjà.

## Étape 1 — Récupérer le contexte

Rassemble les informations nécessaires :

- **Branche courante** — detectee automatiquement
- **Pilotage** — si un fichier `.claude/plans/plan-*.md` correspond a la branche, lis-le : identifiant du ticket, plan et ses points d'attention — c'est la source principale du contexte
- **Ticket lie** — depuis le pilotage, ou l'identifiant dans le nom de branche (`feat/42-...` → issue #42 via MCP GitHub ; `feat/PROJ-42-...` → ticket JIRA via MCP Atlassian)
- **Commits** — la liste des commits de la branche avec leur SHA court (`git log <defaut>..HEAD --format="%h %s"`) : ils alimentent le bloc Changelog du body, chaque entrée pointant vers ses commits
- **URL du remote** — `git remote get-url origin`, convertie en HTTPS : c'est la base des liens vers les commits (`<base>/commit/<sha>`)
- **Diff** — analyse les fichiers créés et modifies pour vérifier que la description reflete ce qui a reellement ete implemente

## Étape 2 — Vérifier si une PR existe déjà

Verifie via MCP GitHub si une PR ouverte existe déjà sur la branche courante. Le resultat determine si on crée une nouvelle PR ou si on met a jour l'existante.

## Étape 3 — Rediger la description

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/../git-conventions/SKILL.md` (section Pull Requests) puis rédige la description.

Que ce soit pour une nouvelle PR ou une mise a jour, la description suit le format defini dans git-conventions et doit toujours refleter l'etat actuel complet de la PR — jamais de mention "ajoute", "mis a jour" ou "nouveau". C'est le rôle du commentaire d'iteration (étape 4).

### Reference au ticket (obligatoire)

Format et regle : voir `${CLAUDE_SKILL_DIR}/../git-conventions/SKILL.md` (section "Reference au ticket"), déjà chargee ci-dessus — la reference se place dans la section Contexte.

Ajouts propres a ce skill : ticket JIRA rattache a une version cible (ticket parent) → ajoute aussi `Version cible : 0.5.2` ; aucun ticket identifiable → demande-le a l'utilisateur avant de continuer.

### Changelog

Le body porte un bloc `## Changelog` au format du CHANGELOG du projet : c'est lui qui sera agrege a la release, ecrit maintenant, tant que le contexte est frais. Utilise Read pour charger `${CLAUDE_SKILL_DIR}/../pipe-changelog/reference.md` et applique ses sections « Types d'entrées », « Mapping prefixe de commit → type », « Règles de contenu », « Rediger pour le consommateur » et « Exclusions ».

## Étape 4 — Rediger le commentaire d'iteration (mise a jour uniquement)

Cette étape ne s'applique que si une PR existe déjà. Sinon, passe directement a l'étape 5.

Recupere la liste complète des commits pushes depuis la dernière mise a jour de la PR. Redige le commentaire en suivant le format defini dans git-conventions.

## Étape 5 — Recapituler et confirmer

Affiche le contenu complet avant de soumettre et demande confirmation.

**Nouvelle PR :**

```
**PR a créer** — [Type] Titre de l'issue (#XX)
`type/XX-description` → `[branche par defaut du projet]`

[body complet]

Je crée cette PR ?
```

**Mise a jour :** affiche la description reecrite + le commentaire d'iteration, puis demande confirmation.

## Étape 6 — Soumettre via MCP GitHub

Une fois confirmation recue :

**Nouvelle PR :**

- Cree la PR via MCP GitHub (base: branche par defaut definie dans `workflow-config`, head: branche courante)

```
PR créée : [URL]
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
