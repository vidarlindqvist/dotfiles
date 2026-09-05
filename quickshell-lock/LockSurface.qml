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

import QtQuick
import QtQuick.Effects
import Quickshell.Wayland

Item {
    id: root
    required property LockContext context

    // Background: same wallpaper hyprlock/hyprpaper use, blurred to
    // match hyprlock.conf's blur_passes = 3 look.
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

    Text {
        id: clock
        property var date: new Date()

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: 120
        }

        color: "#c0caf5"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 90

        Timer {
            running: true
            repeat: true
            interval: 1000
            onTriggered: clock.date = new Date()
        }

        text: {
            const h = clock.date.getHours().toString().padStart(2, '0')
            const m = clock.date.getMinutes().toString().padStart(2, '0')
            return `${h}:${m}`
        }
    }

    Text {
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: clock.bottom
            topMargin: 8
        }
        color: "#565f89"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 20
        text: Qt.formatDateTime(new Date(), "dddd, d MMMM yyyy")
    }

    Rectangle {
        id: inputField
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
        width: 320
        height: 48
        radius: 0
        color: "#16161e"
        border.width: 2
        border.color: root.context.showFailure ? "#f7768e"
            : passwordInput.activeFocus ? "#7aa2f7"
            : "#414868"

        TextInput {
            id: passwordInput
            anchors.fill: parent
            anchors.margins: 12
            verticalAlignment: TextInput.AlignVCenter
            color: "#c0caf5"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 16
            echoMode: TextInput.Password
            focus: true
            enabled: !root.context.unlockInProgress
            clip: true

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
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: inputField.bottom
            topMargin: 16
        }
        visible: root.context.showFailure
        color: "#f7768e"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 13
        text: "Incorrect password"
    }
}
