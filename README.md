# dotfiles

Personal dotfiles for Fedora Linux, managed with [chezmoi](https://github.com/twpayne/chezmoi).

Supports two machine roles, detected automatically from hostname:

| Hostname | Role | Description |
|----------|------|-------------|
| anything else | `workstation` | Full desktop setup — GNOME, apps, fonts, Mullvad |
| `sycamore` | `server` | Headless server — containers, NFS, Cockpit |

## Install

On a fresh machine, run:

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin init --apply ardenn
```

This installs chezmoi and applies the dotfiles in one step. The machine role and Framework laptop
detection are resolved automatically at init time — no prompts required.

## What gets set up

Scripts run in order. Steps marked **W** are workstation-only, **S** are server-only, unmarked run on both.

| Step | Script | What it does |
|------|--------|--------------|
| 1 | `before_10` | Installs base packages (zsh, fzf, zoxide, gh, bat, …) |
| 1W | `before_10` | Installs Chrome, Mullvad, Ghostty, Flatpaks, Brave, Zed, Fly.io |
| 1S | `before_10` | Installs cockpit, fail2ban, mergerfs, delta, rsync, smartmontools |
| 1S | `before_10` | Installs Docker Compose binary to `~/.local/bin` |
| 2W | `before_11` | Removes unwanted Fedora defaults (Rhythmbox, LibreOffice, etc.) |
| 3 | `before_20` | Sets ZSH as the default shell |
| 4W | `before_30` | Downloads all GNOME Shell extensions from extensions.gnome.org |
| 5 | *(dotfiles)* | chezmoi deploys config files to `~` |
| 6W | `after_89` | Deploys Tailscale + Mullvad nftables firewall rules |
| 7W | `after_90` | Installs JetBrains Mono and Nerd Fonts Symbols |
| 8W | `after_91` | Registers the sycamore NFS share in `/etc/fstab` |
| 9S | `after_92` | Prints storage reference (fstab, mergerfs, NFS exports) |
| 10 | `after_9999` | Enables SSH service, generates ed25519 keypair |
| 10W | `after_9999` | Configures Bluetooth, prints workstation checklist |
| 10S | `after_9999` | Enables linger, podman socket, Cockpit, fail2ban |
| - W | `run_once_90` | Loads dconf settings and enables fractional scaling |

## What's managed

### Both machines
- **Shell** — ZSH config, aliases, Starship prompt
- **Git** — `~/.gitconfig`, global `.gitignore`
- **Containers** — `DOCKER_HOST` for rootless Podman; Docker Compose as podman's external provider

### Workstation only
- **Editors** — Zed settings
- **Terminals** — Kitty, Ghostty, Terminator
- **GNOME** — dconf settings (extensions, fonts, input, power, night light, keybindings)
- **GNOME extensions** — 12 extensions auto-installed and configured
- **Network** — Tailscale + Mullvad VPN nftables rules
- **Media** — mpv hardware decode config
- **Audio** — WirePlumber UCM override

## Post-install checklist

After `chezmoi apply` completes, the final script prints a role-specific checklist.

### Workstation
```sh
eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_ed25519
gh auth login
gh ssh-key add ~/.ssh/id_ed25519.pub --title "$(hostname)"
sudo tailscale up
mount /media/rodgers/nfs/sycamore   # after Tailscale is connected
```

Then log out and back in — ZSH activates as the default shell and GNOME extensions load on first session.

### Server (sycamore)
```sh
gh auth login
gh ssh-key add ~/.ssh/id_ed25519.pub --title "$(hostname)"
sudo tailscale up
sudo mount -a          # after configuring /etc/fstab (see storage reference above)
sudo exportfs -v       # verify NFS exports
```

The storage reference script (`after_92`) prints the expected fstab and `/etc/exports` entries
with the current disk IDs and subnets. Adjust for your hardware before running `mount -a`.

## Keeping things current

**GNOME settings changed?**
```sh
dconf-export   # alias defined in ~/.aliases
git -C ~/.local/share/chezmoi diff dconf.ini
# review, strip any machine-specific noise, then commit
```

**New dotfile to track?**
```sh
chezmoi add ~/.config/some/file
chezmoi cd
git add . && git commit -m "Track some/file"
```

## Requirements

- Fedora Linux (scripts are Fedora-first; Debian support is partial)
- A Tailscale account (for VPN and sycamore NFS access)
- A GitHub account (for `gh` SSH key automation)
