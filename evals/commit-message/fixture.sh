#!/bin/bash
# Dépôt minimal pour /pipe-commit en mode simple : un remote, un commit initial, une
# modification non commitée et aucun pilotage.
set -e
git init -q -b develop .
git config user.email "eval@example.com"
git config user.name "Eval"
git remote add origin https://github.com/acme/demo.git
mkdir -p .claude/skills/workflow-config src
cat > .claude/skills/workflow-config/SKILL.md <<'CFG'
---
name: workflow-config
description: Config du workflow pour ce projet.
user-invocable: false
disable-model-invocation: true
---

## Plateforme

- **Git hosting** : GitHub
- **Issue tracker** : GitHub Issues
- **Branche par defaut** : develop
- **Branche de production** : main

## Commandes

- **Lint** : npx eslint .
- **Format** : npx prettier --write .
- **Test** : npx vitest run
CFG
cat > src/email.ts <<'TS'
export function isValidEmail(value: string): boolean {
  return value.includes("@");
}
TS
git add .claude src
git commit -q -m "🎉 chore: initialisation"
cat > src/email.ts <<'TS'
const EMAIL = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

export function isValidEmail(value: string): boolean {
  return EMAIL.test(value.trim());
}
TS
