#!/bin/bash
# Projet avec un index de specs vide : /pipe-spec sur un nom de feature doit explorer,
# puis ouvrir la première salve de questions par une vue haut niveau et s'arrêter.
set -e
git init -q -b develop .
git config user.email "eval@example.com"
git config user.name "Eval"
git remote add origin https://github.com/acme/demo.git
mkdir -p .claude/skills/workflow-config docs/specs src/factures
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
CFG
cat > docs/specs/README.md <<'IDX'
# Specs

| Spec | En une phrase |
|------|---------------|
IDX
cat > src/factures/facture.service.ts <<'TS'
export class FactureService {
  async findOne(id: string) { return { id, total: 120, client: "ACME" }; }
}
TS
git add .claude docs src
git commit -q -m "🎉 chore: initialisation"
