# Détection de l'environnement et récupération du ticket

Chargé par `/pipe-plan` et `/pipe-spec`. La configuration du projet (`.claude/skills/workflow-config/SKILL.md`) a priorité sur toute détection automatique.

## Plateforme git

Depuis `git remote get-url origin` :

| Domaine | Plateforme | MCP |
|---------|-----------|-----|
| `github.com` | GitHub | `mcp__github__` |
| `gitlab.com` ou `gitlab.*` | GitLab | `mcp__gitlab__` |
| Autre | Gitea | `mcp__gitea__` |

## Tracker externe

La forme `ABC-123` est ambiguë (Jira et Linear partagent le format). Ordre de résolution :

| Priorité | Signal | Tracker | MCP |
|----------|--------|---------|-----|
| 1 | Champ « Issue tracker » de workflow-config | Jira ou Linear | `mcp__atlassian__` ou `mcp__linear__` |
| 2 | URL `*.atlassian.net/*` / `linear.app/*` | Jira / Linear | idem |
| 3 (repli) | Forme `ABC-123` seule | Jira | `mcp__atlassian__` |

Aucun tracker externe → le ticket vient de la plateforme git. MCP nécessaire absent → le signaler, proposer des alternatives.

## Formes de l'argument

- `42` ou `#42` → issue de la plateforme git détectée
- URL d'issue GitHub / GitLab → plateforme, org, repo, numéro extraits de l'URL
- `https://org.atlassian.net/browse/PROJ-42` ou `PROJ-42` → ticket Jira
- Texte libre → recherche dans les issues ouvertes, confirmation si ambigu

Récupère le ticket complet : titre, body, labels, commentaires pertinents.

## Vérifications

Remote `origin` configuré ; argument qui identifie un ticket ; MCP disponible. Une vérification échoue → une ligne, stop.

## Hiérarchie Jira

Souvent epic → ticket de version (ex. `0.5.2`) → demandes métier. Remonte la hiérarchie : version cible (ticket parent dont le nom ressemble à une version), epic de rattachement. Rien n'est recopié dans le pilotage — seul l'identifiant y figure ; la version cible sert au journal des specs et à la Pull Request.
