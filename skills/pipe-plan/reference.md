# Pipe Plan — References

## Detection de l'environnement et recuperation du ticket

Section commune a `/pipe-plan` et `/pipe-spec`.

### Plateforme git

Recupere l'URL du remote origin (`git remote get-url origin`) et deduis la plateforme :

| Domaine | Plateforme | MCP |
|---------|-----------|-----|
| `github.com` | GitHub | `mcp__github__` |
| `gitlab.com` ou `gitlab.*` | GitLab | `mcp__gitlab__` |
| Autre | Gitea | `mcp__gitea__` |

Si `.claude/skills/workflow-config/SKILL.md` existe, sa configuration a priorité sur la detection automatique.

### Tracker externe (optionnel)

Si l'argument ressemble à une clé de projet externe ou si le workflow-config mentionne un tracker, utilise le MCP correspondant. La forme `ABC-123` (lettres majuscules-tiret-chiffres) est ambiguë : Jira (`PROJ-123`) et Linear (`ENG-123`) partagent exactement le même format, elle ne suffit pas seule à trancher. Ordre de résolution :

| Priorité | Signal | Tracker | MCP |
|----------|--------|---------|-----|
| 1 | Champ "Issue tracker" de `.claude/skills/workflow-config/SKILL.md` = Jira | JIRA | `mcp__atlassian__` |
| 1 | Champ "Issue tracker" = Linear | Linear | `mcp__linear__` |
| 2 | URL `*.atlassian.net/*` | JIRA | `mcp__atlassian__` |
| 2 | URL `linear.app/*` | Linear | `mcp__linear__` |
| 3 (repli) | Forme `ABC-123` seule — champ "Issue tracker" vide et aucune URL disponible | JIRA (défaut) | `mcp__atlassian__` |

Si le MCP nécessaire n'est pas configuré, signale-le et propose des alternatives.

Si aucun tracker externe n'est détecté, le ticket vient de la plateforme git.

### Verifications

- [ ] Le repo a un remote `origin` configure
- [ ] L'argument permet d'identifier un ticket (numéro, URL, cle ou texte)
- [ ] Le MCP nécessaire est disponible (sinon, signale-le et propose des alternatives)

Si une verification echoue, signale-le clairement et arrete-toi.

### Formes de l'argument

- `42` ou `#42` → issue sur la plateforme git detectee, via le MCP correspondant
- `https://github.com/org/repo/issues/42` → extrais plateforme, org, repo, numéro depuis l'URL
- `https://gitlab.com/org/repo/-/issues/42` → idem pour GitLab
- `https://org.atlassian.net/browse/PROJ-42` → ticket JIRA via MCP Atlassian
- `PROJ-42` → cle JIRA, utilise le MCP Atlassian
- Texte libre → recherche dans les issues ouvertes du repo, confirme avec l'utilisateur si ambigu

Recupere le ticket complet (titre, body, labels/tags, commentaires pertinents).

### Hierarchie JIRA

Les tickets JIRA sont souvent organises en epic → ticket de version (ex: `0.5.2`) → demandes métier. Si le tracker est JIRA, remonte la hierarchie du ticket :

- **Version cible** : le ticket parent, si son nom ressemble a une version
- **Epic** : l'epic de rattachement, si elle existe

Non recopiees dans le pilotage — seul l'identifiant y figure (regle commune : `${CLAUDE_SKILL_DIR}/../../shared/pilotage-template.md`).

## Fichier de pilotage

Template, nommage et règles de tenue : `${CLAUDE_SKILL_DIR}/../../shared/pilotage-template.md` — partage avec `/pipe-spec`, qui crée le fichier.

## Template de plan technique

```markdown
## Plan — [Titre du ticket] (#XX / PROJ-XX)

**Classification :** technique | métier | mixte

### Vue d'ensemble
- **Avant** : ce qui pose problème aujourd'hui
- **Apres** : ce que ca donnera une fois fait

### Approche technique
- Fonction cle et ou elle vit : `nomFonction()` dans [fichier.ts](chemin/relatif)
- Alternative ecartee — pourquoi

### Étapes d'implementation

#### 1. [fichier.ts](chemin/vers/fichier.ts) — créer | modifier | supprimer

Une phrase : a quoi sert ce fichier, dans le langage du produit.

```
Label aligne      : valeur ou signature
Si condition      : comportement
nomFonction(param: Type): TypeRetour
```

#### 2. [autre.ts](chemin/vers/autre.ts) — créer | modifier | supprimer
...

### Tests

**[fichier.spec.ts](chemin/vers/fichier.spec.ts)**
- Comportement teste, une ligne
- Un autre comportement, une ligne

**[autre.spec.ts](chemin/vers/autre.spec.ts)**
- Comportement teste

### Points d'attention
- **Idee cle en gras** — le reste de l'explication
- **Effet de bord ou zone sensible** — pourquoi ca merite l'attention

### Recapitulatif des fichiers

| Fichier | Action | Description |
|---------|--------|-------------|
| [fichier.ts](chemin/fichier.ts) | créer | Breve description |
| [autre.ts](chemin/autre.ts) | modifier | Ce qui change |
```

