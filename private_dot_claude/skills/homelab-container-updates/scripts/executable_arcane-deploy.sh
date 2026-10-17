#!/usr/bin/env bash
# Pull and redeploy whole Arcane projects (compose pull && up -d), then report their status.
# Usage: arcane-deploy.sh <environment name> <project>...
set -euo pipefail
api=https://arcane.home.makalila.org/api
key=$(cat ~/.config/arcane/api-key)
call() { curl -sS -m 900 -H "X-API-Key: $key" -H 'Content-Type: application/json' "$@"; }

envname=$1; shift
env=$(call "$api/environments" | jq -r --arg n "$envname" '.data[] | select(.name == $n) | .id')
[ -n "$env" ] || { echo "no environment named $envname" >&2; exit 1; }
projects=$(call "$api/environments/$env/projects?limit=200")

for name in "$@"; do
  pid=$(jq -r --arg n "$name" '.data[] | select(.name == $n) | .id' <<<"$projects")
  [ -n "$pid" ] || { echo "$name: not found in $envname" >&2; continue; }
  echo "== $envname/$name"
  call -X POST "$api/environments/$env/projects/$pid/pull" | grep -iE '"error"|failed' | head -5 || true
  call -X POST -d '{}' "$api/environments/$env/projects/$pid/up" | grep -iE '"error"|failed' | head -5 || true
  call "$api/environments/$env/projects/$pid" |
    jq -r '.data | "status=\(.status) running=\(.runningCount)/\(.serviceCount)"'
done
