#!/bin/bash
# Avoid starting a second lock instance. This has to be a script file,
# not an inline `sh -c "pgrep ... || quickshell ..."` string -- pgrep -f
# matches against full command lines, and an inline string's own
# invoking shell process literally contains the launch command as text
# in its own argv, so it always matched itself and never actually
# launched quickshell. A script file's own process just shows as
# "bash /path/to/lock.sh", which doesn't contain that text.
if pgrep -f "quickshell -p .*quickshell-lock/shell.qml" > /dev/null; then
    exit 0
fi

# Flag file the always-running main shell (quickshell/shell.qml) watches
# via FileView to hide the corner clock pill while actually locked --
# it should only show once logged in, not float on top of the lock
# screen. Cleared back to "unlocked" by shell.qml's onUnlocked handler.
echo -n "locked" > "$XDG_RUNTIME_DIR/quickshell-lock-state"

exec quickshell -p /home/vidar/dev/dotfiles/quickshell-lock/shell.qml
