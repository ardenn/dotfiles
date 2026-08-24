---
name: sync-local-change
description: Get one specific local change — a file, or a whole directory tree like ~/.claude — into the tracked chezmoi source correctly. Use when the user already knows what changed and just wants it captured — not a full drift audit.
---

# Sync a local change into dotfiles

This is the lightweight counterpart to `dotfiles-drift-audit`. Use this one when the user (or you) already knows what changed locally — a single file, or a known directory tree such as `~/.claude` after adding a new skill under it — and just wants it captured into the tracked chezmoi source. Reach for `dotfiles-drift-audit` instead when the ask is more open-ended ("check if anything's drifted", "sync up dotfiles" with no specific target in mind).

A target here can be a single file (`~/.zshrc`) or a directory (`~/.claude`) — `chezmoi diff`/`chezmoi add` both work recursively on a directory, picking up every new/changed file under it in one pass. That's still the lightweight path, not a drift audit: it doesn't touch anything outside the given target, and does no cross-machine or GNOME/flatpak/package comparison.

## Procedure

1. **Never edit the chezmoi source tree directly.** The change must already exist at its real target path (e.g. `~/.zshrc`, `~/.claude/CLAUDE.md`, or a new file under `~/.claude/skills/...`) — if it doesn't yet, make it there first, not under `~/.local/share/chezmoi/...`.

2. **Preview before adding**: `chezmoi diff <target-path>`, where `<target-path>` can be a single file or a directory (e.g. `~/.claude` to pick up everything changed/added under it at once). Confirm the diff is exactly what you expect. Always scope this to the specific target; a bare `chezmoi diff`/`chezmoi apply` with no target will also surface unrelated pending `run_once` scripts that have never been applied on this machine (see the repo's `CLAUDE.md`).

3. **Add it**: `chezmoi add <target-path>` — same target, file or directory. This lets chezmoi infer the right source naming/attributes (`executable_`, `private_`, etc.) itself for everything under it — don't hand-construct source-tree paths yourself, and don't add each new file one at a time when they all belong to the same change (e.g. a new skill directory).

4. **Verify**: `cd ~/.local/share/chezmoi && git status --short` should show exactly the files you expect for this change, nothing else pulled in unintentionally.

5. **Commit only if asked, push only if asked** — these are separate confirmations, per the global CLAUDE.md git commit constraints. Don't chain straight from `add` to `commit`/`push` without the user asking for each.

## Notes

- If `.chezmoi.toml.tmpl`'s data keys changed as part of this, that's out of scope for this skill — that needs `chezmoi init` to regenerate the local config, plus a matching update to `.github/workflows/test.yml`'s synthetic config (see the repo's `CLAUDE.md` CI gotchas). Flag it and consider `dotfiles-drift-audit` instead if the change is broader than what a single `chezmoi add <target>` cleanly captures.
