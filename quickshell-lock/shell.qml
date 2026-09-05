// The real lock -- uses the actual Wayland session-lock protocol.
// NOT wired into hypridle.conf/hyprland.lua yet; only invoke manually
// once test.qml has confirmed the UI and PAM flow both work correctly.
// Run with:
//   quickshell -p ~/dev/dotfiles/quickshell-lock/shell.qml
// Verified against the official Quickshell lockscreen example:
// https://github.com/quickshell-mirror/quickshell-examples/tree/master/lockscreen

import Quickshell
import Quickshell.Wayland

ShellRoot {
    LockContext {
        id: lockContext

        onUnlocked: {
            // Unlock before exiting, or the compositor shows a fallback
            // lock you can't interact with.
            lock.locked = false
            Qt.quit()
        }
    }

    WlSessionLock {
        id: lock
        locked: true

        WlSessionLockSurface {
            LockSurface {
                anchors.fill: parent
                context: lockContext
            }
        }
    }
}
