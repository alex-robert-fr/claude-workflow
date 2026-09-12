# Audit de conformite — grille, protocoles des sub-agents, formats

Les sections « Protocole » sont chargées par les **sub-agents** (le skill leur passe le chemin de ce fichier dans leur prompt). Les sections « Extraction de la grille », « Format du rapport » et « Plan de remediation » sont pour le contexte principal.

## Extraction de la grille

Une règle est **atomique** quand un auditeur peut y repondre par oui ou non en regardant un fichier, sans interpreter. Tout ce qui demande un jugement se decoupe jusqu'a ce que ce soit vrai, ou sort de la grille.

Decoupage :

- Une phrase du document contenant « et », « sauf », « sauf si » porte presque toujours **plusieurs** règles — separe-les
- Une règle qui commence par « bien », « proprement », « au mieux » n'est pas verifiable en l'etat : soit on la traduit en critère observable, soit elle rejoint les intentions
- Une règle avec exception explicite garde son exception dans son enonce — sinon les auditeurs remonteront les exceptions comme des violations

Chaque règle porte trois choses :

- **enonce** — imperatif, une phrase
- **portee** — quels fichiers elle concerne (`tous`, une extension, un repertoire)
- **citation source** — la phrase du document dont elle vient, pour que l'arbitrage puisse remonter au texte

