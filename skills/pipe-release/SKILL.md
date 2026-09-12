---
name: pipe-release
description: Preparer une release : CHANGELOG métier, puis PR de la branche d'integration vers la production.
disable-model-invocation: true
argument-hint: "[version cible ex: 0.5.2, ou rien pour détecter]"
---

## Étape 0 — Verifications

Utilise Read pour charger `.claude/skills/workflow-config/SKILL.md` :

- **Branche d'integration** : champ "Branche par defaut" (ex: `develop`)
- **Branche de production** : champ "Branche de production" (ex: `main`)

Si aucune branche de production distincte n'est configuree, signale que le flux release ne s'applique pas a ce projet (les PRs de feature vont directement en production) et arrete-toi.

Puis verifie :

- [ ] Le repo a un remote `origin` configure
- [ ] Le working tree est propre
- [ ] La branche d'integration est a jour : `git checkout <integration>` puis `git pull --ff-only origin <integration>`
- [ ] Il y a des commits d'avance sur la production : `git log origin/<production>..<integration> --oneline` non vide — sinon rien a livrer

Si une verification echoue, signale-le clairement et arrete-toi.

## Étape 1 — Determiner la version

Par ordre de priorité :

1. **Argument** fourni (ex: `0.5.2`)
2. **Ticket JIRA de version** — si le tracker est JIRA et que les tickets sont organises par version, propose la version du ticket parent des demandes livrees
3. **SemVer depuis les changements** — analyse les commits a livrer : breaking → MAJOR (ou MINOR en 0.x), `feat` → MINOR, uniquement des `fix` → PATCH. Propose et demande confirmation.

Verifie que le tag `vX.Y.Z` n'existe pas déjà (`git tag -l`). Affiche la version retenue.

## Étape 2 — Contenu de la release

Liste ce qui part en production :

```
**Release vX.Y.Z** — [integration] → [production]

- #12 [Feat] Titre (PROJ-42)
- #15 [Fix] Titre (PROJ-45)
```

Reconstruis cette liste depuis `git log origin/<production>..<integration>` (merges de PRs) — c'est elle qui alimentera le body de la PR de release.

Si le tracker configuré (`.claude/skills/workflow-config/SKILL.md`, champ "Issue tracker") est Jira ou Linear, complète par les tickets référencés dans ces commits — une issue GitHub native se ferme déjà automatiquement via `Closes #N`, rien à faire ici :

```bash
git log origin/<production>..<integration> --format=%B | grep -oE '[A-Z][A-Z0-9]+-[0-9]+' | sort -u
```

```
**Tickets référencés** : PROJ-42, PROJ-45
```

Purement informatif à ce stade (récap avant la PR de release) : la mise à jour réelle du statut se fait à `/pipe-tag`, quand le code est effectivement livré.

## Étape 3 — CHANGELOG

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/../pipe-changelog/SKILL.md` et applique-le avec la version cible en argument.

Adaptation : affiche le resultat mais ne demande pas la confirmation interne de son étape 4 — la confirmation unique de l'étape suivante couvre l'ensemble, et un commit local reste reversible.

Committe le CHANGELOG sur la branche d'integration.

### Figer les decisions des specs

Dans `docs/specs/`, les journaux de decisions portent la version de livraison. Celles de la release en cours y sont notees `X.Y.Z (a venir)` : retire la mention `(a venir)` pour la version qu'on livre — la decision est desormais publiee.

Recherche `(a venir)` dans `docs/specs/` et ne touche qu'aux lignes de la version cible ; celles d'une version ulterieure restent en l'etat. Aucune occurrence, ou projet sans `docs/specs/` → passe a la suite sans rien signaler. Committe ces corrections avec le CHANGELOG.

## Étape 4 — PR de release

Affiche le recap complet (version, PRs incluses, extrait du CHANGELOG) puis demande **une confirmation unique** avant de :

1. Pousser la branche d'integration : `git push origin <integration>`
2. Creer la PR `<integration>` → `<production>` via le MCP de la plateforme :
   - **Titre** : `[Release] vX.Y.Z`
   - **Body** : la section du CHANGELOG de cette version, la liste des PRs incluses, et la version cible

```
PR de release créée : [URL]
```

## Étape 5 — Proposer la suite

```
---
Apres merge de la PR et deploiement : `/pipe-tag vX.Y.Z` sur [production] pour publier le tag.
```

---

## Input utilisateur

$ARGUMENTS
