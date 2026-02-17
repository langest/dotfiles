#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'EOF'
Usage: theme.sh <command> [args]

Commands:
  list
  set <theme-name>
  current
  refresh
  install <git-repo-url>
  update
  remove <theme-name>
  sync
  btop
  foot
  nvim
  wofi
  wallpaper
  swaylock
  lock
EOF
}

cmd="${1:-}"
if [[ $# -gt 0 ]]; then
  shift
fi

case "$cmd" in
  list) "$script_dir/list.sh" "$@" ;;
  set) "$script_dir/set.sh" "$@" ;;
  current) "$script_dir/current.sh" "$@" ;;
  refresh) "$script_dir/refresh.sh" "$@" ;;
  install) "$script_dir/install.sh" "$@" ;;
  update) "$script_dir/update.sh" "$@" ;;
  remove) "$script_dir/remove.sh" "$@" ;;
  sync) "$script_dir/sync_builtin.sh" "$@" ;;
  btop) "$script_dir/setters/set_btop.sh" "$@" ;;
  foot) "$script_dir/setters/set_foot.sh" "$@" ;;
  nvim) "$script_dir/setters/set_nvim.sh" "$@" ;;
  wofi) "$script_dir/setters/set_wofi.sh" "$@" ;;
  wallpaper) "$script_dir/setters/set_wallpaper.sh" "$@" ;;
  swaylock) "$script_dir/setters/set_swaylock.sh" "$@" ;;
  lock) "$script_dir/lock.sh" "$@" ;;
  ""|-h|--help|help) usage ;;
  *)
    echo "Unknown command: $cmd" >&2
    usage
    exit 1
    ;;
esac
