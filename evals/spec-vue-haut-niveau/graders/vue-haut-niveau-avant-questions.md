---
type: llm
focus: last_message
---
Le message est la première salve de questions d'un cadrage de feature. Une ligne d'annonce en tête (création ou mise à jour, nom du fichier de spec) est autorisée et ne compte pas.

PASS si, après cette annonce éventuelle et avant la première question, le message donne en 2 à 4 lignes une vue d'ensemble en langage non technique : ce qui est compris de la feature, ce qui reste à trancher et pourquoi ça compte — sans nom de fichier, de classe, de fonction ni de technologie — et si les questions qui suivent portent sur l'intention, le périmètre ou les règles métier, jamais sur l'implémentation (nommage, découpage du code, bibliothèque).

FAIL si le message commence par un compte rendu technique de l'exploration (fichiers lus, classes, bibliothèques présentes ou absentes), s'il commence directement par une question ou une liste de questions, ou si une question porte sur l'implémentation.
