Commence par lire ces fichiers dans l'ordre :

1. `.claude/skills/shared.md`
2. `.claude/skills/pr-convention.md`
3. `.claude/skills/code-conventions.md`

---

## Étape 0 — Vérifications

Avant de commencer, vérifie :

- [ ] Le repo a un remote `origin` configuré
- [ ] La branche courante n'est pas la branche par défaut (on ne crée pas de PR depuis main/develop)
- [ ] Il y a au moins un commit d'avance sur la branche par défaut

Si une vérification échoue, signale-le clairement et arrête-toi.

## Étape 1 — Récupérer le contexte

Rassemble les informations nécessaires :

- **Branche courante** — détectée automatiquement
- **Issue liée** — récupère-la via MCP GitHub (depuis le numéro dans le nom de branche, ex: `feat/42-...` → issue #42)
- **Diff** — analyse les fichiers créés et modifiés pour comprendre ce qui a réellement été implémenté

## Étape 2 — Vérifier si une PR existe déjà

Vérifie via MCP GitHub si une PR ouverte existe déjà sur la branche courante. Le résultat détermine si on crée une nouvelle PR ou si on met à jour l'existante.

## Étape 3 — Rédiger la description

Que ce soit pour une nouvelle PR ou une mise à jour, la description suit le format défini dans le skill `pr-convention` et doit toujours refléter l'état actuel complet de la PR — jamais de mention "ajouté", "mis à jour" ou "nouveau". C'est le rôle du commentaire d'itération (étape 4).

## Étape 4 — Rédiger le commentaire d'itération (mise à jour uniquement)

Cette étape ne s'applique que si une PR existe déjà. Sinon, passe directement à l'étape 5.

Récupère la liste complète des commits pushés depuis la dernière mise à jour de la PR. Rédige le commentaire en suivant le format défini dans le skill `pr-convention`.

## Étape 5 — Récapituler et confirmer

Affiche le contenu complet avant de soumettre et demande confirmation.

**Nouvelle PR :**

```
---
📬 Pull Request à créer :

Titre : [Type] Titre de l'issue (#XX)
Base  : [branche par défaut du projet]
Head  : type/XX-description

[body complet]
---
Je crée cette PR sur GitHub ?
```

**Mise à jour :** affiche la description réécrite + le commentaire d'itération, puis demande confirmation.

## Étape 6 — Soumettre via MCP GitHub

Une fois confirmation reçue :

**Nouvelle PR :**

- Crée la PR via MCP GitHub (base: branche par défaut définie dans `code-conventions`, head: branche courante)

```
✅ PR créée : [URL]
```

**Mise à jour :**

- Mets à jour la description et poste le commentaire d'itération via MCP GitHub

```
✅ PR mise à jour : [URL]
```

---

## Input utilisateur

$ARGUMENTS
