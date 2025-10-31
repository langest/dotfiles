# Cheat Sheet for various tools
## ctags
* `ctags -R --exclude=vendor`
* `ctags -R --languages=PHP --exclude=vendor`
* `ctags -R --exclude={vendor,node_modules,storage}`
* `ctags -R --languages=PHP,JavaScript,Python`

## Vim ctags
* `Ctrl-]`     - Overridden for gCtrl-], default: Jump to definition under cursor
* `Ctrl-t`     - Jump back from definition
* `g]`         - List all definitions when multiple matches exist
* `gCtrl-]`    - Jump to definition if only one match exists else list all matches
* `:tn`        - Go to next tag match
* `:tp`        - Go to previous tag match
* `:ts`        - List matching tags and select one
* `:tag xyz`   - Jump to xyz definition
* `<Leader>]`  - Open CtrlP tag search (from your config)

* `Ctrl-W }`     - Preview tag under cursor
* `Ctrl-W z`     - Close the preview window
* `:ptag xyz`    - Preview tag 'xyz'
* `:pclose`      - Close preview window (same as Ctrl-W z)

## tmux
* `<prefix>`        - C-s (replaces default C-b)
* `<prefix> C-r`    - Reload tmux configuration
* `<prefix> v`      - Split window horizontally
* `<prefix> s`      - Split window vertically
* `<prefix> h/j/k/l`- Navigate between panes (left/down/up/right)
* `C-h/j/k/l`       - Resize current pane (left/down/up/right) by 1 unit
* `<prefix> c`      - Create new tab
* `<prefix> n`      - Next tab
* `<prefix> p`      - Previous tab
* `<prefix> <number>` - Switch to tab by number
* `<prefix> ,`      - Rename current tab
* `<prefix> &`      - Close current tab
* `vi`              - Mode keys set to vi controls

## i3
* `$mod+v`          - Split vertically (new windows appear below)
* `$mod+h`          - Split horizontally (new windows appear right)
* `$mod+w`          - Change to tabbed layout
* `$mod+s`          - Change to stacked layout
* `$mod+Tab`        - Next tab
* `$mod+Shift+Tab`  - Previous tab

