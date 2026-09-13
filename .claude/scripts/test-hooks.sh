#!/bin/bash
# Rejoue les hooks git/tests/commentaires/Stop du plugin (hooks/scripts/pre-git-guard.sh,
# protect-tests.sh, post-edit-comments.sh, stop-quality.sh) sur des entrées JSON simulées, sans Claude
# Code. Le juge LLM (judge.sh) est remplacé par un faux binaire `claude`
# dont le verdict est piloté par FAKE_VERDICT : on teste le filtre et le câblage, pas
# le jugement lui-même.
# Outillage LOCAL, jamais distribué — à lancer après toute modification de ces
# scripts. Exit 1 dès qu'un cas échoue.

ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
G="$ROOT/hooks/scripts/pre-git-guard.sh"
P="$ROOT/hooks/scripts/protect-tests.sh"
C="$ROOT/hooks/scripts/post-edit-comments.sh"
unset CLAUDE_PROJECT_DIR CLAUDE_WORKFLOW_JUDGE_ACTIVE
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

echo "== post-edit-comments =="
FAKE=$(mktemp -d)
cat > "$FAKE/claude" <<'FAKECLI'
#!/bin/bash
# Faux juge : le verdict vient de FAKE_VERDICT (ok | ko | muet) ; il note qu'il a été
# appelé, et avec quels flags.
echo called >> "$FAKE_LOG"
printf '%s\n' "$@" "MAX_THINKING_TOKENS=${MAX_THINKING_TOKENS-absent}" >> "$FAKE_LOG.args"
case "$FAKE_VERDICT" in
  ok)   echo '{"structured_output":{"ok":true,"commentaires":[]}}' ;;
  ko)   echo '{"structured_output":{"ok":false,"commentaires":[{"commentaire":"// incrémente i","raison":"paraphrase du code"}]}}' ;;
  *)    exit 1 ;;
esac
FAKECLI
chmod +x "$FAKE/claude"
export FAKE_LOG="$FAKE/log" PATH="$FAKE:$PATH"
write_json() { jq -cn --arg f "$1" --arg c "$2" '{tool_name:"Write",tool_input:{file_path:$f,content:$c}}'; }
edit_new()   { jq -cn --arg f "$1" --arg c "$2" '{tool_name:"Edit",tool_input:{file_path:$f,old_string:"a",new_string:$c}}'; }
AVEC=$'let i = 0\n// incrémente i\ni++\n'
SANS=$'let i = 0\ni++\n'
export FAKE_VERDICT=ko
t "verdict ko → renvoyé"           2 "$C" "$(write_json src/a.ts "$AVEC")"
t "Edit avec commentaire → jugé"   2 "$C" "$(edit_new src/a.py $'x = 1  # met x à 1')"
t "markdown jamais jugé"           0 "$C" "$(write_json docs/a.md "$AVEC")"
t "json jamais jugé"               0 "$C" "$(write_json a.json '{"a":1}')"
: > "$FAKE_LOG"
t "code sans commentaire → 0"      0 "$C" "$(write_json src/a.ts "$SANS")"
t "shebang + shellcheck ignorés"   0 "$C" "$(write_json a.sh $'#!/bin/bash\n# shellcheck disable=SC2086\necho $x')"
[ -s "$FAKE_LOG" ] && { echo "FAIL juge appelé sans commentaire à juger"; status=1; } || echo "ok   juge non appelé sans commentaire"
export FAKE_VERDICT=ok
t "verdict ok → 0"                 0 "$C" "$(write_json src/a.ts "$AVEC")"
export FAKE_VERDICT=muet
t "juge muet → 0"                  0 "$C" "$(write_json src/a.ts "$AVEC")"
export FAKE_VERDICT=ko
out=$(printf '%s' "$(write_json src/a.ts "$AVEC")" | CLAUDE_WORKFLOW_JUDGE_ACTIVE=1 bash "$C" 2>&1 >/dev/null); code=$?
[ "$code" = 0 ] && echo "ok   CLAUDE_WORKFLOW_JUDGE_ACTIVE neutralise" || { echo "FAIL CLAUDE_WORKFLOW_JUDGE_ACTIVE (exit $code)"; status=1; }
# Les flags d'allègement du démarrage (judge.sh) sont ce qui tient la latence : un retrait
# silencieux rendrait chaque jugement deux fois plus lent sans qu'aucun test ne le voie.
for flag in --safe-mode --strict-mcp-config --no-session-persistence --disable-slash-commands MAX_THINKING_TOKENS=0; do
  grep -q -- "$flag" "$FAKE_LOG.args" || { echo "FAIL juge appelé sans $flag"; status=1; }
done
grep -q -- '--strict-mcp-config' "$FAKE_LOG.args" && echo "ok   juge appelé avec les flags d'allègement"

echo "== stop-quality =="
S="$ROOT/hooks/scripts/stop-quality.sh"
stop_json() { jq -cn --arg m "$1" '{hook_event_name:"Stop",stop_hook_active:false,last_assistant_message:$m}'; }
LONG=$(printf 'Voici une explication détaillée et très longue du choix technique retenu. %.0s' $(seq 1 12))
export FAKE_VERDICT=ko
: > "$FAKE_LOG"
t "réponse courte sans question → 0"    0 "$S" "$(stop_json 'Fait.')"
[ -s "$FAKE_LOG" ] && { echo "FAIL juge appelé sur une réponse courte"; status=1; } || echo "ok   juge non appelé sur une réponse courte"
t "accent manquant → renvoyé"           2 "$S" "$(stop_json 'Le fichier existe deja.')"
t "réponse longue, verdict ko → 2"      2 "$S" "$(stop_json "$LONG")"
t "stop_hook_active → 0"                0 "$S" "$(jq -cn --arg m "$LONG" '{stop_hook_active:true,last_assistant_message:$m}')"
export FAKE_VERDICT=ok
t "réponse longue, verdict ok → 0"      0 "$S" "$(stop_json "$LONG")"
TR="$FAKE/transcript.jsonl"
jq -cn '{type:"assistant",message:{content:[{type:"text",text:"Le fichier existe deja."}]}}' > "$TR"
t "repli transcript sans last_assistant_message" 2 "$S" "$(jq -cn --arg p "$TR" '{stop_hook_active:false,transcript_path:$p}')"
rm -rf "$FAKE"

[ $status -eq 0 ] && echo "Hooks : OK" || echo "Hooks : ÉCHEC"
exit $status
