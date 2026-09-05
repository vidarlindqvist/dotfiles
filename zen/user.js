// Required for userChrome.css/userContent.css to load at all. Zen may
// already default this to true (it's built around chrome customization),
// but setting it explicitly here is a harmless no-op either way.
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// Square off the outer window corners (GTK client-side decoration draws
// these below the userChrome.css layer, so CSS alone can't reach them)
user_pref("widget.gtk.rounded-bottom-corners.enabled", false);

// Zen's own dedicated pref for chrome corner rounding, confirmed by a Zen
// maintainer: https://github.com/zen-browser/desktop/issues/2512
user_pref("zen.theme.border-radius", 0);

// Fixes the window not visually filling its allocated screen space (a gap
// around the edges) on fractional Hyprland monitor scales like 1.5 -- a
// documented Firefox/GTK3 Wayland bug, not a Hyprland or CSS issue:
// https://github.com/zen-browser/desktop/issues/13495
// https://github.com/zen-browser/desktop/issues/6856
user_pref("widget.wayland.fractional-scale.enabled", false);
