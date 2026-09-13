#!/bin/bash
# Dépôt avec un tag v1.0.0 puis quatre commits conventionnels, sans CHANGELOG : le skill
# doit proposer une section [Unreleased] et attendre la confirmation avant d'écrire.
set -e
git init -q -b develop .
git config user.email "eval@example.com"
git config user.name "Eval"
git remote add origin https://github.com/acme/demo.git
mkdir -p src
echo "v1" > src/app.ts
git add src
git commit -q -m "🎉 chore: version initiale"
git tag -a v1.0.0 -m "Release v1.0.0"
echo "export const exportPdf = () => 'pdf'" > src/export.ts
git add src/export.ts
git commit -q -m "✨ feat(factures): export PDF d'une facture depuis sa page"
echo "fix" >> src/app.ts
git add src/app.ts
git commit -q -m "🐛 fix(auth): la session expirait après 5 minutes au lieu de 30"
echo "refactor" >> src/app.ts
git add src/app.ts
git commit -q -m "♻️ refactor(auth): extraire la lecture du token"
echo "ci" > .ci
git add .ci
git commit -q -m "🔧 chore(ci): cache des dépendances"
