// Verified against the official Quickshell lockscreen example:
// https://github.com/quickshell-mirror/quickshell-examples/tree/master/lockscreen
// Only change from the reference: configDirectory/config point at our
// own pam/hyprlock file (mirrors /etc/pam.d/hyprlock, already proven
// working on this system) instead of the example's generic
// pam_unix.so-only config.

import QtQuick
import Quickshell
import Quickshell.Services.Pam

Scope {
    id: root
    signal unlocked()
    signal failed()

    // Shared across all lock surfaces (one per monitor) so they stay
    // in sync.
    property string currentText: ""
    property bool unlockInProgress: false
    property bool showFailure: false

    onCurrentTextChanged: showFailure = false

    function tryUnlock() {
        if (currentText === "") return
        root.unlockInProgress = true
        pam.start()
    }

    PamContext {
        id: pam

        // configDirectory left at its default (/etc/pam.d) -- PAM
        // correctly refuses to trust a user-writable config directory
        // for authentication (confirmed via "Permission denied" when
        // pointed at a directory under this dotfiles repo). The actual
        // config file needs to be created at /etc/pam.d/quickshell-lock
        // by the user (requires root), matching /etc/pam.d/hyprlock's
        // content exactly.
        config: "quickshell-lock"

        onPamMessage: {
            if (this.responseRequired) {
                this.respond(root.currentText)
            }
        }

        onCompleted: result => {
            if (result === PamResult.Success) {
                root.unlocked()
            } else {
                root.currentText = ""
                root.showFailure = true
            }
            root.unlockInProgress = false
        }
    }
}
