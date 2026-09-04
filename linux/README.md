# Linux (Hyprland) translation of the macOS setup

Two macOS-only pieces from the main setup -- AeroSpace (tiling WM) and
Karabiner-Elements (key remapping) -- don't exist on Linux, so these are
hand-translated equivalents, not the same config running unmodified.

- `hypr/aerospace_keybinds.conf` -- `bind =` lines to fold into your
  `~/.config/hypr/hyprland.conf` (e.g. via `source = ~/dev/dotfiles/linux/hypr/aerospace_keybinds.conf`).
  Focus/move/workspace/floating map cleanly. Layout toggling and container
  joining don't have exact Hyprland equivalents (Hyprland's dwindle/master
  tiling model differs from AeroSpace's explicit tiles/accordion) -- see
  the comments in that file for the closest options.

- `xremap/config.yml` -- install [xremap](https://github.com/xremap/xremap)
  (has native Hyprland support) and point it at this file. Covers the
  grave/non_us_backslash key swap exactly (a pure keycode swap). The
  Option+hjkl brace shortcuts are approximate -- verify the exact target
  keys once you know which XKB layout you're running, since brace-producing
  combos differ by layout and this was written without access to your
  actual Linux keyboard.

Deliberately not ported: Karabiner's "right Option -> ctrl+cmd+alt" rule.
That only existed to build a modifier combo free of macOS shortcut
collisions -- Hyprland's `$mainMod` (Super, by convention) is already a
dedicated collision-free modifier, so there's nothing to remap.
