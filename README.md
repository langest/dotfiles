My dotfiles.
===

My awesome dotfiles.
:hamster:

## Install
- Run `scripts/install.sh` for a dry-run; add `--apply` to make changes.
- Use `--no-packages` to skip package installs if you only want links.
- Use `--no-docker` to skip Docker Engine setup.
- Use `--no-dropbox` to skip Dropbox install.
- Use `--no-links` to skip all symlink creation.
- Use `--no-xdg` to skip XDG directory symlinks into `~/dropvault`.
- Use `--no-validate` to skip end-of-run link validation output.
- Targeted at Debian/apt systems and expects `sudo` for package work.

What is linked by default:
- Dotfiles: `~/.bashrc`, `~/.tmux.conf`, `~/.ideavimrc`.
- XDG configs: `~/.config/sway`, `~/.config/waybar`, `~/.config/nvim`, `~/.config/foot`.
- User dirs config: `~/.config/user-dirs.dirs`, `~/.config/user-dirs.conf`.
- XDG user dirs are set up as symlinks into `~/dropvault` based on `config/user-dirs.dirs`.

## Post-install
Dropbox daemon is 64-bit only and not signed.
Start the daemon after install:

```bash
~/.dropbox-dist/dropboxd
```

Docker Engine is installed via Docker's apt repository with the embedded GPG key.
The installer removes conflicting Docker packages before Docker Engine install:
`docker.io docker-compose docker-doc podman-docker containerd runc`

To use Docker without `sudo` and confirm the daemon:

```bash
sudo usermod -aG docker "$USER"
newgrp docker
sudo systemctl status docker
```

If your shell is not bash, switch default shell for these dotfiles:

```bash
chsh -s "$(command -v bash)"
```

Desktop services you likely want enabled:

```bash
sudo systemctl enable --now tlp
systemctl --user enable --now pipewire pipewire-pulse wireplumber
```

## Theming (Omarchy compatible)
This repo now uses one canonical theme path:
- `~/.config/omarchy/themes`

Built-in themes from local `omarchy-repo/themes` are synced as symlinks into that path.
User-installed themes also live in the same path.

Theme commands:

```bash
scripts/theme/theme.sh list
scripts/theme/theme.sh set tokyo-night
scripts/theme/theme.sh current
scripts/theme/theme.sh refresh
scripts/theme/theme.sh install <git-repo-url>
scripts/theme/theme.sh update
scripts/theme/theme.sh remove <theme-name>
scripts/theme/theme.sh btop
scripts/theme/theme.sh foot
scripts/theme/theme.sh nvim
scripts/theme/theme.sh wofi
scripts/theme/theme.sh swaylock
scripts/theme/theme.sh lock
```

Notes:
- `OMARCHY_PATH` can be set to use a different Omarchy checkout.
- Use `scripts/theme/theme.sh sync` to resync built-in local themes into `~/.config/omarchy/themes`.
- Security validation is centralized in `scripts/theme/lib/validate.sh`.
- Active theme state is stored in `~/.config/omarchy/current/theme` and `~/.config/omarchy/current/theme.name`.
- Waybar style imports `~/.config/omarchy/current/theme/waybar.css` with local fallback colors when no theme is active.
- Sway border highlighting is generated to `~/.config/omarchy/current/theme/sway.theme` and applied via `swaymsg`.
- Sway lock color is generated to `~/.config/omarchy/current/theme/swaylock.color`, copied to `~/.config/swaylock/color`, and used by `scripts/theme/lock.sh`.
- Foot theme is copied to `~/.config/foot/omarchy-theme.ini` and included by `config/foot/foot.ini`.
- Neovim theme overrides are copied to `~/.config/nvim/omarchy-theme.vim` and sourced from `config/nvim/init.vim`.
- Wofi theme is copied to `~/.config/wofi/style.css`.
- btop theme is copied to `~/.config/btop/themes/omarchy.theme` and selected in `~/.config/btop/btop.conf`.
- Chromium color policy is applied from the active theme when `/etc/chromium/policies/managed` is writable.
- Firefox theme overlay is applied to profiles in `~/.mozilla/firefox` via `chrome/omarchy-theme.css`.
