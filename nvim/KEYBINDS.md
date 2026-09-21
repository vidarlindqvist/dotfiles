# Keybind reference

Find this file: `ff` in any terminal (fuzzy-find under `$HOME`, opens in nvim),
or `<leader>ff` / `<leader>fg` from inside nvim if your cwd is `~/.config/nvim`.

Regenerate/update this by asking Claude to re-audit the actual config files --
this is a snapshot, not a live source of truth.

Everything under "This machine" was read straight out of the configs in this
repo. The macOS section at the bottom is kept for the other machine, but those
configs do **not** live here, so it is unverified.

---

# This machine (Arch + Hyprland)

## Hyprland

Modifier is **SUPER** (the Windows key), written `SUPER` below.

| Key | Does |
|---|---|
| `SUPER+Return` | new terminal (ghostty) |
| `SUPER+F` | file manager (thunar, glass GTK theme) |
| `ALT+Space` | app launcher (`rofi -show drun`) -- Spotlight-style |
| `SUPER+C` / `SUPER+W` | close window (both bound) |
| `SUPER+V` | toggle floating |
| `SUPER+P` | pseudotile |
| `SUPER+J` | toggle split direction (dwindle) |
| `SUPER+SHIFT+Backspace` | quit Hyprland entirely, back to tty1 |

### Focus and movement

| Key | Does |
|---|---|
| `SUPER+h/j/k/l` | focus left/down/up/right |
| `SUPER+1`-`0` | go to workspace 1-10 (`0` is 10) |
| `SUPER+SHIFT+1`-`0` | move window to workspace |
| `SUPER+S` | toggle special workspace ("magic" scratchpad) |
| `SUPER+O` | focus next monitor |
| `SUPER+SHIFT+O` | move window to next monitor, and follow it |
| `SUPER+scroll` | previous / next workspace |
| `SUPER+LMB` drag | move window |
| `SUPER+RMB` drag | resize window |

There is deliberately **no** `SUPER+SHIFT+H/J/K/L` to move a window
directionally -- only workspace/monitor moves are bound.

### Screenshots

Saved to `~/Pictures/Screenshots`.

| Key | Does |
|---|---|
| `Print` | whole screen -- saves to file *and* copies to clipboard |
| `SHIFT+Print` | drag a region, then annotate/crop in swappy |
| `SUPER+SHIFT+S` | same as above (Windows-style muscle memory) |

### Media keys

Volume, mic mute, brightness and play/pause/next/prev are bound to the usual
`XF86*` keys, and keep working while the screen is locked. Volume-up allows
PipeWire over-amplification to 150%.

### Not bound (worth knowing)

- **No lock keybind.** Commented out -- home desktop. Note `SUPER+L` is
  *focus right*, not lock; Hyprland can't tell `L` from `l` without an extra
  modifier, so a lock bind would need `SUPER+SHIFT+L`.
- `SUPER+Q` (terminal) and `SUPER+R` (menu) are commented out -- `SUPER+Return`
  and `ALT+Space` replaced them.

## Ghostty

No custom keybinds -- config sets theme/font/shaders only.

## zsh

| Key | Does |
|---|---|
| `Ctrl+Space` | accept the autosuggestion (ghost text from history) |
| `Right arrow` / `End` | accept the autosuggestion (zsh-autosuggestions defaults) |
| `Tab` | completion menu -- arrow keys to pick, case-insensitive, `ls`-coloured |
| `Ctrl+R` | zsh's own incremental history search (**not** fzf, see below) |

> **fzf is installed but not wired to any keys.** `key-bindings.zsh` is never
> sourced, so `Ctrl-T`, `Alt-C` and fzf's `Ctrl-R` are **not** active -- those
> keys still do their stock zsh jobs (`transpose-chars`, `capitalize-word`,
> plain history search). fzf is only reached through the two functions below.
> Source `/usr/share/fzf/key-bindings.zsh` in `zsh/zshrc` if you want them.

| Command | Does |
|---|---|
| `ff [dir]` | fuzzy-find a file under `$HOME` (or `dir`), open in nvim |
| `fcd [dir]` | fuzzy-find a directory under `$HOME` (or `dir`), cd there |
| `shutdown` | aliased to `systemctl poweroff` (interactive shells only) |
| `of` | source the OpenFOAM v2606 environment |

## tmux

Prefix: **Ctrl-a**. Windows and panes are numbered from **1**, and renumber
themselves when one closes. Mouse is on.

