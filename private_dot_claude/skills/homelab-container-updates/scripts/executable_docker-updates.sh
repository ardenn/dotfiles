#!/usr/bin/env bash
# Compare each running container's local image digest on a docker host with the registry's current digest for its tag.
# Registry lookups run here with skopeo, not on the host, so the host's anonymous Docker Hub quota is left alone.
# Usage: docker-updates.sh <ssh-destination>   e.g. docker-updates.sh ubuntu@racknerd
set -u
ssh "$1" 'docker ps --format "{{.Image}}\t{{.Label \"com.docker.compose.project.working_dir\"}}" | sort -u |
  while IFS="	" read -r image dir; do
    printf "%s\t%s\t%s\n" "$image" "$dir" "$(docker image inspect -f "{{range .RepoDigests}}{{.}} {{end}}" "$image" | cut -d" " -f1 | cut -d@ -f2)"
  done' |
while IFS=$'\t' read -r image dir local_digest; do
  if raw=$(skopeo inspect --raw "docker://$image" 2>&1); then
    remote_digest=sha256:$(printf '%s' "$raw" | sha256sum | cut -d' ' -f1)
    if [ "$local_digest" = "$remote_digest" ]; then status=current; else status=update; fi
  elif grep -q '429' <<<"$raw"; then status=ratelimited
  else status=error; fi
  printf '%s\t%s\t%s\n' "$status" "$dir" "$image"
done
