#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../lib/validate.sh"

theme_dir="$HOME/.config/omarchy/current/theme"
colors_file="$theme_dir/colors.toml"

if [[ ! -f "$colors_file" ]]; then
  exit 0
fi

if ! accent="$(get_color_from_toml "$colors_file" accent 2>/dev/null)"; then
  accent="#1c2027"
fi
if ! background="$(get_color_from_toml "$colors_file" background 2>/dev/null)"; then
  background="#111418"
fi
if ! foreground="$(get_color_from_toml "$colors_file" foreground 2>/dev/null)"; then
  foreground="#d9dde2"
fi

found_profile=false
firefox_running=false
if pgrep -x firefox >/dev/null 2>&1; then
  firefox_running=true
fi

for profile in "$HOME"/.mozilla/firefox/*.default* "$HOME"/.mozilla/firefox/*.dev-edition-default; do
  [[ -d "$profile" ]] || continue
  found_profile=true

  chrome_dir="$profile/chrome"
  theme_css="$chrome_dir/omarchy-theme.css"
  user_chrome="$chrome_dir/userChrome.css"
  user_js="$profile/user.js"

  mkdir -p "$chrome_dir"

  cat >"$theme_css" <<EOF
:root {
  --omarchy-accent: $accent;
  --omarchy-background: $background;
  --omarchy-foreground: $foreground;
  --toolbar-bgcolor: var(--omarchy-background) !important;
  --toolbar-color: var(--omarchy-foreground) !important;
  --lwt-accent-color: var(--omarchy-background) !important;
  --lwt-text-color: var(--omarchy-foreground) !important;
  --sidebar-background-color: var(--omarchy-background) !important;
  --sidebar-text-color: var(--omarchy-foreground) !important;
  --tab-selected-bgcolor: var(--omarchy-accent) !important;
  --tab-selected-textcolor: var(--omarchy-foreground) !important;
}

#navigator-toolbox,
#TabsToolbar,
#nav-bar,
#PersonalToolbar {
  background: var(--omarchy-background) !important;
  color: var(--omarchy-foreground) !important;
}

#sidebar-box,
#sidebar,
#sidebar-header,
#sidebar-main,
#tabbrowser-tabs[orient="vertical"],
#tabbrowser-tabs[orient="vertical"] .tabbrowser-tab {
  background: var(--omarchy-background) !important;
  color: var(--omarchy-foreground) !important;
}

.tab-background[selected="true"],
#tabbrowser-tabs[orient="vertical"] .tabbrowser-tab[selected="true"] .tab-background {
  background: var(--omarchy-accent) !important;
}

#tabbrowser-tabs[orient="vertical"] .tabbrowser-tab:hover .tab-background {
  background: color-mix(in srgb, var(--omarchy-accent) 35%, var(--omarchy-background)) !important;
}
EOF

  if [[ ! -f "$user_chrome" ]]; then
    printf '@import "omarchy-theme.css";\n' >"$user_chrome"
  elif ! grep -q 'omarchy-theme.css' "$user_chrome"; then
    tmp_file="$(mktemp)"
    {
      printf '@import "omarchy-theme.css";\n'
      cat "$user_chrome"
    } >"$tmp_file"
    mv "$tmp_file" "$user_chrome"
  fi

  if [[ -f "$user_js" ]] && grep -q 'toolkit\.legacyUserProfileCustomizations\.stylesheets' "$user_js"; then
    sed -i 's/user_pref("toolkit\.legacyUserProfileCustomizations\.stylesheets".*/user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);/' "$user_js"
  else
    printf 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);\n' >>"$user_js"
  fi
done

if ! $found_profile; then
  echo "Firefox theme skipped: no profile found in ~/.mozilla/firefox"
  exit 0
fi

echo "Firefox theme updated"
if $firefox_running; then
  echo "Firefox is running: restart Firefox to fully apply chrome CSS changes"
fi
