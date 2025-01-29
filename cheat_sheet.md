# Cheat Sheet for various tools
## ctags
* `ctags -R --exclude=vendor`
* `ctags -R --languages=PHP --exclude=vendor`
* `ctags -R --exclude={vendor,node_modules,storage}`
* `ctags -R --languages=PHP,JavaScript,Python`

## Vim ctags
* `Ctrl-]`     - Overridden for gCtrl-]

* `Ctrl-]`     - Jump to definition under cursor
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
