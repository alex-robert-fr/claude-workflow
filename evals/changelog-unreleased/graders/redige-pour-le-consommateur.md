---
type: llm
focus: last_message
---
Le message propose le contenu d'un CHANGELOG. Juge uniquement les entrées sous `## [Unreleased]`.

PASS si chaque entrée décrit un effet observable pour l'utilisateur du produit, en français, sans préfixe de commit (`feat(`, `fix(`, emoji de type), et si les commits purement techniques (refactor du token, cache CI) sont absents des entrées ou signalés comme exclus.

FAIL si une entrée recopie un titre de commit avec son préfixe, si un commit technique (refactor, chore CI) figure parmi les entrées, ou si aucune entrée ne mentionne l'export PDF des factures et la correction de la session.
