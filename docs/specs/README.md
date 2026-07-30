# Specs

Une spec par feature : ce qu'elle est, ce qu'on en attend, son perimetre et ses points
d'entree techniques. A lire avant de modifier une feature — c'est le contexte de reference.

Ecrites et maintenues par `/pipe-spec`, verifiees a chaque `/pipe-review`.

| Feature | Spec | En une phrase |
|---------|------|---------------|
| CHANGELOG et release | [`changelog-et-release.md`](changelog-et-release.md) | Un CHANGELOG oriente consommateur, puis version, PR de production et tag |
| Configuration d'un projet | [`configuration-d-un-projet.md`](configuration-d-un-projet.md) | Diagnostique ce qui manque au projet, puis n'installe que ce qui manque |
| Cycle de vie d'une spec | [`cycle-de-vie-d-une-spec.md`](cycle-de-vie-d-une-spec.md) | Comment une spec nait, se met a jour, se verifie et se deprecie |
| Developpement guide par les tests | [`developpement-guide-par-les-tests.md`](developpement-guide-par-les-tests.md) | Tests valides puis figes : le dev les suit en session dediee |
| Fichier de pilotage | [`fichier-de-pilotage.md`](fichier-de-pilotage.md) | Porte l'etat d'un ticket et rend son cycle reprenable en session neuve |
| Garde-fous outilles | [`garde-fous-outilles.md`](garde-fous-outilles.md) | Des scripts deployes par /setup qui font respecter les regles sans le LLM |
| Livraison : commits, branches et PR | [`livraison-git.md`](livraison-git.md) | Des commits qui documentent le projet, une PR qui n'en est que le sommaire |
| Plan technique d'un ticket | [`plan-technique-d-un-ticket.md`](plan-technique-d-un-ticket.md) | Un ticket devient une feuille de route co-construite et calibree |
| Review de fin de cycle | [`review-de-fin-de-cycle.md`](review-de-fin-de-cycle.md) | Outils, agent isole, relecture humaine, puis fraicheur de la spec |
