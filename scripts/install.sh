#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: install.sh [--apply] [--no-packages] [--no-docker] [--no-dropbox] [--no-links] [--no-xdg] [--no-validate] [--help]

By default runs in dry-run mode (no changes). Use --apply to perform actions.

Options:
  --apply         Execute changes (packages + links). Without it, dry-run.
  --no-packages   Skip apt-get update/install steps.
  --no-docker     Skip Docker Engine install.
  --no-dropbox    Skip Dropbox install.
  --no-links      Skip dotfile/config symlinks.
  --no-xdg        Skip XDG user dir setup.
  --no-validate   Skip link validation output.
  --help, -h      Show this help.
EOF
}

apply=false
skip_packages=false
skip_docker=false
skip_dropbox=false
skip_links=false
skip_xdg=false
skip_validate=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply) apply=true ;;
    --no-packages) skip_packages=true ;;
    --no-docker) skip_docker=true ;;
    --no-dropbox) skip_dropbox=true ;;
    --no-links) skip_links=true ;;
    --no-xdg) skip_xdg=true ;;
    --no-validate) skip_validate=true ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
  shift
done

log() {
  printf '%s\n' "$*"
}

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
timestamp="$(date +%s)"

ensure_apt() {
  if ! command -v apt-get >/dev/null 2>&1; then
    echo "apt-get not found; this script targets Debian/apt systems." >&2
    exit 1
  fi
}

SUDO=""
if [[ "$(id -u)" -ne 0 ]]; then
  if command -v sudo >/dev/null 2>&1; then
    SUDO="sudo "
  else
    if $apply && (! $skip_packages || ! $skip_docker); then
      echo "This script needs root privileges for package installs; sudo not found." >&2
      exit 1
    fi
    log "WARN: sudo not found; proceeding because no root-required steps will run."
  fi
fi

PACKAGES=(
  7zip
  adduser
  alsa-utils
  audacity
  btop
  build-essential
  ca-certificates
  chromium
  cups
  curl
  darktable
  dosfstools
  evince
  feh
  ffmpeg
  firefox-esr
  fonts-cascadia-code
  fonts-dejavu
  fonts-firacode
  fonts-font-awesome
  fonts-hack
  fonts-jetbrains-mono
  fonts-material-design-icons-iconfont
  fonts-noto
  fonts-noto-cjk
  fonts-noto-color-emoji
  fonts-noto-mono
  fonts-powerline
  fonts-symbola
  fonts-vlgothic
  fuse3
  gimp
  git
  gocryptfs
  gzip
  htop
  imagemagick
  jq
  keepassxc
  krita
  libvirglrenderer-dev
  libvirglrenderer1
  mesa-utils
  mesa-vulkan-drivers
  mpv
  mpv-mpris
  mupdf
  nano
  ncal
  ncdu
  neovim
  network-manager-applet
  passwd
  pavucontrol
  pipewire
  pipewire-bin
  pipewire-pulse
  playerctl
  podman
  podman-compose
  printer-driver-brlaser
  pulseaudio-utils
  python3
  python3-dev
  python3-pip
  python3-venv
  qemu-system
  qemu-system-x86
  silversearcher-ag
  sudo
  sway
  swayidle
  swaylock
  tar
  thunar
  thunderbird
  tlp
  tmux
  traceroute
  tree
  tuigreet
  unzip
  usbutils
  virt-manager
  virtiofsd
  waybar
  wev
  wget
  wireplumber
  wl-clipboard
  wofi
  xdg-user-dirs
  xwayland
  yt-dlp
  zip
)

run_or_echo() {
  if $apply; then
    eval "$1"
  else
    log "DRY-RUN: $1"
  fi
}

BACKUPS=()

backup_target() {
  local target="$1"
  local backup="${target}.bak.${timestamp}"
  run_or_echo "mv \"$target\" \"$backup\""
  if $apply; then
    BACKUPS+=("$backup")
  fi
}

ensure_dir() {
  local dir="$1"
  run_or_echo "mkdir -p \"$dir\""
}

link_item() {
  local relative="$1"
  local dest="$2"
  local src="${repo_root}/${relative}"

  if [[ ! -e "$src" ]]; then
    echo "Source missing: $src" >&2
    return 1
  fi

  ensure_dir "$(dirname "$dest")"

  if [[ -L "$dest" ]]; then
    local current
    current="$(readlink -f "$dest" || true)"
    local src_real
    src_real="$(readlink -f "$src" || true)"
    if [[ "$current" == "$src_real" ]]; then
      log "OK: $dest already links to $src"
      return 0
    fi
    backup_target "$dest"
  elif [[ -e "$dest" ]]; then
    backup_target "$dest"
  fi

  run_or_echo "ln -s \"$src\" \"$dest\""
  if $apply; then
    log "Linked $dest -> $src"
  else
    log "Would link $dest -> $src"
  fi
}

