#!/bin/bash
# Rejoue les hooks git/tests du plugin (hooks/scripts/pre-git-guard.sh et
# protect-tests.sh) sur des entrées JSON simulées, sans Claude Code.
# Outillage LOCAL, jamais distribué — à lancer après toute modification de ces
# scripts. Exit 1 dès qu'un cas échoue.

ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
G="$ROOT/hooks/scripts/pre-git-guard.sh"
P="$ROOT/hooks/scripts/protect-tests.sh"
unset CLAUDE_PROJECT_DIR
status=0

t() {
  local name="$1" expect="$2" script="$3" json="$4" out code
  out=$(printf '%s' "$json" | bash "$script" 2>&1 >/dev/null); code=$?
  if [ "$code" = "$expect" ]; then echo "ok   $name"
  else echo "FAIL $name (exit $code, attendu $expect) — $out"; status=1; fi
}
bash_json() { jq -cn --arg c "$1" '{tool_name:"Bash",tool_input:{command:$c}}'; }

echo "== pre-git-guard =="
t "git add ."                  2 "$G" "$(bash_json 'git add . && git commit -m "x"')"
t "git add -A"                 2 "$G" "$(bash_json 'git add -A')"
t "git add -u"                 2 "$G" "$(bash_json 'git add -u')"
t "git add chemins explicites" 0 "$G" "$(bash_json 'git add src/a.ts skills/x/SKILL.md')"
t "git add .env"               2 "$G" "$(bash_json 'git add .env src/a.ts')"
t "git add config/.env.local"  2 "$G" "$(bash_json 'git add config/.env.local')"
t "git add environment.ts"     0 "$G" "$(bash_json 'git add src/environment.ts')"
t "git add envelope.ts"        0 "$G" "$(bash_json 'git add src/envelope.ts')"
t "commit propre (heredoc)"    0 "$G" "$(bash_json 'git commit -m "$(cat <<MSG
✨ feat(auth): ajout login

- puce
MSG
)"')"
t "commit Co-Authored-By"      2 "$G" "$(bash_json 'git commit -m "$(cat <<MSG
✨ feat(auth): ajout login

Co-Authored-By: Claude <noreply@anthropic.com>
MSG
)"')"
t "commit Claude-Session"      2 "$G" "$(bash_json 'git commit -m "fix: x" -m "Claude-Session: https://claude.ai/code/session_x"')"
t "gh pr create signé"         2 "$G" "$(bash_json 'gh pr create --title t --body "corps

🤖 Generated with [Claude Code](https://claude.com/claude-code)"')"
t "gh pr create propre"        0 "$G" "$(bash_json 'gh pr create --title t --body "corps propre"')"
t "grep du mot dans le code"   0 "$G" "$(bash_json 'grep -rn Co-Authored-By skills/')"
t "mcp body signé"             2 "$G" "$(jq -cn '{tool_name:"mcp__github__create_pull_request",tool_input:{title:"t",body:"x\n\nhttps://claude.ai/code/session_01ABC"}}')"
t "mcp body propre"            0 "$G" "$(jq -cn '{tool_name:"mcp__github__create_pull_request",tool_input:{title:"t",body:"Closes #4"}}')"
t "outil sans rapport"         0 "$G" "$(jq -cn '{tool_name:"Read",tool_input:{file_path:"/x"}}')"

echo "== protect-tests =="
TMP=$(mktemp -d); mkdir -p "$TMP/.claude/plans" "$TMP/src"
cat > "$TMP/.claude/plans/plan-42.md" <<'PLAN'
# Pilotage — [42] x

## Etat
- [x] Tests valides (review humaine)
- [ ] Dev termine (tests verts)
- [ ] Code valide (review agent + humaine)

## Plan
voir `src/plan-only.spec.ts` (hors section Tests : non protégé)

## Tests

`src/auth/login.spec.ts`
- quand X, alors Y

`src/auth/logout.spec.ts`
- quand Z

## Notes de reprise
- rien
PLAN
edit_json() { jq -cn --arg f "$1" --arg cwd "$TMP" '{tool_name:"Edit",cwd:$cwd,tool_input:{file_path:$f,old_string:"a",new_string:"b"}}'; }
t "test validé bloqué"            2 "$P" "$(edit_json "$TMP/src/auth/login.spec.ts")"
t "second test validé bloqué"     2 "$P" "$(edit_json "$TMP/src/auth/logout.spec.ts")"
t "fichier hors section Tests"    0 "$P" "$(edit_json "$TMP/src/plan-only.spec.ts")"
t "code applicatif libre"         0 "$P" "$(edit_json "$TMP/src/auth/login.ts")"
t "suffixe piégeux (relogin)"     0 "$P" "$(edit_json "$TMP/src/auth/relogin.spec.ts")"
sed -i 's/- \[ \] Code valide/- [x] Code valide/' "$TMP/.claude/plans/plan-42.md"
t "Code valide coché → libre"     0 "$P" "$(edit_json "$TMP/src/auth/login.spec.ts")"
sed -i 's/- \[x\] Code valide/- [ ] Code valide/; s/- \[x\] Tests valides/- [ ] Tests valides/' "$TMP/.claude/plans/plan-42.md"
t "Tests valides décoché → libre" 0 "$P" "$(edit_json "$TMP/src/auth/login.spec.ts")"
t "projet sans .claude/plans"     0 "$P" "$(jq -cn --arg cwd /nonexistent '{tool_name:"Edit",cwd:$cwd,tool_input:{file_path:"/nonexistent/a.spec.ts"}}')"
rm -rf "$TMP"

[ $status -eq 0 ] && echo "Hooks : OK" || echo "Hooks : ÉCHEC"
exit $status
