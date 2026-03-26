---
name: setup-mcp
description: Generer un .mcp.exemple.json de reference avec detection automatique des MCP utilises. Utiliser pour configurer les MCP necessaires au projet.
user-invocable: true
argument-hint: [rien — detecte automatiquement]
---

Utilise Read pour charger `.claude/skills/_workflow-persona/SKILL.md` avant de commencer.

---

## Etape 0 — Verifications

- [ ] On est a la racine d'un projet (`.git/` existe)
- [ ] Le dossier `.claude/skills/` existe et contient des skills

Si une verification echoue, signale-le et arrete-toi.

## Etape 1 — Detecter les MCP utilises

Scanne tous les fichiers `.claude/skills/**/*.md` avec Grep pour le pattern `mcp__[a-z]+__`.

Extrais les noms de serveurs uniques (la partie entre le premier et le deuxieme `__`). Par exemple :
- `mcp__github__create_issue` → `github`
- `mcp__gitea__list_repos` → `gitea`

Utilise Read pour charger `mcp-catalog.md` et mapper chaque serveur detecte a sa configuration type.

Si un serveur detecte n'est pas dans le catalogue, signale-le :

```
MCP detecte mais absent du catalogue : [nom]
→ Tu peux l'ajouter manuellement dans .mcp.exemple.json
```

Affiche le recap de detection :

```
MCP detectes dans les skills :
- github (N references)
- gitea (N references)
```

## Etape 2 — Lire l'existant

Si `.mcp.exemple.json` existe deja a la racine du projet :
- Lis-le et identifie les serveurs deja presents dans `mcpServers`
- Compare avec les serveurs detectes
- Signale les nouveaux a ajouter et ceux deja presents

Si le fichier n'existe pas, passe directement a l'etape 3.

## Etape 3 — Generer ou mettre a jour le fichier

Construis le JSON avec la structure :

```json
{
  "mcpServers": {
    "serveur1": { ... },
    "serveur2": { ... }
  }
}
```

Pour chaque MCP detecte, insere la configuration du catalogue avec les placeholders.

**Regle absolue** : ne jamais lire, acceder ou modifier `.mcp.json`. Seul `.mcp.exemple.json` est manipule.

Affiche le contenu complet du fichier genere et demande confirmation avant d'ecrire :

```
Fichier .mcp.exemple.json a [creer | mettre a jour] :

[contenu JSON]

J'ecris ce fichier ?
```

## Etape 4 — Verifier le .gitignore

Verifie que `.mcp.json` est present dans `.gitignore` :

- Si `.gitignore` existe et contient deja `.mcp.json` → rien a faire
- Si `.gitignore` existe mais ne contient pas `.mcp.json` → ajoute-le
- Si `.gitignore` n'existe pas → cree-le avec `.mcp.json`

Signale l'action prise.

## Etape 5 — Instructions

Affiche les instructions pour le developpeur :

```
## Configuration MCP

Le fichier .mcp.exemple.json a ete [cree | mis a jour] avec N serveur(s) MCP.

### Pour configurer tes MCP :

1. cp .mcp.exemple.json .mcp.json
2. Edite .mcp.json et remplace les placeholders (<YOUR_...>) par tes vrais tokens
3. Ne commite jamais .mcp.json — il est dans le .gitignore
```

---

## Input utilisateur

$ARGUMENTS
