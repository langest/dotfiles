#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: install.sh [--apply] [--no-packages] [--help]

By default runs in dry-run mode (no changes). Use --apply to perform actions.

Options:
  --apply         Execute changes (packages + links). Without it, dry-run.
  --no-packages   Skip apt-get update/install steps.
  --help, -h      Show this help.
EOF
}

apply=false
skip_packages=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply) apply=true ;;
    --no-packages) skip_packages=true ;;
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
    echo "This script needs root privileges for package installs; sudo not found." >&2
    exit 1
  fi
fi

PACKAGES=(
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

setup_xdg_user_dirs() {
  log "Setting up XDG user directories..."
  if $apply; then
    # Create the directories defined in user-dirs.dirs
    if [[ -f "$HOME/.config/user-dirs.dirs" ]]; then
      while IFS='=' read -r key value; do
        # Skip comments and empty lines
        [[ "$key" =~ ^#.*$ || -z "$key" ]] && continue
        # Expand $HOME in the value and remove quotes
        dir=$(eval echo "$value")
        if [[ -n "$dir" && "$dir" != "$HOME" ]]; then
          mkdir -p "$dir"
          log "Created directory: $dir"
        fi
      done < "$HOME/.config/user-dirs.dirs"
    fi
    # Run xdg-user-dirs-update to register them with the system
    if command -v xdg-user-dirs-update >/dev/null 2>&1; then
      xdg-user-dirs-update
      log "Ran xdg-user-dirs-update"
    fi
  else
    log "DRY-RUN: would create XDG user directories and run xdg-user-dirs-update"
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
}

main() {
  log "Repo root: $repo_root"
  if $apply; then
    log "Mode: APPLY"
  else
    log "Mode: DRY-RUN (use --apply to make changes)"
  fi

  install_packages

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

  for pair in "${DOTFILES[@]}"; do
    IFS=":" read -r rel dest <<<"$pair"
    link_item "$rel" "$dest"
  done

  ensure_dir "$HOME/.config"

  for pair in "${CONFIG_DIRS[@]}"; do
    IFS=":" read -r rel dest <<<"$pair"
    link_item "$rel" "$dest"
  done

  setup_xdg_user_dirs

  log "Validation:"
  for pair in "${DOTFILES[@]}"; do
    IFS=":" read -r rel dest <<<"$pair"
    check_link "$rel" "$dest"
  done
  for pair in "${CONFIG_DIRS[@]}"; do
    IFS=":" read -r rel dest <<<"$pair"
    check_link "$rel" "$dest"
  done

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
