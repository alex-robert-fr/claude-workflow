#!/bin/bash
# Rejoue les scripts partagés du plugin (shared/scripts/) dans des dépôts jetables.
# Outillage LOCAL, jamais distribué — à lancer après toute modification de ces
# scripts. Exit 1 dès qu'un cas échoue.

REPO="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
S="$REPO/shared/scripts"
unset CLAUDE_PROJECT_DIR
status=0

# t <nom> <exit attendu> <stdout attendu ("" = ne pas vérifier)> <commande...>
t() {
  local name="$1" expect="$2" want="$3"; shift 3
  local out code
  out=$("$@" 2>/dev/null); code=$?
  if [ "$code" != "$expect" ]; then
    echo "FAIL $name (exit $code, attendu $expect)"; status=1; return
  fi
  if [ -n "$want" ] && [ "$out" != "$want" ]; then
    echo "FAIL $name (stdout « $out », attendu « $want »)"; status=1; return
  fi
  echo "ok   $name"
}

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

echo "== find-plan =="
P="$TMP/p"; mkdir -p "$P/.claude/plans"; git -C "$P" init -q -b develop
t "aucun pilotage"            1 ""                            env CLAUDE_PROJECT_DIR="$P" bash "$S/find-plan.sh"
printf '# Pilotage\n## Branche\n`feat/42-x`\n' > "$P/.claude/plans/plan-42.md"
t "un seul → son chemin"      0 ".claude/plans/plan-42.md"    env CLAUDE_PROJECT_DIR="$P" bash "$S/find-plan.sh"
t "identifiant présent"       0 ".claude/plans/plan-42.md"    env CLAUDE_PROJECT_DIR="$P" bash "$S/find-plan.sh" 42
t "identifiant absent"        1 ""                            env CLAUDE_PROJECT_DIR="$P" bash "$S/find-plan.sh" 99
printf '# Pilotage\n## Branche\n`feat/43-y`\n' > "$P/.claude/plans/plan-43.md"
t "plusieurs, hors branche"   3 ""                            env CLAUDE_PROJECT_DIR="$P" bash "$S/find-plan.sh"
git -C "$P" commit -q --allow-empty -m init && git -C "$P" switch -q -c feat/43-y
t "plusieurs, branche courante" 0 ".claude/plans/plan-43.md"  env CLAUDE_PROJECT_DIR="$P" bash "$S/find-plan.sh"

echo "== new-branch =="
R="$TMP/remote"; git init -q --bare -b develop "$R"
W="$TMP/w"; git clone -q "$R" "$W" 2>/dev/null; git -C "$W" switch -q -c develop 2>/dev/null
git -C "$W" commit -q --allow-empty -m init && git -C "$W" push -q -u origin develop 2>/dev/null
mkdir -p "$W/.claude/skills/workflow-config"
printf -- '---\nname: workflow-config\n---\n\n## Plateforme\n\n- **Branche par defaut** : develop\n' > "$W/.claude/skills/workflow-config/SKILL.md"
t "sans argument"             2 ""                                     env CLAUDE_PROJECT_DIR="$W" bash "$S/new-branch.sh"
t "création depuis develop"   0 "feat/1-a (depuis develop)"            env CLAUDE_PROJECT_DIR="$W" bash "$S/new-branch.sh" feat/1-a
t "  → branche courante"      0 "feat/1-a"                             git -C "$W" branch --show-current
t "branche déjà existante"    1 ""                                     env CLAUDE_PROJECT_DIR="$W" bash "$S/new-branch.sh" feat/1-a
printf -- '- **Branche par défaut** : `main`\n' > "$W/.claude/skills/workflow-config/SKILL.md"
git -C "$W" branch -q main develop && git -C "$W" push -q origin main 2>/dev/null
t "accent + backticks lus"    0 "fix/2-b (depuis main)"                env CLAUDE_PROJECT_DIR="$W" bash "$S/new-branch.sh" fix/2-b
rm -rf "$W/.claude"
t "sans config → origin/HEAD" 0 "docs/3-c (depuis develop)"            env CLAUDE_PROJECT_DIR="$W" bash "$S/new-branch.sh" docs/3-c

echo "== changelog-section / detect-version =="
C="$TMP/CHANGELOG.md"
cat > "$C" <<'CL'
# Changelog

## [Unreleased]

### Added
- En préparation ([#9](u))

## [1.7.1](https://x/releases/tag/v1.7.1) - 2026-09-12

### Fixed
- Un correctif ([`abc`](u))

## [1.7.0] - 2026-08-01

### Added
- Une feature ([#5](u))

[Unreleased]: https://x/compare/v1.7.1...HEAD
[1.7.1]: https://x/compare/v1.7.0...v1.7.1
[1.7.0]: https://x/releases/tag/v1.7.0
CL
t "section liée"              0 $'### Fixed\n- Un correctif ([`abc`](u))'   env CHANGELOG_FILE="$C" bash "$S/changelog-section.sh" 1.7.1
t "préfixe v accepté"         0 $'### Fixed\n- Un correctif ([`abc`](u))'   env CHANGELOG_FILE="$C" bash "$S/changelog-section.sh" v1.7.1
t "dernière section (liens exclus)" 0 $'### Added\n- Une feature ([#5](u))' env CHANGELOG_FILE="$C" bash "$S/changelog-section.sh" 1.7.0
t "Unreleased"                0 $'### Added\n- En préparation ([#9](u))'    env CHANGELOG_FILE="$C" bash "$S/changelog-section.sh" Unreleased
t "version absente"           1 ""                                          env CHANGELOG_FILE="$C" bash "$S/changelog-section.sh" 9.9.9
t "sans argument"             2 ""                                          env CHANGELOG_FILE="$C" bash "$S/changelog-section.sh"
t "dernière publiée"          0 "1.7.1"                                     env CHANGELOG_FILE="$C" bash "$S/detect-version.sh"
t "--next"                    0 "1.7.2"                                     env CHANGELOG_FILE="$C" bash "$S/detect-version.sh" --next
t "changelog absent"          1 ""                                          env CHANGELOG_FILE="$TMP/nope.md" bash "$S/detect-version.sh"
git -C "$W" tag -a v0.1.0 -m x && git -C "$W" tag -a v0.2.0 -m x
t "--tag (tri sémantique)"    0 "v0.2.0"                                    env CLAUDE_PROJECT_DIR="$W" bash "$S/detect-version.sh" --tag

echo "== check-specs : budget de lignes =="
X="$TMP/x"; mkdir -p "$X/docs/specs"
printf '# Specs\n\n| Feature | Spec | En une phrase |\n|---|---|---|\n| Longue | [`longue.md`](longue.md) | x |\n| Courte | [`courte.md`](courte.md) | x |\n' > "$X/docs/specs/README.md"
{ echo "# Longue"; for i in $(seq 1 85); do echo "- ligne $i"; done; } > "$X/docs/specs/longue.md"
printf '# Courte\n\n- ok\n' > "$X/docs/specs/courte.md"
out=$(CLAUDE_PROJECT_DIR="$X" bash "$REPO/skills/setup/scripts/check-specs.sh" 2>&1)
if printf '%s' "$out" | grep -q "longue.md — 86 lignes (budget 80)" && ! printf '%s' "$out" | grep -q "courte.md — .* lignes"; then
  echo "ok   spec > 80 lignes signalée, spec courte non"
else
  echo "FAIL budget de lignes — sortie : $out"; status=1
fi

[ $status -eq 0 ] && echo "Scripts : OK" || echo "Scripts : ÉCHEC"
exit $status
