# Keybind reference

Find this file: `ff` in any terminal (fuzzy-find under `$HOME`, opens in nvim),
or `<leader>ff` / `<leader>fg` from inside nvim if your cwd is `~/.config/nvim`.

Regenerate/update this by asking Claude to re-audit the actual config files --
this is a snapshot, not a live source of truth.

---

## macOS System Level

| Key | Does |
|---|---|
| Caps Lock | Escape (via `hidutil`, survives reboot) |

## Karabiner-Elements

| Key | Does |
|---|---|
| Left Option + `h`/`j`/`k`/`l` | `{` `}` `[` `]` (Swedish-Pro layout) |
| Right Option (any) | becomes `ctrl+cmd+alt` -- feeds AeroSpace |
| Top-left key (Option-adjacent) | `paragraph sign` / `degree sign` |
| Key next to Left Shift | `<` / `>` |

## AeroSpace (window manager)

All bindings use `ctrl-cmd-alt` (i.e. **right Option**) as the modifier --
left Option is reserved for typing/brackets above.

| Key | Does |
|---|---|
| `+h/j/k/l` | focus left/down/up/right |
| `+shift+h/j/k/l` | move window left/down/up/right |
| `+shift+h/j/k/l` *(mode: service)* | join-with (split direction) |
| `+1`-`9`, `+a`-`z` (minus a few) | switch to workspace N |
| `+shift+`(same) | move window to workspace N |
| `+tab` | back-and-forth last workspace |
| `+shift+tab` | move workspace to next monitor |
| `+slash` / `+comma` | tile layout / accordion layout |
| `+minus` / `+equal` | resize smart -50 / +50 |
| `+shift+semicolon` | enter "service" mode |

## Ghostty

No custom keybinds -- uses macOS-native window/tab shortcuts (Cmd+T, Cmd+W,
etc.) untouched.

## zsh

| Key | Does |
|---|---|
| `Ctrl-T` | fzf: find file below cwd |
| `Ctrl-R` | fzf: search shell history |
| `Alt-C` | fzf: cd into subdirectory (likely dead -- Option is claimed by Karabiner) |
| `Ctrl-G` | fzf: find ANY directory under `$HOME`, cd there |
| `Tab` | accept autosuggestion if shown, else `**`-trigger fzf-completion, else normal completion |

| Command | Does |
|---|---|
| `ff [dir]` | fuzzy-find a file under `$HOME` (or `dir`), open in nvim |
| `fcd [dir]` | fuzzy-find a directory, cd there |
| `y` | yazi file manager, cd's to wherever you exit it |

## tmux

Prefix: **Ctrl-a**

| Key | Does |
|---|---|
| `prefix` `c` | new window |
| `prefix` `,` | rename window |
| `prefix` `1`-`9` | jump to window N |
| `prefix` `d` | detach |
| `prefix` `[` | enter copy-mode |
| `Ctrl-a` `Ctrl-a` | send literal Ctrl-a through (shell line-start) |

**Inside copy-mode** (vi-style):

| Key | Does |
|---|---|
| `h/j/k/l`, `w/b/e`, `Ctrl-d`/`Ctrl-u`, `g`/`G`, `/`, `{`/`}` | navigate -- matches vim |
| `v` | begin selection (char-wise) |
| `V` | begin selection (line-wise) |
| `Ctrl-v` | begin selection (block-wise) |
| `y` or `Enter` | copy selection -> real macOS clipboard |
| `q` / `Esc` | cancel |

---

## Neovim

`mapleader` = **Space** -- `maplocalleader` = **`\`** (never set, so it's the
default -- deliberately kept separate from Space)

### General

| Key | Does |
|---|---|
| `<leader>cd` | file explorer (netrw) |

### Telescope

| Key | Does |
|---|---|
| `<leader>ff` | find files |
| `<leader>fg` | live grep |
| `<leader>fb` | list buffers |
| `<leader>fh` | help tags |

### Harpoon

| Key | Does |
|---|---|
| `<leader>a` | pin current file |
| `<C-e>` | open harpoon menu |
| `<leader>1`-`4` | jump to pinned file N |
| `<leader>hp` / `<leader>hn` | previous / next pinned file |

### LSP (basedpyright, ruff, texlab, matlab_ls)

| Key | Does |
|---|---|
| `gd` / `gD` | go to definition / declaration |
| `go` | go to type definition |
| `gl` | show full diagnostic (float) |
| `<leader>lf` | format buffer |
| `K` *(0.11 default)* | hover |
| `grn` *(0.11 default)* | rename |
| `gra` *(0.11 default)* | code action -- e.g. "Organize imports" |
| `grr` *(0.11 default)* | references |
| `gri` *(0.11 default)* | implementations |
| `]d` / `[d` *(0.11 default)* | next / previous diagnostic |

### Completion (nvim-cmp) -- insert mode

| Key | Does |
|---|---|
| `Ctrl-Space` | force-trigger completion |
| `Ctrl-e` | abort completion |
| `Ctrl-b` / `Ctrl-f` | scroll docs popup |
| `Enter` | confirm ONLY if an item is explicitly selected |
| `Tab` | jump to next snippet placeholder (else literal Tab) |
| `Shift-Tab` | jump to previous snippet placeholder |

### LaTeX (vimtex -- its own defaults, under `\`)

| Key | Does |
|---|---|
| `\ll` | compile (continuous mode) |
| `\lv` | view/sync in Skim |
| `za` / `zR` / `zM` | toggle / open-all / close-all folds |

### Redo/undo (built-in, unmapped by you, worth having in this list)

| Key | Does |
|---|---|
| `u` | undo |
| `Ctrl-r` | redo |
