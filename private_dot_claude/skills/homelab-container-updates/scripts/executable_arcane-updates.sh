#!/usr/bin/env bash
# List images with pending updates (or check errors) per Arcane project on sycamore and willow.
# Usage: arcane-updates.sh [--check]   (--check forces a fresh registry check first)
set -euo pipefail
api=https://arcane.home.makalila.org/api
key=$(cat ~/.config/arcane/api-key)
call() { curl -sf -m 300 -H "X-API-Key: $key" -H 'Content-Type: application/json' "$@"; }

call "$api/environments" | jq -r '.data[] | select(.name == "Sycamore" or .name == "Willow") | [.id, .name] | @tsv' |
while IFS=$'\t' read -r env name; do
  [ "${1:-}" = --check ] && call -X POST -d '{}' "$api/environments/$env/image-updates/check-all" >/dev/null
  call "$api/environments/$env/projects?limit=200" | jq -r '.data[] | [.id, .name, .status] | @tsv' |
  while IFS=$'\t' read -r pid pname pstatus; do
    call "$api/environments/$env/projects/$pid/updates" | jq -r --arg host "$name" --arg p "$pname" --arg s "$pstatus" '
      .data.updateInfo.serviceUpdates // {} | to_entries[]
      | select(.value.updateInfo.hasUpdate or (.value.updateInfo.error // "") != "")
      | [$host, $p, $s, .key, .value.imageRef, .value.updateInfo.updateType,
         (.value.updateInfo.latestVersion // ""), (.value.updateInfo.error // "")] | @tsv'
  done
done