| Key | Does |
|---|---|
| `prefix` `c` | new window |
| `prefix` `,` | rename window |
| `prefix` `1`-`9` | jump to window N |
| `prefix` `%` / `"` | split pane vertical / horizontal |
| `prefix` `h/j/k/l` | move between panes (repeatable -- hold prefix once) |
| `prefix` `d` | detach |
| `prefix` `[` | enter copy-mode |
| `Ctrl-a` `Ctrl-a` | send a literal Ctrl-a through (shell line-start) |

**Inside copy-mode** (vi keys):

| Key | Does |
|---|---|
| `h/j/k/l`, `w/b/e`, `Ctrl-d`/`Ctrl-u`, `g`/`G`, `/`, `{`/`}` | navigate -- matches vim |
| `v` | begin selection (char-wise) -- remapped to match vim |
| `V` | begin selection (line-wise) |
| `Ctrl-v` | begin selection (block-wise) |
| `y` or `Enter` | copy to the **system** clipboard (`wl-copy` here, `pbcopy` on macOS) |
| mouse drag | same -- also copies to the system clipboard |
| `q` / `Esc` | cancel |

---

# Neovim

`mapleader` = **Space** -- `maplocalleader` = **`\`** (never set, so it's the
default -- deliberately kept separate from Space)

### General

| Key | Does |
|---|---|
| `<leader>cd` | file explorer (netrw) |
| `Ctrl-d` / `Ctrl-u` | half-page down/up, **cursor recentred** (normal + visual) |

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

### LSP (basedpyright, ruff, texlab, lua_ls, tinymist, matlab_ls)

These attach to **every** language above, Typst included.

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

`matlab_ls` only loads if `/Applications/MATLAB_R2025b.app` exists, so on this
machine it never attaches.

### Completion (nvim-cmp) -- insert mode

| Key | Does |
|---|---|
| `Ctrl-Space` | force-trigger completion |
| `Ctrl-e` | abort completion |
| `Ctrl-b` / `Ctrl-f` | scroll docs popup |
| `Enter` | confirm ONLY if an item is explicitly selected |
| `Tab` | jump to next snippet placeholder (else literal Tab) |
| `Shift-Tab` | jump to previous snippet placeholder |

### Typst (tinymist + typst-preview)

**There are no custom Typst keybinds.** Nothing in `plugins/typst.lua` maps a
key, and `tinymist` is configured as a plain LSP -- so Typst editing uses the
LSP table above (`gd`, `K`, `grn`, `gra`, `<leader>lf`, `]d`/`[d`) exactly like
Python or LaTeX. The preview is driven by commands instead:

| Command | Does |
|---|---|
| `:TypstPreview` | start the live preview (opens a browser tab) |
| `:TypstPreviewToggle` | start it, or stop it if already running |
| `:TypstPreviewStop` | stop the preview server |
| `:TypstPreviewSyncCursor` | jump the preview to the cursor, once |
| `:TypstPreviewFollowCursorToggle` | turn continuous cursor-following on/off |
| `:TypstPreviewFollowCursor` / `...NoFollowCursor` | force it on / off |
| `:TypstPreviewUpdate` | re-download the preview server binaries |

Cursor-following is **on by default**, so the preview already scrolls with you
after `:TypstPreview` -- the `FollowCursor` commands are only for turning it off.

This is the one place the Typst setup is thinner than LaTeX, which has `\ll`
and `\lv` from vimtex. If it starts to grate, a `ft=typst` mapping for
`:TypstPreviewToggle` is the obvious thing to add.

**Spellcheck is on automatically in `.typ` files**, checking English and
Swedish together (a word is only flagged if it matches neither). That makes the
built-in spell keys worth knowing here:

| Key | Does |
|---|---|
| `]s` / `[s` | next / previous misspelling |
| `z=` | suggest corrections |
| `zg` / `zw` | add word to dictionary / mark it wrong |

### LaTeX (vimtex -- its own defaults, under `\`)

| Key | Does |
|---|---|
| `\ll` | compile (continuous latexmk -- after the first run, saving recompiles) |
| `\lv` | view/sync in the PDF viewer (**Zathura** here, Skim on macOS) |
| `za` / `zR` / `zM` | toggle / open-all / close-all folds |

Math snippets (Gilles Castel's set) expand **automatically** in math mode as
soon as the trigger is typed -- no Tab or Enter. `Tab`/`Shift-Tab` then jump
between the placeholders.

### Redo/undo (built-in, unmapped by you, worth having in this list)

| Key | Does |
|---|---|
| `u` | undo |
| `Ctrl-r` | redo |

---

# macOS machine (unverified)

These configs are **not** in this repo -- Karabiner and AeroSpace live on the
Mac itself, and `linux/` here only holds hand-written translations of them that
are not symlinked by `install.sh`. Treat the following as last-known-good.

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
