---
name: dotfiles-drift-audit
description: Audit this chezmoi dotfiles repo for drift between what's tracked and what's actually live on samaritan/sycamore/willow (GNOME extensions, dconf, flatpaks, packages), fix discrepancies, and ship the result. Use whenever the user asks to check if their dotfiles are up to date, sync recent local changes into the repo, or generally "see what's changed."
---

Not a project-scoped skill for a specific bug — this is the recurring maintenance sweep for `~/.local/share/chezmoi`. See the repo's own `CLAUDE.md` for the architecture and accumulated gotchas; this skill is the procedure for using that knowledge to actually find and fix drift.

## Procedure

1. **Sync first.** `git pull origin main` in the source dir before doing anything — other sessions/machines may have pushed since you last looked. Read the new commits if any are unfamiliar; don't just proceed blind.

2. **Check chezmoi's own view of drift.** `chezmoi status` — `R` entries are `run_once` scripts pending a real apply (expected/normal if the user hasn't run a full `chezmoi apply` recently, not itself a problem to fix). `MM`/other entries on regular files are real drift between the live file and tracked source — worth a `chezmoi diff -- <path>` to see what changed and which direction it should resolve (did the user intentionally change something live that should flow into the repo, or did the tracked source just never get applied here).

3. **Compare live state against tracked state, per dimension:**
   - **GNOME extensions**: `gsettings get org.gnome.shell enabled-extensions` vs. the `enabled-extensions` line in `dconf.ini`. A live-only entry with no installed directory under `~/.local/share/gnome-shell/extensions/` is a ghost (ask if the user recognizes it — check `extensions.gnome.org`'s `extension-info` API by UUID if not; it may be a since-abandoned alternative to something else already tracked, as happened with `fullscreen-to-empty-workspace2` vs. `maximise-to-workspace`). A tracked-only entry that's genuinely wanted just needs re-syncing; if the user says they removed it, drop it from three places: the install script's `install_extension`/`install_extension_git` call, `dconf.ini`'s `enabled-extensions` list, and any leftover `[org/gnome/shell/extensions/<name>]` settings section.
   - **Flatpaks**: `flatpak list --app --columns=application` vs. the `flatpaks` array in `run_once_before_10-install-packages-linux.sh.tmpl`.
   - **Packages actually installed vs. `server_packages`/`workstation_packages`/`base_packages`** if there's reason to suspect drift (e.g. after manually installing something during troubleshooting).
   - **Other dotfiles**: `chezmoi unmanaged`, filtered to exclude the obvious noise (browser/app caches, `.config/*` for unrelated apps, personal project folders like `ledger`/`ncba-tracker`/`boondocks`) — anything left over is a candidate for `chezmoi add` or `chezmoi re-add` if it's a genuine config file worth tracking.

4. **Before writing any fix, verify it against live state** — don't persist a change on the assumption the mechanism is obviously correct (see the Flatpak/dconf gotcha in `CLAUDE.md`: some apps' settings don't even land in the place you'd expect).

5. **After editing, verify with `chezmoi apply --dry-run`** before committing. If `.chezmoi.toml.tmpl`'s data keys changed, also run `chezmoi init` to regenerate the local config, and update `.github/workflows/test.yml`'s synthetic config generation to match (the CI gotcha — it bypasses `.chezmoi.toml.tmpl` entirely).

6. **Commit with a clear, specific message, push, then watch CI to green**: `gh run watch <run-id> --interval 10`. Don't consider the sweep done until CI passes.

7. **Summarize what changed** — which drift was found, which direction each was resolved, and what (if anything) still needs a live fix on a specific machine that this sweep can't do remotely (e.g. anything needing `sudo` over a non-interactive SSH session).

## Notes

- SSH aliases `willow` and `sycamore` are configured — use them directly for cross-machine comparisons rather than asking the user to paste output, but `sudo` on either needs an interactive password this session doesn't have; give the user the exact command instead of guessing at what a failed non-interactive sudo attempt means.
- Not every difference is a bug to fix — some drift is a deliberate choice (e.g. Secure Boot updates left unapplied on willow). Ask rather than assume when the right direction isn't obvious from context.
