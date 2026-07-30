# Cycle de vie d'une spec

> **Statut** : active
> **Tickets** : —

## En une phrase

Comment une spec nait, se met a jour, se verifie et se deprecie — et pourquoi elle n'est jamais ecrite sans l'humain.

## Intention

Une session neuve qui doit modifier une feature n'a que deux options : reparcourir le code, ou lire ce que la feature est censee etre. Le code dit le comportement, jamais le pourquoi, le hors-scope ni les alternatives ecartees — c'est ce manque que la spec comble.

Reussi quand modifier une feature commence par lire une page au lieu d'explorer un repertoire, et qu'aucune session ne « complete » une feature dans une direction ecartee volontairement.

## Philosophie

**Une spec qui ment coute plus cher que pas de spec**, parce qu'elle est lue comme une reference. Toute regle du cycle de vie decoule de la : le cadrage vient de l'humain, la fraicheur se verifie a chaque cycle, et une feature disparue se deprecie au lieu d'etre rafistolee.

## Comportement attendu

- Une spec par feature, nommee d'apres la feature, alimentee par plusieurs tickets au fil du temps
- Elle est ecrite au present et decrit ce qui est ; une phrase qui devient fausse au merge du ticket n'y a pas sa place
- Une demande sans comportement metier ne produit pas de spec, et c'est annonce en une ligne
- Un ticket technique met a jour une spec existante plutot que d'en creer une
- Intention, hors-scope et alternatives ecartees viennent de l'utilisateur ; si elles restent vides, l'exercice est annonce comme sans valeur au lieu d'etre meuble
- Le journal des decisions s'ajoute, ne se reecrit pas — une decision remplacee est conservee avec sa raison
- Budget de 40 a 80 lignes, sections faibles supprimees plutot que remplies
- Seul l'index est charge pour savoir quelles features existent, et sa phrase de resume est bornee
- Une spec dont tous les points d'entree ont disparu est proposee a la depreciation ; quelques points morts signalent seulement du retard
- Une spec depreciee conserve son corps entier, quitte l'index actif et cesse d'etre injectee dans les sessions
- Un projet dont les features preexistent dispose d'un mode inventaire priorise, une feature par passe
- Aucune spec n'est ecrite sans accord explicite de l'utilisateur

## Hors scope

- Dire comment implementer — l'ordre, les fichiers et les signatures appartiennent au plan du ticket
- Deprecier automatiquement — le controle outille signale, l'humain tranche : une feature peut avoir simplement demenage
- Generer plusieurs specs d'affilee — chacune exige son propre cadrage
- Supprimer le fichier d'une feature retiree — git en garderait la trace, mais plus personne ne la retrouverait

## Fonctionnement technique

L'ecriture n'a que deux declencheurs : le cadrage en debut de cycle, et le mode inventaire sans argument. Le plan d'un ticket detecte l'absence de spec et route vers le cadrage ; il ne bloque pas si le projet n'en a aucune.

L'index est le point d'entree unique : trie alphabetiquement, il porte une phrase par feature et une section terminale pour les features retirees. Le garde-fou de session l'injecte a chaque demarrage en s'arretant a cette section — d'ou son titre, qui est un contrat et non une preference de redaction.

La verification de fraicheur se fait a deux niveaux, appeles depuis la review de fin de cycle : mecanique pour les chemins morts et les specs hors index, au jugement pour le comportement, le hors-scope, les points d'entree ajoutes et les decisions non consignees.

## Dependances

- **Internes** : [`plan-technique-d-un-ticket.md`](plan-technique-d-un-ticket.md) pour la detection d'environnement et la recuperation du ticket ; [`fichier-de-pilotage.md`](fichier-de-pilotage.md), ouvert par le cadrage ; [`garde-fous-outilles.md`](garde-fous-outilles.md) pour l'injection de l'index et le controle mecanique
- **Externes** : `git log` pour la priorisation de l'inventaire ; les MCP de tracker pour recuperer un ticket
- **Dependants** : [`review-de-fin-de-cycle.md`](review-de-fin-de-cycle.md), [`developpement-guide-par-les-tests.md`](developpement-guide-par-les-tests.md) et [`changelog-et-release.md`](changelog-et-release.md), qui lisent ou modifient les specs

## Decisions

| Version | Ticket | Decision | Raison | Alternative ecartee |
|---------|--------|----------|--------|---------------------|
| — | — | La frontiere spec / plan est le critere central | Une spec qui derive en plan devient fausse au premier commit, donc n'est plus relue — et une spec non relue ne rembourse jamais son cout | Un seul document par feature |
| — | — | Une feature par passe d'inventaire | Une spec generee sans le Q/R est une documentation inventee, et le rythme de l'ecriture est celui des arbitrages humains | Generer tout l'inventaire d'un coup |
| — | — | La priorisation de l'inventaire suit le churn | Une spec rapporte proportionnellement au nombre de fois ou la feature sera rouverte, et le passe le predit mieux que l'intuition | Suivre l'ordre alphabetique ou la taille |
| — | — | La phrase de l'index est bornee a 80 caracteres et le plafond est outille | L'index est le seul poste de contexte qui grossit avec le projet : une colonne libre le fait grossir deux fois | Compter sur la concision du modele |
| — | — | Le mode inventaire vit dans un fichier separe des references | Il enchaine sur le flow normal, qui charge deja les references : un fichier unique se faisait lire deux fois par invocation | Tout garder dans un fichier |

## Points d'entree

| Fichier | Role |
|---------|------|
| `skills/pipe-spec/SKILL.md` | Tri, identification de la feature, Q/R, redaction, elagage, validation |
| `skills/pipe-spec/reference.md` | Frontiere spec/plan, template, regles de redaction, fin de vie, fraicheur |
| `skills/pipe-spec/index-format.md` | Format de l'index et budget de la phrase — lu aussi a l'installation |
| `skills/pipe-spec/inventaire.md` | Reperage, priorisation par churn, presentation du classement |

## Pieges et zones sensibles

- **Le titre de la section des features retirees est un contrat** : le garde-fou de session s'y arrete pour n'injecter que l'actif. Le renommer ou le deplacer reintroduit les features mortes dans chaque session
- **Rien ne rappelle le rattrapage apres l'installation** : le controle outille ne valide que les specs existantes et ne signale jamais une feature sans spec
- **Une entree de journal `(a venir)` est modifiee au moment de la release** : c'est le seul cas ou une ligne existante du journal change
- Une version passee ne se devine pas : une decision heritee dont on ignore l'origine reste sans version, sinon le journal devient faux la ou il pretend etre precis
