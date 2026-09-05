// Safe test harness -- renders the exact same LockSurface + LockContext
// (including real PAM auth) inside a normal closable window instead of
// an actual Wayland session lock. Run with:
//   quickshell -p ~/dev/dotfiles/quickshell-lock/test.qml
// Verified against the official Quickshell lockscreen example's own
// test.qml: https://github.com/quickshell-mirror/quickshell-examples/tree/master/lockscreen

import QtQuick
import Quickshell

ShellRoot {
    LockContext {
        id: lockContext
        onUnlocked: Qt.quit()
    }

    FloatingWindow {
        id: testWindow

        LockSurface {
            anchors.fill: parent
            context: lockContext
            screen: testWindow.screen
        }
    }

    Connections {
        target: Quickshell
        function onLastWindowClosed() {
            Qt.quit()
        }
    }
}
