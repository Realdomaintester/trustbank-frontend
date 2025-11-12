#!/usr/bin/env bash
set -euo pipefail

# Run this from the repo root. This script will:
#  - create backup-before-replace branch (if missing) and push it
#  - create replace/all-with-new branch
#  - DESTRUCTIVELY remove tracked files in replace/all-with-new
#  - write new public/index.html, src/index.js, src/App.js, package.json, .gitignore
#  - commit and push replace/all-with-new
#
# IMPORTANT: If you want to preserve files like README.md, LICENSE, .github, or an existing package.json,
# DO NOT RUN this script. Instead tell me which to preserve and I will produce a non-destructive script.

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "This directory is not a git repository. cd into the repo root and run again."
  exit 1
fi

echo
echo "Repository: $(git remote get-url origin 2>/dev/null || echo origin:not-set)"
echo "Current branch: $(git branch --show-current)"
echo

if [ -n "$(git status --porcelain)" ]; then
  echo "Your working tree has uncommitted changes. Please commit or stash them before running this script."
  git status --porcelain
  exit 1
fi

git fetch origin
if git show-ref --verify --quiet refs/heads/main; then
  git checkout main
  git pull origin main
else
  echo "No local 'main' branch found. Attempting to create from origin/main..."
  git checkout -b main origin/main
fi

# Create backup branch if missing
if git show-ref --verify --quiet refs/heads/backup-before-replace; then
  echo "backup-before-replace already exists locally."
else
  echo "Creating backup-before-replace from main..."
  git checkout -b backup-before-replace
  git push -u origin backup-before-replace
  git checkout main
fi

# Create or reset feature branch
if git show-ref --verify --quiet refs/heads/replace/all-with-new; then
  echo "Local branch replace/all-with-new already exists; switching to it and resetting to main..."
  git checkout replace/all-with-new
  git reset --hard main
else
  echo "Creating branch replace/all-with-new from main..."
  git checkout -b replace/all-with-new
fi

echo
echo "!!! DESTRUCTIVE STEP !!!"
echo "This will REMOVE ALL TRACKED FILES in the branch replace/all-with-new (backup-before-replace preserves the previous main)."
echo "If you want to preserve particular files (README.md, LICENSE, .github, package.json, etc.) STOP now and tell me which to preserve."
read -p "Type the word YES (all caps) to continue: " confirm
if [ "$confirm" != "YES" ]; then
  echo "Aborting."
  exit 0
fi

echo "Removing all tracked files..."
git ls-files -z | xargs -0 -r git rm -rf --

echo "Creating new project files..."
mkdir -p public src

cat > public/index.html <<'HTML'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>TrustBank Frontend</title>
  </head>
  <body>
    <noscript>You need to enable JavaScript to run this app.</noscript>
    <div id="root"></div>
  </body>
</html>
HTML

cat > src/index.js <<'JS'
import React from 'react';
import { createRoot } from 'react-dom/client';
import App from './App';

const root = createRoot(document.getElementById('root'));
root.render(<App />);
JS

cat > src/App.js <<'JS'
import React from 'react';
import { Button } from '@mui/material';

export default function App() {
  return (
    <div style={{ padding: '2rem', fontFamily: 'Arial, sans-serif' }}>
      <h1>TrustBank Frontend</h1>
      <p>Welcome to your React app deployed on Vercel!</p>
      <Button variant="contained" color="primary">
        Get Started
      </Button>
    </div>
  );
}
JS

cat > package.json <<'JSON'
{
  "name": "trustbank-frontend",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "@mui/material": "^5.13.2",
    "@emotion/react": "^11.11.0",
    "@emotion/styled": "^11.11.0"
  },
  "devDependencies": {
    "vite": "^5.0.0"
  }
}
JSON

cat > .gitignore <<'TXT'
node_modules
dist
.env
TXT

git add .
git commit -m "Replace repository contents with new TrustBank frontend starter"
git push -u origin replace/all-with-new

echo
echo "Done: branch replace/all-with-new has been pushed."
echo "Open a PR from replace/all-with-new -> main on GitHub to merge."
echo "To test locally:"
echo "  npm install"
echo "  npm run dev"