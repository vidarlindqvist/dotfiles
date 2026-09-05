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
link "$REPO_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
link "$REPO_DIR/zsh/zshrc" "$HOME/.zshrc"
link "$REPO_DIR/quickshell" "$HOME/.config/quickshell"

# Zen Browser's profile folder name is randomly generated per-install, so
# this path will need updating if the profile is ever recreated. Current
# profile confirmed via: ls ~/.config/zen/
ZEN_PROFILE="$HOME/.config/zen/sizs8jqv.Default (release)"
if [ -d "$ZEN_PROFILE" ]; then
    link "$REPO_DIR/zen/user.js" "$ZEN_PROFILE/user.js"
    link "$REPO_DIR/zen/chrome/userChrome.css" "$ZEN_PROFILE/chrome/userChrome.css"
else
    echo "Skipping Zen theme: profile dir not found at $ZEN_PROFILE (update install.sh with the current profile name)"
fi

echo "Done. Any pre-existing configs were backed up with a .bak.$TIMESTAMP suffix, not deleted."
