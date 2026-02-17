#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${1:-}" ]]; then
  echo "Usage: $(basename "$0") <git-repo-url>"
  exit 1
fi

repo_url="$1"
themes_dir="$HOME/.config/omarchy/themes"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

theme_name="$(basename "$repo_url" .git | sed -E 's/^omarchy-//; s/-theme$//')"
theme_path="$themes_dir/$theme_name"

mkdir -p "$themes_dir"
rm -rf "$theme_path"

git clone --depth 1 "$repo_url" "$theme_path"
"$script_dir/set.sh" "$theme_name"
