#!/usr/bin/env bash
# Compare the local image of each Quadlet job on a podman host (linked .container without AutoUpdate=, so neither
# Arcane nor podman auto-update covers it) with the registry's current digest for its tag.
# Prints one TSV row per job image: status (current|update|error), unit file, image.
# Usage: quadlet-job-updates.sh <ssh-destination>   e.g. quadlet-job-updates.sh sycamore
set -u
ssh "$1" 'for f in ~/.config/containers/systemd/*.container; do
    [ -e "$f" ] || continue
    grep -q "^AutoUpdate=" "$f" && continue
    image=$(sed -n "s/^Image=//p" "$f")
    printf "%s\t%s\t%s\n" "${f##*/}" "$image" "$(podman image inspect --format "{{range .RepoDigests}}{{.}} {{end}}" "$image" 2>/dev/null)"
  done' |
while IFS=$'\t' read -r unit image local_digests; do
  if remote_digest=$(skopeo inspect --format '{{.Digest}}' "docker://$image" 2>/dev/null); then
    case " $local_digests" in
      *"@$remote_digest"*) status=current ;;
      *) status=update ;;
    esac
  else
    status=error
  fi
  printf '%s\t%s\t%s\n' "$status" "$unit" "$image"
done
