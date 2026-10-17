#!/usr/bin/env bash
# Print "<image>  <local version> -> <registry version>" from OCI version labels.
# Usage: image-versions.sh <ssh-host> <image>...   (host runs podman/docker; registry lookup uses local skopeo)
set -u
host=$1; shift
for image in "$@"; do
  local_v=$(ssh "$host" "podman image inspect -f '{{index .Labels \"org.opencontainers.image.version\"}}' $image 2>/dev/null || docker image inspect -f '{{index .Config.Labels \"org.opencontainers.image.version\"}}' $image")
  remote_v=$(skopeo inspect --no-tags --override-os linux --override-arch amd64 "docker://$image" 2>/dev/null | jq -r '.Labels["org.opencontainers.image.version"] // ""')
  printf '%s\t%s -> %s\n' "$image" "${local_v:-?}" "${remote_v:-?}"
done
