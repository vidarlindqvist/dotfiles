#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d%H%M%S)"

link() {
    local src="$1"
    local dest="$2"

    if [ -L "$dest" ]; then
        rm "$dest"
    elif [ -e "$dest" ]; then
        echo "Backing up existing $dest -> $dest.bak.$TIMESTAMP"
        mv "$dest" "$dest.bak.$TIMESTAMP"
    fi

    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
    echo "Linked $dest -> $src"
}

link "$REPO_DIR/nvim" "$HOME/.config/nvim"
link "$REPO_DIR/ghostty" "$HOME/.config/ghostty"
link "$REPO_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"
link "$REPO_DIR/rofi" "$HOME/.config/rofi"
link "$REPO_DIR/hypr" "$HOME/.config/hypr"
link "$REPO_DIR/gtk-3.0" "$HOME/.config/gtk-3.0"
link "$REPO_DIR/gtk-4.0" "$HOME/.config/gtk-4.0"
link "$REPO_DIR/dunst" "$HOME/.config/dunst"
link "$REPO_DIR/swappy" "$HOME/.config/swappy"
link "$REPO_DIR/gtk-theme-glass" "$HOME/.local/share/themes/Tokyonight-Dark-Glass"

echo "Done. Any pre-existing configs were backed up with a .bak.$TIMESTAMP suffix, not deleted."
