// Structure (required "context" property, PAM wiring via
// root.context.currentText/tryUnlock/unlockInProgress/showFailure)
// verified against the official Quickshell lockscreen example:
// https://github.com/quickshell-mirror/quickshell-examples/tree/master/lockscreen
// Visuals are a full rebuild in Tokyonight colors matching hyprlock.conf
// (blurred wallpaper, same palette/font/sharp corners as the rest of
// the rice). Deliberately avoids QtQuick.Controls (Button/TextField) --
// their default "Basic" style rendered as an unstyled white box when
// used for the Quickshell notification tooltips earlier tonight, so
// this hand-rolls a plain TextInput + Rectangle instead.
//
// Per-monitor layout: "screen" is passed in explicitly from
// shell.qml/test.qml (bound to the enclosing WlSessionLockSurface's own
// .screen property, confirmed to exist via the real API docs). Password
// entry only renders on DP-6 (the main monitor); DP-5 (vertical) gets a
// completely different huge stacked-digit clock treatment instead.

import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland

Item {
    id: root
    required property LockContext context
    property var screen

    readonly property bool isMainScreen: !root.screen || root.screen.name === "DP-6"
    readonly property bool isVerticalScreen: root.screen && root.screen.name === "DP-5"

    // Shared ticking clock -- both the main-screen clock and the
    // vertical-screen one read from this instead of each keeping their
    // own timer.
    property var now: new Date()
    Timer {
        running: true
        repeat: true
        interval: 1000
        onTriggered: root.now = new Date()
    }

    // Background: same wallpaper hyprlock/hyprpaper use, blurred to
    // match hyprlock.conf's blur_passes = 3 look. Shown on every screen.
    Image {
        id: bgImage
        anchors.fill: parent
        source: "/home/vidar/dev/dotfiles/wallpaper/tokyonight_wallpaper.png"
        fillMode: Image.PreserveAspectCrop
        visible: false
    }

    MultiEffect {
        anchors.fill: bgImage
        source: bgImage
        blurEnabled: true
        blur: 0.6
        blurMax: 48
    }

    Rectangle {
        anchors.fill: parent
        color: "#1a1b26"
        opacity: 0.35
    }

    // --- Main screen (DP-6): password entry only. Clock/date live on the
    // vertical screen instead -- no need to duplicate them here. ---

    // Angled panel behind the login box -- a parallelogram (not a plain
    // rectangle), leaning the same way as the diagonal marks sketched on
    // the screenshot: the top edge sits further right than the bottom
    // edge. Same color/alpha as the pill widget's own card.
    Shape {
        id: bandShape
        visible: root.isMainScreen
        anchors.fill: parent
        asynchronous: true

        readonly property real bandWidth: parent.width * 0.45
        readonly property real skew: parent.height * 0.3
        readonly property real centerX: parent.width / 2

        ShapePath {
            strokeWidth: -1
            fillColor: "#bf16161e" // #16161e at alpha=0.75 (0xbf/255)

            startX: bandShape.centerX - bandShape.bandWidth / 2 + bandShape.skew / 2
            startY: 0
            PathLine { x: bandShape.centerX + bandShape.bandWidth / 2 + bandShape.skew / 2; y: 0 }
            PathLine { x: bandShape.centerX + bandShape.bandWidth / 2 - bandShape.skew / 2; y: bandShape.height }
            PathLine { x: bandShape.centerX - bandShape.bandWidth / 2 - bandShape.skew / 2; y: bandShape.height }
            PathLine { x: bandShape.centerX - bandShape.bandWidth / 2 + bandShape.skew / 2; y: 0 }
        }
    }

    Rectangle {
        id: inputField
        visible: root.isMainScreen
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
        width: 320
        height: 48
        radius: height / 2
        color: "#16161e"

        TextInput {
            id: passwordInput
            anchors.fill: parent
            anchors.margins: 12
            verticalAlignment: TextInput.AlignVCenter
            color: "#c0caf5"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 16
            echoMode: TextInput.Password
            focus: root.isMainScreen
            enabled: !root.context.unlockInProgress
            clip: true

            // Explicit rather than relying on the implicit
            // activeFocus-driven default -- activeFocus wasn't reliably
            // landing on this Item inside the lock surface, so the caret
            // never appeared even though typing worked.
            cursorVisible: true
            Component.onCompleted: forceActiveFocus()

            onTextChanged: root.context.currentText = text
            onAccepted: root.context.tryUnlock()

            Connections {
                target: root.context
                function onCurrentTextChanged() {
                    passwordInput.text = root.context.currentText
                }
            }
        }

        Text {
            anchors.fill: parent
            anchors.margins: 12
            verticalAlignment: Text.AlignVCenter
            visible: passwordInput.text === "" && !passwordInput.activeFocus
            color: "#565f89"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 16
            text: "Enter password..."
        }
    }

    Text {
        visible: root.isMainScreen && root.context.showFailure
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: inputField.bottom
            topMargin: 16
        }
        color: "#f7768e"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 13
        text: "Incorrect password"
    }

    // Power options -- same construction as the pill widget's icon row
    // (Nerd Font glyphs via String.fromCodePoint, verified codepoints,
    // fixed hit targets, hover label in reserved headroom above).
    // Codepoints verified against the nerd-fonts glyphnames.json registry:
    // nf-fa-power_off=U+F011 (already used on the pill), nf-md-restart=
    // U+F0709, nf-md-sleep=U+F04B2.
    Text {
        anchors {
            horizontalCenter: powerRow.horizontalCenter
            bottom: powerRow.top
            bottomMargin: 4
        }
        visible: root.isMainScreen && powerRow.hoverText !== ""
        color: "#c0caf5"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 11
        text: powerRow.hoverText
    }

    Rectangle {
        id: powerRow
        visible: root.isMainScreen
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: inputField.bottom
            topMargin: 32
        }
        width: powerIcons.implicitWidth + 32
        height: 56
        radius: height / 2
        color: "#16161e"

        readonly property string hoverText: sleepArea.containsMouse ? "Sleep"
            : restartArea.containsMouse ? "Restart"
            : shutdownArea.containsMouse ? "Shut down"
            : ""

        Row {
            id: powerIcons
            anchors.centerIn: parent

            Item {
                width: 44
                height: 44

                Text {
                    anchors.centerIn: parent
                    color: "#7aa2f7"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 22
                    text: String.fromCodePoint(0xf04b2)
                }

                MouseArea {
                    id: sleepArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: Quickshell.execDetached(["systemctl", "suspend"])
                }
            }

            Item {
                width: 44
                height: 44

                Text {
                    anchors.centerIn: parent
                    color: "#e0af68"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 22
                    text: String.fromCodePoint(0xf0709)
                }

                MouseArea {
                    id: restartArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: Quickshell.execDetached(["systemctl", "reboot"])
                }
            }

            Item {
                width: 44
                height: 44

                Text {
                    anchors.centerIn: parent
                    color: "#f7768e"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 22
                    text: String.fromCodePoint(0xf011)
                }

                MouseArea {
                    id: shutdownArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: Quickshell.execDetached(["systemctl", "poweroff"])
                }
            }
        }
    }

    // --- Vertical screen (DP-5): huge stacked hour/minute, small dimmed
    // date block underneath. No password entry here at all. ---

    Column {
        visible: root.isVerticalScreen
        anchors {
            left: parent.left
            top: parent.top
            leftMargin: 80
            topMargin: 60
        }
        spacing: 32

        // No horizontalCenter on these two -- Column left-aligns
        // children by default, which is exactly what makes "17:" and
        // "53" share the same left edge instead of each being
        // independently centered (that mismatch is what showed up in
        // the screenshot).
        Column {
            spacing: -80

            Text {
                color: "#c0caf5"
                font.family: "JetBrainsMono Nerd Font"
                font.bold: true
                font.pixelSize: 640
                // The default Qt renderer scales a glyph atlas, which
                // looks jagged at sizes this large. Native rendering
                // re-renders glyphs at actual size instead -- the same
                // fix the official Quickshell lockscreen example uses on
                // its own large clock label.
                renderType: Text.NativeRendering
                text: Qt.formatDateTime(root.now, "hh:")
            }

            Text {
                color: "#c0caf5"
                font.family: "JetBrainsMono Nerd Font"
                font.bold: true
                font.pixelSize: 640
                renderType: Text.NativeRendering
                text: Qt.formatDateTime(root.now, "mm")
            }
        }

        Text {
            color: "#565f89"
            font.family: "JetBrainsMono Nerd Font"
            font.bold: true
            font.pixelSize: 84
            renderType: Text.NativeRendering
            text: Qt.formatDateTime(root.now, "dddd, MMMM d").toUpperCase()
        }
    }
}
