# dotfiles

Neovim, Ghostty, tmux, rofi, and Hyprland (+ hyprpaper) config, kept in sync across machines via symlinks.

## Setup on a new machine

```bash
git clone https://github.com/vidarlindqvist/dotfiles.git ~/dev/dotfiles
~/dev/dotfiles/install.sh
```

The install script symlinks:

- `nvim/` → `~/.config/nvim`
- `ghostty/` → `~/.config/ghostty`
- `tmux/tmux.conf` → `~/.tmux.conf`
- `rofi/` → `~/.config/rofi`
- `hypr/` → `~/.config/hypr` (Hyprland config + hyprpaper wallpaper config)

Anything already at those paths gets backed up with a `.bak.<timestamp>` suffix, not deleted.

## Keeping it in sync

Because these are symlinks, editing the live config (e.g. `~/.config/nvim/lua/...`) edits
the file inside this repo directly. Commit and push from `~/dev/dotfiles` as usual, then
`git pull` on any other machine to pick up changes.

Requires [Ghostty](https://ghostty.org), [Neovim](https://neovim.io) (0.11+),
[tmux](https://github.com/tmux/tmux), [rofi](https://github.com/davatorium/rofi), and
[Hyprland](https://hyprland.org) (+ hyprpaper) to already be installed -- this repo is
just config, not the tools themselves.
