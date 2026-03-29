---
name: audit-naming
description: Auditer les conventions de nommage d'un projet via sub-agent. Verifie fichiers, dossiers, variables, fonctions, classes/types. Utiliser pour detecter les noms ambigus, incoherents ou non-conformes.
user-invocable: true
argument-hint: [chemin/scope ou rien pour audit complet]
---

## Contexte

Utilise Read pour charger `${CLAUDE_SKILL_DIR}/../_workflow-persona/SKILL.md` avant de commencer.

---

## Etape 0 — Verifications

Verifie qu'il y a au moins un fichier source dans le projet (Glob `**/*.{ts,js,py,rb,go,rs,java,kt,swift,php,cs}`). Si aucun fichier source trouve, signale-le et arrete-toi.

## Etape 1 — Detecter le contexte du projet

1. **Langage(s)** — utilise Glob pour detecter les extensions presentes et determiner le(s) langage(s) principal(aux) :
   - `.ts` / `.tsx` → TypeScript
   - `.js` / `.jsx` → JavaScript
   - `.py` → Python
   - `.rb` → Ruby
   - `.go` → Go
   - `.rs` → Rust
   - `.java` / `.kt` → JVM
   - `.swift` → Swift
   - `.php` → PHP
   - `.cs` → C#

2. **Conventions projet-specific** — cherche dans `.claude/skills/` des fichiers qui mentionnent des conventions de nommage (Glob `*.md` puis Grep `naming|nommage|convention`). Si trouves, lis-les — elles ont priorite sur les regles universelles.

3. **Scope** — si un argument est fourni (chemin ou glob), restreins l'analyse a ce scope. Sinon, analyse tout le projet.

## Etape 2 — Lancer l'audit via sub-agent

Utilise Read pour charger `reference.md` (referentiel de conventions).

Lance un sub-agent (`Agent` tool, type `general-purpose`) avec le prompt suivant. Injecte dans le prompt :
- Le referentiel de conventions (contenu de reference.md)
- Le(s) langage(s) detecte(s) et les conventions de casse applicables
- Les conventions projet-specific si trouvees a l'etape 1
- Le scope d'analyse

```
Tu es un auditeur de conventions de nommage. Analyse le codebase pour detecter les violations de nommage.

Langage(s) detecte(s) : [langages]
Scope : [scope ou "projet complet"]
[Conventions projet-specific si trouvees]

Referentiel de conventions :
[contenu de reference.md]

Consignes :
- Utilise uniquement Glob, Grep et Read pour scanner le code (jamais Bash)
- Exclus les patterns listes dans le referentiel (node_modules, dist, build, etc.)
- Pour chaque categorie, analyse un echantillon representatif de fichiers (pas besoin de tout lire)
- Concentre-toi sur les violations les plus impactantes, pas les micro-details

Analyse par categorie :
1. Fichiers et dossiers — casse, caracteres speciaux, coherence
2. Variables et constantes — casse, descriptivite, antipatterns
3. Fonctions/methodes — verbe d'action, precision, coherence
4. Classes/types/interfaces/enums — PascalCase, domaine clair
5. Coherence du vocabulaire — ubiquitous language, termes mixtes pour un meme concept

Pour chaque violation, donne :
- Fichier et ligne
- Severite (erreur / warning / suggestion)
- Description precise
- Suggestion de renommage quand pertinent

Produis le rapport au format defini dans le referentiel (section "Format du rapport").
```

## Etape 3 — Afficher le rapport

Affiche le rapport du sub-agent tel quel. Ajoute un resume en tete si le sub-agent ne l'a pas inclus :

```
## Audit naming — [nom du projet]

### Resume
- Erreurs : N
- Warnings : N
- Suggestions : N

[rapport detaille du sub-agent]
```

## Etape 4 — Proposer les corrections

Selon le resultat :

- **Aucune violation** → confirme que le nommage est conforme
- **Violations detectees** → propose de corriger les erreurs et warnings les plus critiques. Demande confirmation avant toute modification.

```
---
Audit termine. [N] violation(s) detectee(s).
Tu veux que je corrige les [erreurs/warnings] les plus critiques ?
```

---

## Input utilisateur

$ARGUMENTS
