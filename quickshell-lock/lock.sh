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
exec quickshell -p /home/vidar/dev/dotfiles/quickshell-lock/shell.qml
