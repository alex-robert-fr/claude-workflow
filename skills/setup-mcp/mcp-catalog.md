# Catalogue MCP

Reference des serveurs MCP connus et leur configuration type pour `.mcp.exemple.json`.

## Format de detection

Le pattern de detection dans les skills est `mcp__<serveur>__` (ex: `mcp__github__create_issue`).
La partie `<serveur>` est extraite et matchee contre les cles de ce catalogue.

---

## github

**Nom** : GitHub (officiel)
**Detection** : `mcp__github__`
**Package** : `@modelcontextprotocol/server-github`

```json
{
  "github": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-github"],
    "env": {
      "GITHUB_PERSONAL_ACCESS_TOKEN": "<YOUR_GITHUB_TOKEN>"
    }
  }
}
```

**Scopes requis** : `repo`, `read:org`, `project`

---

## gitea

**Nom** : Gitea
**Detection** : `mcp__gitea__`
**Package** : `gitea-mcp`

```json
{
  "gitea": {
    "command": "npx",
    "args": ["-y", "gitea-mcp"],
    "env": {
      "GITEA_URL": "<YOUR_GITEA_INSTANCE_URL>",
      "GITEA_TOKEN": "<YOUR_GITEA_TOKEN>"
    }
  }
}
```

---

## gitlab

**Nom** : GitLab (officiel)
**Detection** : `mcp__gitlab__`
**Package** : `@modelcontextprotocol/server-gitlab`

```json
{
  "gitlab": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-gitlab"],
    "env": {
      "GITLAB_PERSONAL_ACCESS_TOKEN": "<YOUR_GITLAB_TOKEN>",
      "GITLAB_API_URL": "https://gitlab.com/api/v4"
    }
  }
}
```

---

## atlassian

**Nom** : Atlassian (Jira / Confluence)
**Detection** : `mcp__atlassian__`
**Package** : `@anthropic/atlassian-mcp`

```json
{
  "atlassian": {
    "command": "npx",
    "args": ["-y", "@anthropic/atlassian-mcp"],
    "env": {
      "ATLASSIAN_SITE_URL": "<YOUR_ATLASSIAN_SITE_URL>",
      "ATLASSIAN_USER_EMAIL": "<YOUR_ATLASSIAN_EMAIL>",
      "ATLASSIAN_API_TOKEN": "<YOUR_ATLASSIAN_API_TOKEN>"
    }
  }
}
```

---

## slack

**Nom** : Slack
**Detection** : `mcp__slack__`
**Package** : `@anthropic/slack-mcp`

```json
{
  "slack": {
    "command": "npx",
    "args": ["-y", "@anthropic/slack-mcp"],
    "env": {
      "SLACK_BOT_TOKEN": "<YOUR_SLACK_BOT_TOKEN>"
    }
  }
}
```

---

## Ajouter un nouveau MCP

Pour ajouter un MCP au catalogue, ajouter une section avec :

1. Un titre `## nom` (correspondant a la cle dans `mcpServers`)
2. Le pattern de detection `mcp__nom__`
3. Le bloc JSON complet avec placeholders `<DESCRIPTION>`
4. Les scopes ou permissions requis si applicable