check_link() {
  local relative="$1"
  local dest="$2"
  local src="${repo_root}/${relative}"

  if [[ -L "$dest" ]]; then
    local current
    current="$(readlink -f "$dest" || true)"
    local src_real
    src_real="$(readlink -f "$src" || true)"
    if [[ "$current" == "$src_real" ]]; then
      log "VALID: $dest -> $src"
      return 0
    fi
  fi
  if [[ -e "$dest" ]]; then
    log "WARN: $dest exists but is not linked to $src"
  else
    log "WARN: $dest missing"
  fi
}

install_packages() {
  if $skip_packages; then
    log "Skipping package installation (--no-packages)."
    return
  fi

  ensure_apt
  log "Package install (${#PACKAGES[@]} packages)."
  if $apply; then
    ${SUDO}DEBIAN_FRONTEND=noninteractive apt-get update -y
    ${SUDO}DEBIAN_FRONTEND=noninteractive apt-get install -y "${PACKAGES[@]}"
  else
    log "DRY-RUN: ${SUDO}DEBIAN_FRONTEND=noninteractive apt-get update -y"
    log "DRY-RUN: ${SUDO}DEBIAN_FRONTEND=noninteractive apt-get install -y ${PACKAGES[*]}"
  fi
}

install_docker_engine() {
  if $skip_docker; then
    log "Skipping Docker install (--no-docker)."
    return
  fi

  if $skip_packages; then
    log "Skipping Docker install (--no-packages)."
    return
  fi

  ensure_apt

  local codename=""
  if [[ -f /etc/os-release ]]; then
    codename="$(. /etc/os-release && echo "${VERSION_CODENAME:-}")"
  fi

  if [[ -z "$codename" ]]; then
    log "Cannot detect Debian codename from /etc/os-release; skipping Docker install."
    return
  fi

  log "Docker install will remove conflicting packages: docker.io docker-compose docker-doc podman-docker containerd runc"

  if $apply; then
    ${SUDO}DEBIAN_FRONTEND=noninteractive apt-get remove -y \
      docker.io docker-compose docker-doc podman-docker containerd runc
    ${SUDO}DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates
    ${SUDO}install -m 0755 -d /etc/apt/keyrings
    cat <<'EOF' | ${SUDO}tee /etc/apt/keyrings/docker.asc >/dev/null
-----BEGIN PGP PUBLIC KEY BLOCK-----

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
YT90qFF93M3v01BbxP+EIY2/9tiIPbrd
=0YYh
-----END PGP PUBLIC KEY BLOCK-----
EOF
    ${SUDO}chmod a+r /etc/apt/keyrings/docker.asc
    cat <<EOF | ${SUDO}tee /etc/apt/sources.list.d/docker.sources >/dev/null
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: ${codename}
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF
    ${SUDO}DEBIAN_FRONTEND=noninteractive apt-get update -y
    ${SUDO}DEBIAN_FRONTEND=noninteractive apt-get install -y \
      docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  else
    log "DRY-RUN: ${SUDO}DEBIAN_FRONTEND=noninteractive apt-get remove -y docker.io docker-compose docker-doc podman-docker containerd runc"
    log "DRY-RUN: ${SUDO}DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates"
    log "DRY-RUN: ${SUDO}install -m 0755 -d /etc/apt/keyrings"
    log "DRY-RUN: write embedded Docker GPG key to /etc/apt/keyrings/docker.asc"
    log "DRY-RUN: ${SUDO}chmod a+r /etc/apt/keyrings/docker.asc"
    log "DRY-RUN: write /etc/apt/sources.list.d/docker.sources with codename ${codename}"
    log "DRY-RUN: ${SUDO}DEBIAN_FRONTEND=noninteractive apt-get update -y"
    log "DRY-RUN: ${SUDO}DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"
  fi
}

install_dropbox() {
  if $skip_dropbox; then
    log "Skipping Dropbox install (--no-dropbox)."
    return
  fi

  log "Installing Dropbox..."
  local arch
  arch="$(uname -m 2>/dev/null || true)"
  if [[ "$arch" != "x86_64" ]]; then
    log "WARN: Dropbox daemon is 64-bit only; detected architecture: ${arch:-unknown}"
  fi
  if [[ -d "$HOME/.dropbox-dist" ]]; then
    log "Dropbox already installed at ~/.dropbox-dist"
    return
  fi

  if $apply; then
    cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
    log "Dropbox installed. Start with: ~/.dropbox-dist/dropboxd"
  else
    log "DRY-RUN: would install Dropbox to ~/.dropbox-dist"
  fi
}

