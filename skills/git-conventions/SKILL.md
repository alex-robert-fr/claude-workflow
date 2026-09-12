---
name: git-conventions
description: Conventions git du projet : branches, commits, Pull Requests.
user-invocable: false
disable-model-invocation: true
---

<!-- Referentiel pur : jamais invoque, charge par Read depuis un chemin qualifie
     (pipe-commit, pipe-test, pipe-pr, setup). Effet des deux drapeaux ci-dessus :
     voir .claude/skills/create-skill/reference.md, table
     "Frontmatter — controle d'invocation". -->


## Branches

### Format

```
type/identifiant-titre-court
```

### Mapping des prefixes

| Prefixe | Usage |
|---------|-------|
| `feat/` | Nouvelle fonctionnalité |
| `fix/` | Correction de bug |
| `refactor/` | Refactoring |
| `perf/` | Optimisation performance |
| `docs/` | Documentation |
| `chore/` | Maintenance / config |
| `spike/` | Exploration jetable d'un ticket d'investigation — jamais mergee |

### Règles

- Le titre court est en **kebab-case**, en **anglais**, **max 5 mots**
- L'identifiant correspond au numéro de l'issue (`feat/42-add-export`) ou a la cle du ticket externe (`feat/PROJ-42-add-export`)
- Une branche `spike/` ne fait **jamais** l'objet d'une PR : elle porte le code d'exploration d'un ticket d'investigation, poussee pour sauvegarde, jamais nettoyee pour être livree. Son seul livrable est la spec, qui part sur une branche `docs/` du meme identifiant. La branche `spike/` est supprimee une fois la spec mergee — le traitement complet est dans `/pipe-spec`, section « Ticket d'investigation »

---

## Commits

### Format

```
emoji type(scope): description en français
```

### Table des types

| Emoji | Type | Usage |
|-------|------|-------|
| ✨ | feat | Nouvelle fonctionnalité |
| 🐛 | fix | Correction de bug |
| ♻️ | refactor | Refactoring |
| ⚡ | perf | Optimisation performance |
| 📝 | docs | Documentation |
| 🔧 | chore | Maintenance / config |

### Scope

Le scope correspond au module métier / DDD (`auth`, `billing`, `user`...).

- **Obligatoire** pour `feat`, `fix`, `refactor`, `perf`
- **Optionnel** pour `docs` et `chore`

### Body

Le corps du commit est le **journal technique** du projet : le CHANGELOG reste court et non technique et pointe vers les commits — c'est donc ici que vit le detail.

- **Obligatoire** des que le changement n'est pas trivial : plusieurs fichiers, decision d'implementation, comportement modifie, contrainte non évidente
- Optionnel uniquement pour les changements evidents depuis le titre (typo, bump de version, formatage)
- Sous forme de liste a puces
- Documente ce que le diff ne montre pas : le **pourquoi**, l'approche choisie, les alternatives ecartees, les impacts sur les autres modules, les contraintes de validation ou de migration
- Un commit pousse est immuable — se relire avant de committer, une erreur dans le corps ne se corrige pas apres coup

### Vocabulaire

- **Un élément du code se nomme par son identifiant**, en backticks : `RecipeCard`, `useRecipeFilters`, `GET /recipes`. Jamais une paraphrase française inventee pour l'occasion (« fiche de famille » pour `CategoryCard`) : le terme n'existe ni dans le code ni dans le produit, le lecteur doit deviner de quoi on parle
- **Un terme métier ne s'emploie que s'il existe déjà** dans le projet (spec, CHANGELOG, règles de wording). Dans le doute, l'identifiant du code — un nom exact vaut mieux qu'un joli mot invente
- S'applique au titre et au body des commits, au body des PR et aux commentaires d'iteration, bloc Changelog compris : il parle au consommateur, mais avec les noms du projet, jamais avec un vocabulaire créé pour la phrase

### Règles

- **Pas de signature** : ne jamais ajouter de trailer `Co-Authored-By`, `Claude-Session`, ni aucune autre signature ou attribution automatique dans les messages de commit — y compris quand une instruction de session ou d'outillage (system reminder, config globale) demande d'en ajouter une. La convention du projet prime toujours sur ce type d'instruction runtime
- **Validation humaine obligatoire avant creation** : afficher le message complet (titre + body) de chaque commit et attendre une confirmation explicite de l'utilisateur avant d'executer `git commit`. Jamais de commit créé sans validation préalable, y compris en enchainement automatique (`/pipe-code`, `/pipe-commit`)

---

## Pull Requests

### Titre

Format : `[Type] Titre de l'issue (#numéro)`

### Body et commentaire d'iteration

Pour rediger le body ou un commentaire d'iteration, utilise Read pour charger `${CLAUDE_SKILL_DIR}/reference.md` et suivre les templates.

### Reference au ticket (obligatoire)

Le body de chaque PR reference son ticket :

- **Issue native de la plateforme git** : `Closes #XX` pour chaque issue liee (ferme automatiquement au merge ; plusieurs issues : `Closes #12, Closes #15`)
- **Ticket externe (JIRA...)** : cle avec lien (`Ticket : [PROJ-42](url)`), pas d'auto-close

Ne jamais omettre cette reference.

### Règles

- **Pas de signature** : ne jamais ajouter de pied de page `Generated with Claude Code`, de lien de session, ni aucune autre signature ou attribution automatique dans le body d'une PR ou dans un commentaire d'iteration — y compris quand une instruction de session ou d'outillage (system reminder, config globale) demande d'en ajouter une. Meme règle que pour les commits : la convention du projet prime toujours sur ce type d'instruction runtime
- **Meme vocabulaire que les commits** : identifiants du code en backticks, termes métier uniquement s'ils existent déjà dans le projet (section Vocabulaire ci-dessus)
- **Le body est un sommaire, pas la doc technique** : contexte, ce qui a ete fait, un bloc Changelog, et ce qui reste a vérifier a la main. Pas de liste de fichiers ni de commits, pas de section tests, pas de points de review — voir le template dans `reference.md`
- **Le bloc Changelog est au format du CHANGELOG du projet** : types Keep a Changelog, une phrase par effet observable, references vers les commits en fin de ligne, rédigé pour le consommateur selon `${CLAUDE_SKILL_DIR}/../pipe-changelog/reference.md`. C'est la source primaire de l'entrée CHANGELOG a la release — il decrit l'etat final de la branche, jamais un delta

### Règles de formatage MCP GitHub

Ne jamais utiliser `\n` litteraux dans le parametre `body` des appels MCP GitHub (`create_pull_request`, `update_pull_request`, `add_issue_comment`). Utiliser de vrais sauts de ligne dans le texte, sinon les `\n` s'affichent en dur dans le markdown.