```
| # | Règle | Portee | Source |
|---|---|---|---|
| R1 | Chaque skill est un repertoire `nom/SKILL.md` avec frontmatter | `skills/**` | « Chaque skill est un repertoire… » |
```

Sous la grille, liste a part les **intentions non verifiables** — ce que le document dit mais qu'aucun auditeur ne peut trancher (« rester concis », « penser au lecteur »). Ne les jette pas silencieusement : leur presence dit a l'utilisateur ce que l'audit ne couvrira pas, et c'est parfois le signal que le document merite d'être précise.

---

## Protocole de l'auditeur

Tu audites une zone de code contre une grille de règles. Tu ne corriges rien, tu ne proposes pas de refactor, tu ne donnes pas ton avis sur le code.

**Ta seule question, pour chaque règle et chaque fichier de ta zone : est-elle respectee ?**

Méthode :

1. Lis chaque fichier de ta zone via Read — **en entier**. Un audit sur des extraits produit des faux positifs (le code conforme est souvent trois lignes plus bas)
2. Pour chaque règle dont la portee couvre le fichier, cherche activement la **contre-preuve**, pas la confirmation
3. Toute violation exige une preuve `chemin/fichier.ext:ligne` et la citation exacte du code fautif. **Sans preuve localisee, la violation n'existe pas** — ne la remonte pas

Pour chaque violation :

- **règle** : le numéro (`R3`)
- **fichier** : `chemin:ligne`
- **preuve** : la ligne ou le fragment fautif, cite tel quel
- **ecart** : en quoi ce code contredit l'enonce de la règle — une phrase, sans jargon
- **sévérité** : BLOQUANT (la règle est violee frontalement, conséquence reelle) / AVERTISSEMENT (violation partielle ou contournement) / SUGGESTION (respect formel mais pas de l'esprit)
- **confiance** : HAUTE (le texte de la règle et le code sont sans ambiguite) / MOYENNE / BASSE (la règle demande une interpretation pour trancher)

Rends aussi, pour **chaque** règle de la grille, un verdict de zone : `conforme`, `viole` (avec N occurrences), ou `sans objet` (aucun fichier de ta zone n'entre dans sa portee). Une règle omise du verdict sera traitee comme non evaluee et relancera un audit — ne saute aucune ligne de la grille.

Ce que tu ne fais **pas** : signaler des problèmes que la grille ne couvre pas, meme s'ils sont reels (bugs, style, perf). Ce n'est pas une review de code. Un rapport qui deborde de la grille est un rapport a refaire.

Zone entièrement conforme = resultat valide et fréquent. Ne remplis jamais pour justifier ton passage.

---

## Protocole du refutateur

On te donne des violations remontees par un auditeur. **Ton rôle est de les detruire.** Tu n'es pas la pour confirmer : un constat qui survit a une tentative honnete de demolition vaut quelque chose, un constat jamais attaque ne vaut rien.

Pour chaque violation, ouvre le fichier via Read, lis-le en entier, et cherche laquelle de ces sorties s'applique :

- **faux positif** — le code respecte en fait la règle ; l'auditeur a mal lu, ou la conformite est ailleurs dans le fichier
- **exception legitime** — la règle prevoit ce cas, ou le contexte (test, script generE, code legacy explicitement isole, compatibilite) le sort de sa portee
- **règle mal interpretee** — l'auditeur a applique un enonce plus large que le document ne le dit ; cite la phrase source pour le montrer
- **règle mauvaise** — le code a raison et le document a tort : la règle est obsolete, contredite par une autre partie du document, ou impossible a tenir. Sortie rare, mais c'est la plus precieuse : elle corrige la loi au lieu du prevenu
- **confirme** — aucune des sorties ci-dessus ne tient apres verification

**En cas de doute, le defaut est `refute`.** Un faux positif qui remonte jusqu'a l'arbitrage humain coute plus cher qu'une violation ratee : il fait perdre la confiance dans tout le rapport.

Rends pour chaque violation : son identifiant, le verdict parmi les cinq ci-dessus, et **une phrase** de motif avec sa preuve (`fichier:ligne` ou citation du document).

---

## Protocole du critique

On te donne la grille de règles, la carte des zones auditees et les rapports agreges. Tu ne lis pas le code pour trouver des violations : tu cherches ce que l'audit **n'a pas vu**.

Quatre angles :

1. **Règles jamais evaluees** — une règle declaree `sans objet` par toutes les zones alors que sa portee couvre des fichiers reellement presents. Signal quasi certain d'un trou
2. **Zones survolees** — une zone qui rend zero violation sur toutes les règles alors que les autres en rendent, ou dont le rapport ne cite aucun fichier précis
3. **Faux negatifs probables** — un endroit du projet ou la règle est structurellement difficile a tenir (code ancien, module a part, fichiers generes, points d'entrée exotiques) et qu'aucun auditeur ne mentionne
4. **Perimetre manquant** — des fichiers concernes par la grille qui n'appartiennent a aucune zone : extensions oubliees, repertoires exclus a tort, configuration, scripts, CI

Rends une liste de **trous** : pour chacun, ce qui n'a pas ete couvert, pourquoi tu le penses, et la cible exacte a re-auditer (fichiers ou glob + numéros de règles). Si tu ne trouves pas de trou credible, dis-le en une ligne — inventer un doute pour paraitre utile fait relancer des agents pour rien.

---

## Format du rapport

Fichier `.claude/audits/audit-<slug>.md` :

```markdown
# Audit de conformite — <document de reference>

Perimetre : N fichiers · G zones · R règles · <date>

## Verdict par règle

| # | Règle | Verdict | Violations |
|---|---|---|---|
| R1 | <enonce court> | ✅ conforme | — |
| R2 | <enonce court> | ❌ viole | 3 (1 bloquant) |
| R3 | <enonce court> | — sans objet | — |

## Violations confirmees

### R2 — <enonce>

- `src/auth/session.ts:41` — BLOQUANT · <ecart en une phrase>
  > <ligne fautive citee>

## Constats refutes

| Règle | Fichier | Motif |
|---|---|---|
| R5 | `src/legacy/pdf.ts:12` | Exception legitime : module isole, exclu par la règle |

## Ecarts acceptes

| Règle | Fichier | Raison (decidee le <date>) |
|---|---|---|

## Non couvert

- <intentions non verifiables de la grille>
- <trous signales par le critique et non resolus>
```

La section « Constats refutes » n'est pas du remplissage : sans elle, le prochain audit remontera les memes faux positifs et les fera rearbitrer.

## Plan de remediation

Un lot est un travail **complet et livrable seul** : il ne laisse pas le projet a moitie conforme a une règle.

```markdown
## Lot 1 — <intitule> · <route>

- Règles : R2, R7
- Fichiers : N (`src/auth/`)
- Sévérité max : BLOQUANT
- Depend de : —
```

Règles de decoupage :

- **Grouper par règle** quand la correction est mecanique et repetee (meme geste sur N fichiers) — un seul lot, une seule relecture
- **Grouper par zone** quand la correction demande de comprendre le module — sinon le meme fichier est repris dans trois lots differents, avec les conflits qui vont avec
- Ordonner par sévérité, puis par dependance : un lot qui deplace des fichiers passe avant celui qui les modifie
- Un lot qui touche plus de ~15 fichiers se redecoupe : il ne sera pas relisible
