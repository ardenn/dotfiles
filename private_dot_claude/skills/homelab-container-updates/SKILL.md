---
name: homelab-container-updates
description: Weekly update sweep for the self-hosted container stacks on sycamore, willow and racknerd — find pending image updates, read release notes for breaking changes, upgrade whole stacks, verify health, and write a roundup of what's new. Use when the user asks to update their containers/services/homelab, or for "the Friday updates".
---

# Homelab container updates

Hosts and how each is managed:

| Host | Runtime | Stacks | Check | Upgrade |
|---|---|---|---|---|
| sycamore | rootless podman + compose CLI | `~/sycamore/<stack>` | Arcane API (env `Sycamore`) | Arcane API, except Quadlet stacks (`traefik`, `arcane`) and Quadlet jobs |
| willow | rootless podman + compose CLI | `~/sycamore/willow/<stack>` | Arcane API (env `Willow`) | Arcane API, except Quadlet stacks (`arcaneagent`) |
| racknerd | rootless Docker (`ssh ubuntu@racknerd`) | `~/netbird`, `~/beszel` | `scripts/docker-updates.sh` | SSH |

Arcane lists a `Racknerd` environment; it is stale and not used. Never manage racknerd through Arcane.

Scripts live in `scripts/` next to this file and run from samaritan. They read the Arcane API key from
`~/.config/arcane/api-key` (perms: environments:list, image-updates:check/read, projects:list/read/deploy,
images:list/read).

## Rules

- **Breaking changes need explicit approval.** If release notes contain a breaking change that affects this setup,
  stop and ask before upgrading that stack. Everything else proceeds without asking.
