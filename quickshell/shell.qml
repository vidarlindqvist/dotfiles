// Dynamic-Island-style widget: the pill grows *horizontally to the
// left* into a longer capsule of icons when clicked (anchored to the
// right edge, so growing width extends leftward automatically).
// Shutdown and logout are both directly on the main pill -- no confirm
// step, no extra UI.
//
// Hover labels render in permanently-reserved transparent headroom
// above the dark card (not inside it), and never resize the window --
// the window's own height is fixed, so hovering never triggers a resize.
//
// Each icon is a fixed 32x32 hit target (not a tight text-bounds
// MouseArea) placed edge-to-edge with no gap, so the cursor is always
// inside exactly one hitbox -- a small gap between tight hitboxes was
// causing rapid enter/exit flicker when hovering the dead zone between
// icons.
//
// Verified against https://quickshell.org/docs/v0.3.0/ (PanelWindow,
// SystemClock, ShellScreen, Quickshell.execDetached, Quickshell.Networking)
// and https://www.nerdfonts.com/cheat-sheet for icon codepoints
// (nf-md-ethernet_cable U+F0201, nf-fa-power_off U+F011,
// nf-md-logout U+F0343) rather than guessed. All icon glyphs are set
// via String.fromCodePoint() rather than literal characters, since a
// literal character silently turned into an empty string once already.

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Services.Notifications

