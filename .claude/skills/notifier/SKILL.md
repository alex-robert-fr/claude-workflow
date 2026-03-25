---
name: notifier
description: Envoyer une notification apres creation ou mise a jour d'une PR. Utiliser apres /create-pr.
argument-hint: [URL de la PR ou rien si detectable depuis la branche]
---

Lis `.claude/skills/_workflow-persona/SKILL.md` avant de commencer.

---

## Etape 0 — Verifications

Lis `.claude/skills/workflow-config/SKILL.md` pour identifier le canal de notification configure.

- [ ] Un canal de notification est configure (section Notifications de `workflow-config`)
- [ ] Le MCP correspondant est disponible (Slack, etc.)

Si pas de canal configure :

```
Pas de canal de notification configure dans workflow-config.
Configure la section "Notifications" de `.claude/skills/workflow-config/SKILL.md` pour activer les notifications.
```

## Etape 1 — Identifier la PR

Si un argument est passe (URL), utilise-le directement.

Sinon, detecte la PR ouverte sur la branche courante via MCP GitHub/GitLab/Gitea.

Si aucune PR trouvee → signale-le et arrete-toi.

## Etape 2 — Collecter les infos

Recupere via le MCP correspondant :

- Titre de la PR
- URL
- Nombre de fichiers modifies
- Branche source → branche cible
- Issue liee (depuis le titre ou le body de la PR)
- Statut (ouverte, draft, etc.)

## Etape 3 — Envoyer la notification

Envoie via le MCP defini dans `workflow-config` (section Notifications) au canal configure.

Format du message :

```
🔀 PR : [Titre] (#XX)
[branche-source] → [branche-cible] · N fichiers
Issue : #XX
[URL]
```

## Etape 4 — Confirmation

```
Notification envoyee sur [canal].
---
Pipeline termine. La PR est prete pour review humaine.
```

---

## Input utilisateur

$ARGUMENTS