- **Always upgrade whole stacks** (`compose pull && compose up -d`, or Arcane's project `pull` + `up`), never single
  services or images.
- **Arcane cannot update itself or its agent**, so both are Quadlets (below).
- **Quadlet stacks** (`<stack>/*.container`, run with `~/sycamore/quadlet.sh`) are invisible to Arcane's update
  check and are upgraded by `podman auto-update`. `podman-auto-update.timer` stays disabled so nothing updates before
  its release notes are read.
- **Quadlet jobs** are one-shot `.container`s with a same-named `.timer` or `.path` and no `AutoUpdate=` (sycamore:
  `pocketid-backup`, `downloads-audit`, `docs-build`). Neither Arcane nor `podman auto-update` sees them, because no
  compose project or running container holds their image. Each run uses whatever image is local, so upgrading one means
  pulling its image. `pocketid-backup` shares `pocket-id:v2` with the `pocketid` compose service, so upgrading that
  stack upgrades the job too.
- Sequence netbird so the management server (racknerd) is upgraded before the peers on sycamore and willow.
- **If `gluetun` needs recreating** (image update or config change), don't use Arcane for the `arr` stack: several
  services share gluetun's network namespace, so podman refuses to remove it and compose leaves it half-renamed
  (`<id>_gluetun`) with the VPN-routed services down. Use SSH `docker-compose down && docker-compose up -d` in
  `~/sycamore/arr` instead, then confirm gluetun logs a public IP.
- **At most one `userns_mode: keep-id` service per stack.** Podman's Docker API gives all but one of several
  `keep-id` containers created in one deployment a one-entry ID map, and they sit in `Created` with `crun: mount
  devpts to dev/pts: Invalid argument`. Restarting reuses the bad map. If a compose change adds a second one, flag it;
  apps that can run as root inside (`PUID=0` or `user: "0:0"`) should do that instead, since rootless podman maps
  container root to `rodgers`.

## Procedure

1. **Find updates.**
   - `scripts/arcane-updates.sh --check` — forces a registry check on sycamore and willow, then prints one TSV row per
     service with an update or check error: host, project, status, service, image, update type.
   - `scripts/docker-updates.sh ubuntu@racknerd` — racknerd's local digests vs. the registry (looked up from
     samaritan, since racknerd's anonymous Docker Hub quota is often exhausted). `ratelimited` means retry later.
   - Quadlet stacks: `ssh <sycamore|willow> podman auto-update --dry-run --format '{{.Unit}} {{.Image}} {{.Updated}}'`
     (`pending` means an update is available). Resolve versions with `image-versions.sh` as usual.
   - Quadlet jobs: `scripts/quadlet-job-updates.sh <sycamore|willow>` prints `current`, `update` or `error` per job
     image, comparing local digests with the registry.
   - Pinned tags (e.g. `crowdsec:v1.8.1`) never show as updates by digest. List their compose `image:` lines and Quadlet
     `Image=` lines (e.g. `homer/docs-build.container`'s pandoc) and compare with `gh release list -R <repo>
     --exclude-pre-releases -L 3`. For netbird's stack, also compare with the pins in upstream's
     `infrastructure_files/getting-started.sh`, which is where racknerd's pins came from.

2. **Resolve versions.** Arcane only reports digests. `scripts/image-versions.sh <ssh-host> <image>...` prints
   local → registry versions from the `org.opencontainers.image.version` label. Where the label is missing or is a base
   OS version (`24.04`), get the running version from the app (`podman logs <c> | grep -i version`, `<bin> -v`) and
   the latest from `gh release list`. linuxserver tags like `6.4.4.10685-ls319 → -ls321` are image rebuilds of the
   same app version — no release notes to read.

3. **Read release notes** for every version skipped, not just the latest (`gh release view <tag> -R <repo> --json
   body -q .body`). Grep for `breaking|deprecat|migrat|removed|require|manual`, then judge each hit against this
   setup: check whether the affected integration/feature is actually in use before calling it breaking (e.g. grep
   Home Assistant's `.storage/core.config_entries` for an integration). Also check component compatibility (e.g. a
   beszel agent must not be newer than the hub on sycamore).

4. **Present the plan** — a table of host, stack, from → to, upgrade path, and any breaking change with whether it
   applies. If nothing applicable is breaking, proceed; otherwise wait for approval on those stacks.

5. **Upgrade.**
   - Arcane stacks: `scripts/arcane-deploy.sh <Sycamore|Willow> <project>...` (pull + up, then prints status and
     running/total counts).
   - Quadlet stacks: `ssh <host> systemctl --user start podman-auto-update.service`, which pulls and restarts
     every unit with `AutoUpdate=registry` and rolls back one that fails to start. Check the result with
     `journalctl --user -u podman-auto-update.service`.
   - Quadlet jobs: `ssh <host> podman pull -q <image>`, then run the job once to check it
     (`systemctl --user start <job>.service`; all three are safe to run off-schedule). For a pinned `Image=`, edit
     the file in the repo, commit, push, `git pull` on the host and pull the new image; pulling on sycamore also
     triggers `docs-build`.
   - SSH stacks on sycamore/willow (`docker` is only an interactive alias there):
     `ssh <host> 'export PATH=$HOME/.local/bin:$PATH DOCKER_HOST=unix:///run/user/$(id -u)/podman/podman.sock;
     cd ~/sycamore/<path> && docker-compose pull -q && docker-compose up -d'`
   - racknerd: `ssh ubuntu@racknerd 'cd ~/<stack> && docker compose pull -q && docker compose up -d'`.
   - If racknerd's pull hits Docker Hub's 429, side-load from samaritan:
     `skopeo copy --override-os linux --override-arch amd64 docker://docker.io/<img> docker-archive:<scratch>/img.tar:<img>`,
     `ssh ubuntu@racknerd docker load < <scratch>/img.tar`, then `docker compose up -d --pull never`. A side-loaded
     image has no registry digest, so `docker-updates.sh` keeps reporting it as `update` until a normal pull.
   - Bumping a pinned tag means editing the compose file on the host; back it up first (`cp <file>
     <file>.bak-$(date +%F)`) since racknerd's stacks aren't under git.

6. **Verify each stack** before moving to the next: containers up (healthy where a healthcheck exists), no
   `error|fatal|panic` in `logs --since 2m`, version label now matches, and the service answers over HTTP where it
   has a URL.
   - racknerd: `pgrep pasta` must still exist (see memory on the pasta crash), `https://netbird.makalila.org/` returns
     200, and `docker exec netbird-crowdsec cscli bouncers list` shows `netbird-proxy` with a fresh `last_pull`.
   - netbird-server runs DB migrations for ~30s after an upgrade; the proxy logs `connection refused` until then.
     Wait and recheck before treating it as a failure.
   - Quadlet jobs: the manual run's `systemctl --user show <job>.service -p Result --value` is `success`, and
     `quadlet.sh ps` in the stack's directory shows its trigger `linked` and `active`. `docs-build` should leave
     `docs.home.makalila.org` answering 200.
   - Arcane: `systemctl --user is-active arcane.service` and the container is `healthy`; `/api/version` shows the new
     version; after an agent upgrade both environments are `online`.
   - On sycamore and willow, no container is stuck in `Created`: `ssh <host> 'podman ps -a --filter status=created
     --format "{{.Names}}"'`. For each one, check its map with `podman inspect <c> --format
     '{{json .HostConfig.IDMappings}}'`: a lone `1000:0:1` entry is the `keep-id` bug above. Recreate the affected
     services one at a time over SSH (`docker-compose up -d --force-recreate --no-deps <service>`), which gives them a
     full map.
   - Nothing new under `~/containers`, `~/sycamore` or `/mnt/storage` (sycamore) is owned by anyone but `rodgers`,
     apart from `~/containers/databasus`: `find <path> -path ~/containers/databasus -prune -o ! -user rodgers -print`.
     A hit usually means an image now runs as a non-root user; switch it to root inside or `keep-id`.

7. **Re-run step 1** to confirm nothing is left pending.

8. **Write a roundup** of what's new across every updated service, for the user: grouped by service, most noteworthy
   first; new features worth trying, behaviour changes, security fixes relevant to this setup, and any follow-up
   actions. Skip dependency bumps and fixes for integrations not in use; list unremarkable services in a one-line
   footer. Delegating this to a subagent with the downloaded notes keeps the main context small.
