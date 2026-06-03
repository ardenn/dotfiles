# dotfiles

Personal dotfiles for Fedora Linux, managed with [chezmoi](https://github.com/twpayne/chezmoi).

## Install

On a fresh machine, run:

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin init --apply ardenn
```

This installs chezmoi and applies the dotfiles in one step.

## What gets set up

The install runs a sequence of scripts in order:

| Step | Script | What it does |
|------|--------|--------------|
| 1 | `before_10` | Installs DNF packages, Flatpaks, Brave, Zed, Tailscale, Starship, Fly.io |
| 2 | `before_11` | Removes unwanted Fedora defaults (Rhythmbox, LibreOffice, etc.) |
| 3 | `before_20` | Sets ZSH as the default shell |
| 4 | `before_30` | Downloads all GNOME Shell extensions from extensions.gnome.org |
| 5 | *(dotfiles)* | chezmoi deploys config files to `~` |
| 6 | `after_89` | Deploys Tailscale + Mullvad nftables firewall rules |
| 7 | `after_90` | Installs JetBrains Mono and Nerd Fonts Symbols |
| 8 | `after_91` | Registers the sycamore NFS share in `/etc/fstab` |
| 9 | `after_9999` | Configures Bluetooth, SSH, generates an ed25519 keypair |
| — | `run_once_90` | Loads dconf settings and enables fractional scaling |

## What's managed

- **Shell** — ZSH config, aliases, Starship prompt
- **Editors** — Zed settings
- **Terminals** — Kitty, Ghostty, Terminator
- **Git** — `~/.gitconfig`, global `.gitignore`
- **GNOME** — dconf settings (extensions, fonts, input, power, night light, keybindings)
- **GNOME extensions** — 12 extensions auto-installed and configured
- **Containers** — rootless Podman networking via `pasta`
- **Network** — Tailscale + Mullvad VPN nftables rules
- **Media** — mpv hardware decode config
- **Audio** — WirePlumber UCM override

## Post-install checklist

After `chezmoi apply` completes, the final script prints a checklist. Key steps:

```sh
eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_ed25519
gh auth login
gh ssh-key add ~/.ssh/id_ed25519.pub --title "$(hostname)"
sudo tailscale up
mount /media/rodgers/nfs/sycamore   # after Tailscale is connected
```

Then log out and back in — ZSH activates as the default shell and GNOME extensions load on first session.

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