setup_xdg_user_dirs() {
  log "Setting up XDG user directories as symlinks to ~/dropvault/..."
  local dropvault="$HOME/dropvault"

  if $apply; then
    mkdir -p "$dropvault"

    # Create symlinks for directories defined in user-dirs.dirs
    while IFS='=' read -r key value; do
      [[ "$key" =~ ^#.*$ || -z "$key" ]] && continue
      dir=$(eval echo "$value")
      [[ -z "$dir" || "$dir" == "$HOME" ]] && continue

      local dirname target
      dirname="$(basename "$dir")"
      target="${dropvault}/${dirname}"

      mkdir -p "$target"

      # Skip if already correctly linked
      if [[ -L "$dir" ]] && [[ "$(readlink -f "$dir")" == "$(readlink -f "$target")" ]]; then
        log "OK: $dir -> $target"
        continue
      fi

      # Backup existing
      [[ -e "$dir" || -L "$dir" ]] && backup_target "$dir"

      ln -s "$target" "$dir"
      log "Linked $dir -> $target"
    done < "$HOME/.config/user-dirs.dirs"

    command -v xdg-user-dirs-update >/dev/null && xdg-user-dirs-update
  else
    log "DRY-RUN: would create XDG user directories as symlinks to $dropvault/"
  fi
}

post_install_notes() {
  if command -v bash >/dev/null 2>&1; then
    local bash_path
    bash_path="$(command -v bash)"
    if [[ "${SHELL:-}" != "$bash_path" ]]; then
      log "Post-install: default shell is ${SHELL:-unknown}; dotfiles expect bash. Consider: chsh -s \"$bash_path\""
    fi
  fi

  if command -v systemctl >/dev/null 2>&1; then
    log "Post-install: enable desktop services if needed, e.g.:"
    log "  systemctl enable --now tlp"
    log "  systemctl --user enable --now pipewire pipewire-pulse wireplumber"
  fi

  if command -v docker >/dev/null 2>&1; then
    log "Post-install: Docker is installed. For non-root use:"
    log "  ${SUDO}usermod -aG docker \"$USER\""
    log "  newgrp docker"
    log "Post-install: Verify daemon:"
    log "  ${SUDO}systemctl status docker"
  fi
}

main() {
  log "Repo root: $repo_root"
  if $apply; then
    log "Mode: APPLY"
  else
    log "Mode: DRY-RUN (use --apply to make changes)"
  fi

  install_packages
  install_docker_engine

  DOTFILES=(
    "dots/bashrc:$HOME/.bashrc"
    "dots/tmux.conf:$HOME/.tmux.conf"
    "dots/ideavimrc:$HOME/.ideavimrc"
    "config/user-dirs.dirs:$HOME/.config/user-dirs.dirs"
    "config/user-dirs.conf:$HOME/.config/user-dirs.conf"
  )

  CONFIG_DIRS=(
    "config/sway:$HOME/.config/sway"
    "config/waybar:$HOME/.config/waybar"
    "config/nvim:$HOME/.config/nvim"
    "config/foot:$HOME/.config/foot"
  )

  if $skip_links; then
    log "Skipping link setup (--no-links)."
  else
    for pair in "${DOTFILES[@]}"; do
      IFS=":" read -r rel dest <<<"$pair"
      link_item "$rel" "$dest"
    done

    ensure_dir "$HOME/.config"

    for pair in "${CONFIG_DIRS[@]}"; do
      IFS=":" read -r rel dest <<<"$pair"
      link_item "$rel" "$dest"
    done

  fi

  install_dropbox
  if $skip_xdg; then
    log "Skipping XDG user dirs setup (--no-xdg)."
  else
    setup_xdg_user_dirs
  fi

  if $skip_validate; then
    log "Skipping validation output (--no-validate)."
  else
    log "Validation:"
    for pair in "${DOTFILES[@]}"; do
      IFS=":" read -r rel dest <<<"$pair"
      check_link "$rel" "$dest"
    done
    for pair in "${CONFIG_DIRS[@]}"; do
      IFS=":" read -r rel dest <<<"$pair"
      check_link "$rel" "$dest"
    done
  fi

  if $apply && [[ ${#BACKUPS[@]} -gt 0 ]]; then
    log "Backups created:"
    for b in "${BACKUPS[@]}"; do
      log "  $b"
    done
  elif $apply; then
    log "No backups created."
  fi

  log "Done."
  if $apply; then
    log "Remember to source ~/.bashrc or restart your shell."
    post_install_notes
  else
    log "Dry-run only; re-run with --apply to make changes."
  fi
}


main "$@"
