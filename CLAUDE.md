# Dotfiles repo — working notes for Claude

Chezmoi-managed dotfiles for a three-machine homelab: **samaritan** (workstation, Framework laptop), **sycamore** (server, NAS host), **willow** (server, NAS client + Intel QuickSync transcode). Remote: `ardenn/dotfiles` on GitHub, branch `main`.

This file is intentionally excluded from chezmoi's apply target (see `.chezmoiignore`, same treatment as `README.md`) — it's here for Claude's benefit, not deployed anywhere.

## Data model

`.chezmoi.toml.tmpl` computes three independent axes from hostname lists — not from a single `machineType` check:
- `machineType`: workstation | server
- `nasRole`: host | client — who serves NFS storage vs. who mounts it
- `transcodeRole`: none | quicksync — who does hardware transcoding

Also exposes `nasHostname`, `nasLanIP` (sycamore's identity/IP), `isFramework`.

**Adding a new machine**: append its hostname to the relevant list(s) in `.chezmoi.toml.tmpl`. No other file needs touching — every script branches on these role variables, not on hostnames or `machineType` alone.

## CI gotchas — both have broken CI before, don't reintroduce either

- `.github/workflows/test.yml` writes a **synthetic** `chezmoi.toml` directly via `printf`, bypassing `.chezmoi.toml.tmpl` entirely, to simulate different roles without needing real hostnames. **Any new data key added to `.chezmoi.toml.tmpl` must also be added to this synthetic config**, or CI fails with "map has no entry for key X" even though the real templating is fine.
- The shellcheck lint step replaces `{{ ... }}` template tokens with a placeholder **in place** (`sed -E 's/\{\{-?[^}]*-?\}\}/x/g'`), not by deleting whole lines. An earlier version deleted any line containing `{{`, which broke whenever a template interpolation shared a line with real bash control flow (e.g. `if grep -qF "{{ .var }}" ...; then`) — it silently ate the `if`/`then`, leaving an orphaned `else`/`fi` that failed to parse. Don't revert to line deletion.

## Local workflow gotchas

- Run `chezmoi init` before `apply`/`update` whenever `.chezmoi.toml.tmpl`'s data keys change — `chezmoi update` only *warns* about a stale local config, it doesn't regenerate it, and will then fail against the old values.
- `run_once_*` scripts don't self-heal when a tracked value changes (e.g. an IP, a hostname). Their idempotency checks (usually a `grep` for a specific string) only detect *presence*, not *correctness* — changing `nasLanIP` won't fix an already-written `/etc/fstab` line on a machine that's already been provisioned. Needs a manual live fix on the affected machine(s) alongside the dotfiles fix.
- NFS export changes on sycamore need `exportfs -ra` after editing `/etc/exports` — the file alone doesn't reload the kernel's live export table.
- `dconf.ini` is a raw `dconf dump /` snapshot of the *entire* system, not just extension state — regenerating it (the `dconf-export` alias) captures ordinary desktop usage drift too (window sizes, recent folders, etc.), which is expected and harmless. Cleaning up a stale/ghost GNOME extension means removing it from three places: the `enabled-extensions` list, any leftover `[org/gnome/shell/extensions/<name>]` settings section, and `disabled-extensions` if present.
- GNOME extensions only distributed via GitHub (not extensions.gnome.org) need the `install_extension_git` helper (git clone based) in the install script, not the curl+unzip `install_extension` helper.
- Flatpak apps can persist GSettings to a private sandboxed keyfile store instead of the shared dconf database, invisible to `dconf dump /` and unreachable by `dconf load /`. Before adding any Flatpak app's setting to `dconf.ini`, verify with `dconf dump /` that the key actually lands there. If it doesn't, configure it instead via `flatpak run --command=gsettings <app-id> set <schema> <key> <value>` in a script that runs after the app installs.
- Verify a live config change actually round-trips through the real mechanism before persisting it to the dotfiles — don't just trust that the mechanism looks structurally correct. This is what caught the Flatpak/dconf gotcha above.
- Fedora package name gotchas hit so far: `gnupg` → `gnupg2`, `util-linux-user` → `util-linux` (merged upstream), `delta` → `git-delta`, `cockpit-storage` → `cockpit-storaged`, `intel-media-driver` → `libva-intel-media-driver`. `mergerfs` isn't in any Fedora repo at all — install from the upstream GitHub release RPM matching the running Fedora version.

## Infrastructure reference

SSH aliases configured: `ssh willow`, `ssh sycamore` (both as user `rodgers`).

Sycamore runs its stack as rootless podman containers — check with `podman ps -a`, not `systemctl`. As of 2026-07 it includes: arcane (container manager UI), traefik, homer, pocketid, readeck, netbird, beszel + beszel-agent (monitoring, PocketBase API on internal network `10.89.1.2:8090`, needs auth), gluetun, jellyfin (no hardware transcode on sycamore itself), backrest (restic backups to Backblaze B2, repo `sycamore-cinemax-backblaze`, runs ~3am), seerr, the immich stack (server/machine-learning/redis/postgres/public-proxy), databasus, the *arr suite (bazarr/radarr/sonarr/prowlarr/profilarr/flaresolverr), qbittorrent/sabnzbd, cleanuparr, portcheck, miniflux (+ its own postgres), geopulse stack (postgres/backend/ui), home-assistant.

Storage: sycamore pools disks via mergerfs at `/mnt/storage` (not RAID — `/proc/mdstat` is empty despite an `mdadm` raid-check timer existing harmlessly), exported over NFS, mounted by clients at `/media/rodgers/nfs/sycamore`. ~13TB total.

## Known deliberate gaps

- Secure Boot KEK/db/dbx firmware updates on willow are left unapplied — firmware-level `EFI_SECURITY_VIOLATION` rejection, low priority given willow isn't exposed to the physical/local-access threat model those protect against.
- mergerfs/storage-export setup on a NAS host is intentionally manual-reference-only (the script prints instructions rather than auto-applying) — disk IDs and subnets are hardware-specific.
- Fedora Silverblue support was audited (every `dnf`/repo/systemctl dependency across all scripts catalogued, plus a few general bugs the audit surfaced that are worth fixing regardless of Silverblue) but paused before implementation. The open decision: whether CLI tools without a host-login requirement (git, gh, fzf, zoxide, bat, htop, delta) get rpm-ostree layered on the host like everything else, or provisioned inside a toolbox container instead (more idiomatic Silverblue, fewer reboots, bigger structural change). Detection would use `.chezmoi.osRelease.variantID == "silverblue"`, confirmed available in chezmoi templates — no `isSilverblue` data field exists yet.
