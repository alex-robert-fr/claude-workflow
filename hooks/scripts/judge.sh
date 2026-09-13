#!/bin/bash
# Appel du juge LLM imbriqué, partagé par stop-quality.sh et post-edit-comments.sh — à sourcer,
# pas à exécuter. `judge "$SYS_PROMPT" "$PROMPT" "$SCHEMA"` imprime le JSON de `claude -p`
# (vide si l'appel échoue) ; le verdict se lit dans `.structured_output`.
#
# Latence mesurée sur un vrai verdict : ~6,5 s → ~3 s. Le gros poste est le thinking, que
# `--effort low` ne supprime pas (MAX_THINKING_TOKENS=0 le coupe ; un verdict binaire sur un
# extrait n'en a pas besoin, vérifié sur les cas fautifs et justifiés) ; les flags de
# démarrage valent ~1 s. `--bare` irait plus loin mais saute la lecture du trousseau : un
# utilisateur en abonnement n'est plus connecté et le juge répond « Not logged in » — voir
# la décision 1.8.0 de docs/specs/garde-fous-automatiques.md. stdin est fermé : hérité
# ouvert et vide, le CLI l'attend 3 s avant de continuer.
#
# Garde anti-récursion, deux niveaux : `--safe-mode` désactive les hooks du juge (donc le
# sien) ; CLAUDE_WORKFLOW_JUDGE_ACTIVE, hérité par le process enfant, neutralise le hook
# appelant si jamais il s'exécutait quand même.

judge() {
  CLAUDE_WORKFLOW_JUDGE_ACTIVE=1 MAX_THINKING_TOKENS=0 claude --safe-mode -p \
    --strict-mcp-config --no-session-persistence --tools "" --disable-slash-commands \
    --model claude-haiku-4-5-20251001 \
    --effort low \
    --system-prompt "$1" \
    --output-format json \
    --json-schema "$3" \
    "$2" </dev/null 2>/dev/null
}
