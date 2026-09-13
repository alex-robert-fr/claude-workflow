# Décomposition d'un ticket trop large

Chargé par `/pipe-plan` quand le ticket dépasse un cycle : plus de 3 modules, plus de 2 couches (data, domaine, API, UI), plusieurs features indépendantes emballées ensemble, ou plus qu'une session `/pipe-code`.

## Principes

- Chaque sous-ticket est implémentable indépendamment et apporte de la valeur
- L'ordre respecte les dépendances (schéma avant API, API avant UI) ; les sous-tickets techniques précèdent les sous-tickets métier qu'ils conditionnent
- Chaque sous-ticket a un critère d'acceptance clair et sa propre classification (technique, métier, mixte)

## Sortie

1. Liste des sous-tickets : classification, titre, 1-2 lignes, dépendances
2. Plan détaillé du sous-ticket 1 seulement (template complet)
3. Les suivants seront planifiés par `/pipe-plan` au moment de les implémenter

## Exemple

Ticket : « Ajouter un système de notifications temps réel »

1. **[Technique]** Serveur WebSocket — infra de base, dépend de rien
2. **[Technique]** Modèle Notification en base — schéma + migration, dépend de rien
3. **[Mixte]** API de notifications — CRUD + logique métier, dépend de 1 et 2
4. **[Métier]** Composant notifications dans l'UI — bell + dropdown, dépend de 3
5. **[Métier]** Préférences de notification — settings, dépend de 3
