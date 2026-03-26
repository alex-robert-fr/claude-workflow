---
name: setup-ui-ux
description: Generer les conventions UI/UX specifiques a un projet. Pose des questions puis cree .claude/skills/ui-ux/SKILL.md avec les preferences visuelles, layouts, patterns d'interaction et composants. Utiliser une fois par projet pour definir l'identite UI.
argument-hint: [theme ou vide pour wizard interactif]
---

Utilise Read pour charger `.claude/skills/_workflow-persona/SKILL.md` avant de commencer.

---

## Etape 0 — Verifications

- [ ] On est a la racine d'un projet (`.git/` existe)
- [ ] Le dossier `.claude/skills/` existe

Si `.claude/skills/ui-ux/SKILL.md` existe deja, propose de le mettre a jour plutot que de l'ecraser.

Si `$ARGUMENTS` contient un theme (ex: `minimal`, `premium`, `enterprise`), pre-remplir les reponses en consequence et confirmer avec l'utilisateur au lieu de poser toutes les questions.

## Etape 1 — Questionnaire interactif

Utilise Read pour charger `reference.md` — il contient le questionnaire complet (8 sections) avec les options pour chaque groupe.

Pose les questions **un groupe a la fois** via AskUserQuestion. Pour chaque groupe, propose les options entre parentheses et un choix par defaut.

## Etape 2 — Generer le fichier

A partir des reponses, genere `.claude/skills/ui-ux/SKILL.md` avec ce frontmatter :

```yaml
---
name: ui-ux
description: Conventions UI/UX du projet. Utiliser lors de la creation d'interfaces, composants, ecrans et interactions pour respecter l'identite visuelle et les patterns d'interaction definis.
user-invocable: false
---
```

Le contenu doit :

- Etre structure en sections correspondant aux 8 axes
- Contenir les regles (ce qu'on fait) ET les anti-patterns (ce qu'on evite)
- Inclure un tableau recapitulatif en fin de fichier
- Ne jamais depasser 150 lignes

Si besoin d'un exemple de structure, utilise Read pour charger `reference.md` (section "Exemple de structure generee").

## Etape 3 — Confirmer et ecrire

Affiche le contenu complet du fichier genere et demande confirmation avant d'ecrire.

---

## Input utilisateur

$ARGUMENTS
