---
name: pipe-ship
description: Livrer une issue planifiee en un seul geste : enchaine implementation, review, tests, changelog et Pull Request en ne s'arretant que sur probleme bloquant. Utiliser apres /pipe-plan a la place des etapes unitaires du pipeline. Adapte son perimetre au niveau du projet.
argument-hint: [numero issue ou rien si plan deja present]
---

Ce skill enchaine les etapes du pipeline en reutilisant les skills unitaires — il ne duplique pas leur logique. Chaque etape indique quel skill charger et quelles adaptations appliquer. Les skills unitaires restent invocables individuellement.

## Points d'arret (gates)

`/pipe-ship` ne s'arrete que dans ces quatre cas — tout le reste s'enchaine sans confirmation :

1. **Probleme non anticipe dans le plan** pendant l'implementation (fichier manquant, incoherence)
2. **Bloquant de review** (bug, faille, regression detectee par le sub-agent)
3. **Tests rouges** apres 3 tentatives de correction, ou probleme structurel
4. **Confirmation finale unique** avant push + creation de la PR

Si le flux s'arrete, afficher ou on en est et comment reprendre. Relancer `/pipe-ship` reprend la ou le flux s'est arrete : detecter l'etat via git (branche deja creee, commits presents, changelog modifie) et sauter les etapes deja faites.

## Etape 0 — Contexte et niveau de projet

Utilise Read pour charger `.claude/skills/workflow-config/SKILL.md` (si absent, utilise Read pour charger `.claude/skills/tech-stack/SKILL.md` — config legacy).

Determine le **niveau** du projet (champ "Niveau", section Projet) :

- **Niveau A** (ou champ absent) : code → review → tests → changelog → PR
- **Niveau B** : code → tests → push (pas de changelog, pas de review formelle)

Annonce la route retenue en une ligne avant de commencer.

## Etape 1 — Implementer

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/../pipe-code/SKILL.md` et applique toutes ses etapes (resolution du plan, verifications, branche, implementation, commits atomiques).

Adaptation : a la fin, ne pas proposer `/pipe-review` — enchainer directement sur l'etape suivante de ce skill.

Gate : si une etape revele un probleme non anticipe dans le plan, stopper et presenter les options comme le prevoit pipe-code.

## Etape 2 — Review (niveau A uniquement)

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/../pipe-review/SKILL.md` et applique ses etapes 0 a 4 (collecte, sub-agent avec le protocole de sa `reference.md`, rapport).

Adaptations :

- **Aucun bloquant** → afficher la synthese (compteurs par severite), memoriser avertissements et suggestions pour le recap final, enchainer sans question.
- **Au moins un bloquant** → gate : afficher les bloquants au format Question/Reponse de pipe-review et traiter chacun (corriger / adapter / ignorer) avec l'utilisateur avant de continuer. Committer les corrections.

## Etape 3 — Tests

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/../pipe-test/SKILL.md` et applique-le tel quel (boucle corrective bornee a 3 tentatives).

Adaptation : si tous les tests passent, enchainer sans proposer `/pipe-changelog`.

Gate : probleme structurel ou echec apres 3 tentatives → stopper comme le prevoit pipe-test.

Si aucune commande de test n'est configuree dans `workflow-config`, le signaler en une ligne et continuer — ne pas bloquer le flux.

## Etape 4 — Changelog (niveau A uniquement)

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/../pipe-changelog/SKILL.md` et applique-le en mode `[Unreleased]` (sans argument de version).

Adaptation : ne pas demander la confirmation de l'etape 4 de pipe-changelog — ecrire les fichiers et committer directement. Le resultat est presente dans le recap final, et un commit local reste reversible.

## Etape 5 — Recap et confirmation unique, puis PR

Affiche le recap complet :

```
## Ship — [branche]

### Commits
- emoji type(scope): description (un par ligne)

### Review
- X bloquant(s) traite(s), Y avertissement(s), Z suggestion(s) — [details si non vide]

### Tests
- ✅ N tests passent (ou : non configures)

### Changelog
- CHANGELOG.md : [mis a jour | inchange | non applicable (niveau B)]

---
Je pousse `[branche]` et je [cree | mets a jour] la PR ?
```

C'est la **seule confirmation** du flux nominal. Une fois recue :

- **Niveau A** : utilise Read pour charger `${CLAUDE_SKILL_DIR}/../pipe-pr/SKILL.md` et applique-le sans redemander ses confirmations internes (push et soumission couverts par la confirmation ci-dessus). La regle `Closes #XX` reste obligatoire — si aucune issue n'est identifiable, demander le numero.
- **Niveau B** : pousser la branche. Ne creer une PR que si l'utilisateur le demande ou si le projet en utilise habituellement (PRs existantes sur le repo) ; sinon proposer un merge direct.

Cloture :

```
---
PR soumise : [URL]
Apres merge : `/pipe-tag [vX.Y.Z]` pour publier une release (niveau A).
```

---

## Input utilisateur

$ARGUMENTS
