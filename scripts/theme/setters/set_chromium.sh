#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../lib/validate.sh"

theme_dir="$HOME/.config/omarchy/current/theme"
colors_file="$theme_dir/colors.toml"
chromium_theme_file="$theme_dir/chromium.theme"
policy_dir="/etc/chromium/policies/managed"
policy_file="$policy_dir/color.json"

if [[ -f "$chromium_theme_file" ]]; then
  theme_rgb="$(tr -d '[:space:]' <"$chromium_theme_file")"
  if ! is_rgb_triplet "$theme_rgb"; then
    echo "Chromium theme skipped: invalid generated RGB value in $chromium_theme_file" >&2
    exit 0
  fi
elif [[ -f "$colors_file" ]]; then
  # Fallback for older generated themes missing chromium.theme.
  if accent_hex="$(get_color_from_toml "$colors_file" accent 2>/dev/null)"; then
    theme_rgb="$(hex_to_rgb "$accent_hex")"
  else
    theme_rgb="28,32,39"
  fi
else
  theme_rgb="28,32,39"
fi

theme_hex="$(rgb_to_hex "$theme_rgb")"
policy_json="{\"BrowserThemeColor\":\"$theme_hex\"}"

if mkdir -p "$policy_dir" 2>/dev/null && [[ -w "$policy_dir" ]]; then
  printf '%s\n' "$policy_json" >"$policy_file"
else
  echo "Chromium theme skipped: need write access to $policy_dir"
  exit 0
fi

if ! chromium --refresh-platform-policy --no-startup-window >/dev/null 2>&1; then
  echo "Chromium policy refresh skipped: command failed" >&2
fi

echo "Chromium theme color set: $theme_hex"