ShellRoot {
    // Tracks whether the real session lock (quickshell-lock/shell.qml) is
    // currently up, via the flag file it and lock.sh write to. Lets the
    // corner pill hide itself while locked -- it should only be visible
    // once actually logged in, not float on top of the lock screen.
    FileView {
        id: lockStateFile
        path: Quickshell.env("XDG_RUNTIME_DIR") + "/quickshell-lock-state"
        watchChanges: true
        onFileChanged: reload()
    }

    NotificationServer {
        id: notifServer
        bodySupported: true
        imageSupported: true
        actionsSupported: false
        onNotification: notification => {
            notification.tracked = true
        }
    }

    PanelWindow {
        id: notifPanel
        screen: Quickshell.screens.find(s => s.name === "DP-6")

        anchors {
            top: true
            right: true
        }

        margins {
            top: 12
            right: 12
        }

        implicitWidth: 320
        implicitHeight: Math.max(1, notifColumn.implicitHeight)
        color: "transparent"

        Column {
            id: notifColumn
            width: parent.width
            spacing: 8

            Repeater {
                model: notifServer.trackedNotifications

                delegate: Item {
                    id: notifCard
                    required property Notification modelData

                    width: notifColumn.width
                    height: notifBg.implicitHeight

                    // Tokyonight urgency colors, same scheme as the old
                    // dunst config (frame_color per urgency_*).
                    readonly property color urgencyColor:
                        modelData.urgency === NotificationUrgency.Critical ? "#f7768e"
                        : modelData.urgency === NotificationUrgency.Low ? "#565f89"
                        : "#7aa2f7"

                    // image is often a direct picture (e.g. a contact
                    // photo); appIcon is usually a themed icon *name*
                    // that needs resolving via Quickshell.iconPath() to
                    // get something Image.source can actually load.
                    // Falls back to "" cleanly (no broken-image icon)
                    // if neither is present or resolvable.
                    readonly property string iconSource:
                        modelData.image !== "" ? modelData.image
                        : modelData.appIcon !== "" ? Quickshell.iconPath(modelData.appIcon, "")
                        : ""

                    Rectangle {
                        id: notifBg
                        width: parent.width
                        implicitHeight: notifContent.implicitHeight + 24
                        color: "#1a1b26"
                        radius: 12
                        border.width: 1
                        border.color: notifCard.urgencyColor

                        Row {
                            id: notifContent
                            anchors.centerIn: parent
                            width: parent.width - 24
                            spacing: 10

                            Image {
                                width: 32
                                height: 32
                                visible: notifCard.iconSource !== ""
                                source: notifCard.iconSource
                                fillMode: Image.PreserveAspectFit
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Column {
                                width: notifCard.iconSource !== "" ? parent.width - 42 : parent.width
                                spacing: 4
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    width: parent.width
                                    color: "#c0caf5"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 13
                                    font.bold: true
                                    wrapMode: Text.Wrap
                                    textFormat: Text.PlainText
                                    text: notifCard.modelData.summary
                                }

                                Text {
                                    width: parent.width
                                    visible: notifCard.modelData.body !== ""
                                    color: "#a9b1d6"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 12
                                    wrapMode: Text.Wrap
                                    textFormat: Text.PlainText
                                    text: notifCard.modelData.body
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: notifCard.modelData.dismiss()
                        }
                    }

                    // Auto-expire: matches the old dunst timeouts
                    // (low=4s, normal=8s, critical=never).
                    Timer {
                        running: notifCard.modelData.urgency !== NotificationUrgency.Critical
                        interval: notifCard.modelData.urgency === NotificationUrgency.Low ? 4000 : 8000
                        onTriggered: notifCard.modelData.expire()
                    }
                }
            }
        }
    }

    PanelWindow {
        id: islandPanel
        screen: Quickshell.screens.find(s => s.name === "DP-6")

        // Missing/empty file (no lock has happened yet this session)
        // reads as "" here, which correctly counts as unlocked.
        visible: lockStateFile.text().trim() !== "locked"

        anchors {
            bottom: true
            right: true
        }

        margins {
            bottom: 10
            right: 12
        }

        property bool expanded: false

        // Computed reactively from containsMouse rather than set
        // imperatively via onEntered/onExited -- imperative handlers
        // race (exit-then-enter isn't guaranteed) when moving directly
        // between two adjacent hitboxes, causing a flash to "".  A pure
        // binding re-evaluates all inputs together and can't glitch
        // that way.
        readonly property string hoverText: ethernetArea.containsMouse ? "Ethernet: connected"
            : shutdownArea.containsMouse ? "Shut down"
            : logoutArea.containsMouse ? "Log out"
            : ""

        // Fixed headroom above the card for the hover label -- reserved
        // permanently so hovering never resizes the window.
        readonly property int hoverReserve: 22

        // Fixed window size -- always as wide as the fully-expanded
        // state. The window's own implicitWidth used to animate every
        // frame via a spring, which resizes the actual Wayland surface
        // continuously; that left a stale-buffer artifact (a leftover
        // beam/shadow the same color as the pill) after collapsing,
        // since the compositor doesn't always fully repaint a shrunk
        // layer-shell surface. Now only the *visible card* animates,
        // inside a surface that never changes size -- purely a GPU
        // composite within a static buffer, no resize artifact possible.
        // timeText's width is constant regardless of expanded (always
        // "hh:mm" in a monospace font), so this is a true fixed value,
        // not something that churns per frame.
        implicitWidth: timeText.implicitWidth + 16 + (32 * 3) + 24
        implicitHeight: 32 + 20 + hoverReserve

        color: "transparent"

        SystemClock {
            id: clock
            precision: SystemClock.Minutes
        }

        // Hover label -- sits in the transparent headroom above the
        // card, outside its background, never affects window sizing.
        Text {
            anchors.horizontalCenter: card.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 4
            visible: islandPanel.hoverText !== ""
            color: "#c0caf5"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 11
            text: islandPanel.hoverText
        }

        // The card -- anchored to the bottom-right, sized to the icon
        // row only. Only this animates; the window itself is fixed.
        Rectangle {
            id: card
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            width: mainRow.implicitWidth + 24
            height: 32 + 20
            color: "#a60d0e14" // alpha=0.65 (0xa6/255) -- icons stay fully opaque, they're separate children
            radius: Math.min(width, height) / 2

            Behavior on width {
                SpringAnimation { spring: 4; damping: 0.4 }
            }

            Row {
                id: mainRow
                anchors.centerIn: parent

                Item {
                    width: timeText.implicitWidth + 16
                    height: 32

                    Text {
                        id: timeText
                        anchors.centerIn: parent
                        color: "#c0caf5"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 14
                        text: Qt.formatDateTime(clock.date, "hh:mm")
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: islandPanel.expanded = !islandPanel.expanded
                    }
                }

                Item {
                    width: islandPanel.expanded ? 32 : 0
                    height: 32
                    clip: true
                    visible: width > 0

                    Text {
                        anchors.centerIn: parent
                        color: "#7aa2f7"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 18
                        text: String.fromCodePoint(0xf0201)
                    }

                    MouseArea {
                        id: ethernetArea
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                }

                Item {
                    width: islandPanel.expanded ? 32 : 0
                    height: 32
                    clip: true
                    visible: width > 0

                    Text {
                        anchors.centerIn: parent
                        color: "#e0af68"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 18
                        text: String.fromCodePoint(0xf0343)
                    }

                    MouseArea {
                        id: logoutArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            islandPanel.expanded = false
                            Quickshell.execDetached(["loginctl", "terminate-user", "vidar"])
                        }
                    }
                }

                Item {
                    width: islandPanel.expanded ? 32 : 0
                    height: 32
                    clip: true
                    visible: width > 0

                    Text {
                        anchors.centerIn: parent
                        color: "#f7768e"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 18
                        text: String.fromCodePoint(0xf011)
                    }

                    MouseArea {
                        id: shutdownArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            islandPanel.expanded = false
                            Quickshell.execDetached(["systemctl", "poweroff"])
                        }
                    }
                }
            }
        }
    }
}
