# dotfiles

Neovim, Ghostty, and tmux config, kept in sync across machines via symlinks.

## Setup on a new machine

```bash
git clone https://github.com/vidarlindqvist/dotfiles.git ~/dev/dotfiles
~/dev/dotfiles/install.sh
```

The install script symlinks:

- `nvim/` → `~/.config/nvim`
- `ghostty/` → `~/.config/ghostty`
- `tmux/tmux.conf` → `~/.tmux.conf`

Anything already at those paths gets backed up with a `.bak.<timestamp>` suffix, not deleted.

## Keeping it in sync

Because these are symlinks, editing the live config (e.g. `~/.config/nvim/lua/...`) edits
the file inside this repo directly. Commit and push from `~/dev/dotfiles` as usual, then
`git pull` on any other machine to pick up changes.

Requires [Ghostty](https://ghostty.org), [Neovim](https://neovim.io) (0.11+), and
[tmux](https://github.com/tmux/tmux) to already be installed -- this repo is just config,
not the tools themselves.