## Règles

- Les chemins de fichiers doivent correspondre a la structure reelle du projet (vérifiés lors de l'exploration)
- Si un fichier n'existe pas encore, indique-le : `(a créer)`
- Pas d'étape floue — si tu ne sais pas comment implementer quelque chose, dis-le explicitement
- Ordre des étapes = ordre logique d'implementation (dependances d'abord)
- **Pas de code implemente** dans le plan (pas de corps de fonction, pas de logique) — le code sera ecrit par `/pipe-code`. Un bloc ``` est en revanche autorise par étape pour lister signatures et comportements de facon structuree (format `Label : valeur`, un par ligne) : plus lisible qu'une liste a puces quand plusieurs signatures ou branches de comportement s'enchainent. La phrase d'intro en langage naturel reste obligatoire avant le bloc
- **Pas de schema** dans le plan — contrairement a la spec, ca embrouille plus que ca n'aide ici
- **Budget : 80-120 lignes** pour un ticket simple, 150 max pour un ticket decompose. Si le plan depasse, c'est probablement qu'il contient du code ou des details d'implementation qui appartiennent a `/pipe-code`

## Critères de classification

| Type | Signaux | Exemples |
|------|---------|----------|
| **Technique** | refactor, migration, perf, CI, lint, deps, infra, dette, tooling | "Migrer de Express a Fastify", "Ajouter le linting" |
| **Métier** | utilisateur, fonctionnalité, UX, dashboard, ecran, bouton, workflow, export | "Ajouter un graphique de suivi", "Export CSV" |
| **Mixte** | Besoin métier + changement architectural significatif | "Ajouter l'authentification OAuth" (login user + couche auth) |

Le type **mixte** est le plus fréquent en pratique : la plupart des features métier impliquent du travail technique. Reserve **technique pur** aux tickets sans impact utilisateur visible, et **métier pur** aux tickets qui n'ajoutent pas de nouvelle couche technique.

## Guide de decomposition

### Quand decomposer

Un ticket merite d'être decompose quand :
- Il touche **>3 modules** distincts
- Il impacte **>2 couches** d'architecture (data, domaine, API, UI)
- Il contient **plusieurs features independantes** emballees ensemble
- Son implementation depasse ce qu'une seule session `/pipe-code` peut couvrir

### Principes de decoupage

- Chaque sous-ticket est **implementable independamment** et apporte de la valeur
- L'ordre respecte les **dependances** (schema DB avant API, API avant UI)
- Les sous-tickets techniques precedent les sous-tickets métier quand ils sont pre-requis
- Chaque sous-ticket a un **critère d'acceptance clair**
- Classifier chaque sous-ticket independamment (technique, métier ou mixte)

### Format de sortie pour un ticket decompose

1. **Liste des sous-tickets** avec pour chacun : classification, titre, 1-2 lignes de description, dependances
2. **Plan detaille uniquement pour le sous-ticket 1** (le template complet ci-dessus)
3. Les sous-tickets suivants seront planifies via `/pipe-plan` au moment de les implementer

### Exemple

Ticket : "Ajouter un système de notifications temps reel"

1. **[Technique]** Mettre en place le serveur WebSocket — infra de base, depend de rien
2. **[Technique]** Creer le modele Notification en base — schema + migration, depend de rien
3. **[Mixte]** Implementer l'API de notifications — CRUD + logique métier, depend de 1 et 2
4. **[Métier]** Ajouter le composant notifications dans l'UI — bell + dropdown, depend de 3
5. **[Métier]** Ajouter les preferences de notification utilisateur — settings, depend de 3

→ Plan detaille pour le sous-ticket 1 uniquement. Les autres seront planifies ensuite.
