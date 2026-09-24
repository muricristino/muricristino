#!/usr/bin/env bash
# Rewrites the list between the repos markers in README.md from the public,
# non-fork, non-archived repos of the owner. Description comes from GitHub.
set -euo pipefail
owner="${GITHUB_REPOSITORY_OWNER:?}"

list=$(gh repo list "$owner" --visibility public --source --no-archived --limit 100 \
  --json name,url,description \
  --jq "sort_by(.name) | .[] | select(.name != \"$owner\")
        | \"- [\(.name)](\(.url))\" + (if .description then \": \(.description)\" else \"\" end)")

awk -v list="$list" '
  /<!-- repos:start -->/ { print; print list; skip = 1; next }
  /<!-- repos:end -->/   { skip = 0 }
  !skip
' README.md > README.md.new
mv README.md.new README.md
