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
import Quickshell.Services.Pipewire

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

    // Activates live property tracking for these two nodes -- Pipewire
    // nodes are otherwise lazily subscribed, so volume/mute changes
    // wouldn't actually notify without this.
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
    }

    // Volume OSD -- a small pill that appears briefly whenever volume or
    // mute changes (via the XF86Audio* keybinds calling wpctl, which
    // Pipewire picks up reactively regardless of who changed it), then
    // auto-hides. Hyprland has no OSD of its own, so without this,
    // volume/mute changes are otherwise invisible.
    PanelWindow {
        id: osdPanel
        screen: Quickshell.screens.find(s => s.name === "DP-6")
        visible: false

        // Default ExclusionMode.Auto reserves screen space matching this
        // panel's size and pushes tiled windows away from the anchored
        // edge -- fine for a permanent bar, wrong for a transient popup
        // that should float over everything without shrinking anything.
        exclusionMode: ExclusionMode.Ignore

        readonly property var sinkAudio: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio : null
        readonly property real volumePct: sinkAudio ? sinkAudio.volume : 0
        readonly property bool isMuted: sinkAudio ? sinkAudio.muted : false
        // Matches the -l 1.5 cap on the XF86AudioRaiseVolume keybind in
        // hyprland.lua -- the bar's full width represents this max, not
        // a flat 100%, so boosted volume is visible instead of just
        // reading as "full" the same as exactly 100% would.
        readonly property real maxVolume: 1.5
        readonly property string accentColor: osdPanel.isMuted ? "#f7768e"
            : osdPanel.volumePct > 1 ? "#e0af68" // boosted past 100% -- distortion risk
            : "#7aa2f7"

        // Icon codepoints verified against the nerd-fonts glyphnames.json
        // registry: nf-md-volume_mute=U+F075F, nf-md-volume_off=U+F0581,
        // nf-md-volume_low=U+F057F, nf-md-volume_medium=U+F0580,
        // nf-md-volume_high=U+F057E.
        readonly property string icon: isMuted ? String.fromCodePoint(0xf075f)
            : volumePct <= 0 ? String.fromCodePoint(0xf0581)
            : volumePct < 0.34 ? String.fromCodePoint(0xf057f)
            : volumePct < 0.67 ? String.fromCodePoint(0xf0580)
            : String.fromCodePoint(0xf057e)

        anchors {
            bottom: true
        }

        margins {
            bottom: 90
        }

        implicitWidth: 220
        implicitHeight: 56
        color: "transparent"

        Timer {
            id: hideTimer
            interval: 1500
            onTriggered: osdPanel.visible = false
        }

        Connections {
            target: osdPanel.sinkAudio
            function onVolumeChanged() {
                osdPanel.visible = true
                hideTimer.restart()
            }
            function onMutedChanged() {
                osdPanel.visible = true
                hideTimer.restart()
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: "#e60d0e14" // alpha=0.9 (0xe6/255) -- OSD should read clearly

            Row {
                anchors.centerIn: parent
                spacing: 12

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    color: osdPanel.accentColor
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 20
                    text: osdPanel.icon
                }

                Rectangle {
                    id: barTrack
                    anchors.verticalCenter: parent.verticalCenter
                    width: 110
                    height: 6
                    radius: 3
                    color: "#292e42"

                    Rectangle {
                        height: parent.height
                        radius: 3
                        color: osdPanel.accentColor
                        width: parent.width * Math.min(1, Math.max(0, osdPanel.volumePct / osdPanel.maxVolume))
                    }

                    // Marks where "normal" 100% sits on a track whose
                    // full width represents maxVolume (150%) instead.
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        x: parent.width * (1 / osdPanel.maxVolume) - width / 2
                        width: 1
                        height: parent.height + 4
                        color: "#565f89"
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    color: "#c0caf5"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 13
                    text: Math.round(osdPanel.volumePct * 100) + "%"
                }
            }
        }
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
        exclusionMode: ExclusionMode.Ignore

        anchors {
            top: true
            right: true
        }

        margins {
            top: 12
            right: 12
        }

        implicitWidth: 420
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
                        implicitHeight: notifContent.implicitHeight + 32
                        // Same background/alpha as the pill and calendar
                        // popup cards, for a consistent look across the
                        // whole shell -- was a fully opaque color before.
                        color: "#e60d0e14" // alpha=0.9 (0xe6/255)
                        radius: 16
                        border.width: 1
                        // Same static border as the calendar popup, except
                        // critical notifications keep a red border to stay
                        // noticeable -- shape/width/radius are otherwise
                        // identical either way.
                        border.color: notifCard.modelData.urgency === NotificationUrgency.Critical
                            ? "#f7768e" : "#292e42"

                        Row {
                            id: notifContent
                            anchors.centerIn: parent
                            width: parent.width - 32
                            spacing: 12

                            Image {
                                width: 40
                                height: 40
                                visible: notifCard.iconSource !== ""
                                source: notifCard.iconSource
                                fillMode: Image.PreserveAspectFit
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Column {
                                width: notifCard.iconSource !== "" ? parent.width - 52 : parent.width
                                spacing: 6
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    width: parent.width
                                    color: "#c0caf5"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 16
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
                                    font.pixelSize: 14
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
        exclusionMode: ExclusionMode.Ignore

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
        // Independent of `expanded` itself, but collapsing the pill hides
        // the calendar too -- see calendarPopup.visible -- since its own
        // icon (the only way to close it) disappears with the rest.
        property bool calendarOpen: false

        // Computed reactively from containsMouse rather than set
        // imperatively via onEntered/onExited -- imperative handlers
        // race (exit-then-enter isn't guaranteed) when moving directly
        // between two adjacent hitboxes, causing a flash to "".  A pure
        // binding re-evaluates all inputs together and can't glitch
        // that way.
        readonly property string hoverText: calendarArea.containsMouse ? "Calendar"
            : ethernetArea.containsMouse ? "Ethernet: connected"
            : sleepArea.containsMouse ? "Sleep"
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
        implicitWidth: timeText.implicitWidth + 16 + (32 * 5) + 24
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

                // Calendar icon -- a small mini-page mimicking the classic
                // "today" calendar app icon (colored header strip + day
                // number below), not a static Nerd Font glyph, since the
                // whole point is that it visibly updates with the date.
                Item {
                    width: islandPanel.expanded ? 32 : 0
                    height: 32
                    clip: true
                    visible: width > 0

                    Rectangle {
                        anchors.centerIn: parent
                        width: 22
                        height: 22
                        radius: 4
                        color: "#1a1b26"
                        border.width: 1
                        border.color: "#414868"
                        clip: true

                        Rectangle {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 6
                            color: "#f7768e"
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 1
                            color: "#c0caf5"
                            font.family: "JetBrainsMono Nerd Font"
                            font.bold: true
                            font.pixelSize: 11
                            text: Qt.formatDateTime(clock.date, "d")
                        }
                    }

                    MouseArea {
                        id: calendarArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: islandPanel.calendarOpen = !islandPanel.calendarOpen
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

                // nf-md-sleep (U+F04B2), same verified codepoint used on
                // the lock screen's own power row (see quickshell-lock/
                // LockSurface.qml) -- cyan since ethernet/logout/shutdown
                // already claim blue/orange/red in this pill.
                Item {
                    width: islandPanel.expanded ? 32 : 0
                    height: 32
                    clip: true
                    visible: width > 0

                    Text {
                        anchors.centerIn: parent
                        color: "#7dcfff"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 18
                        text: String.fromCodePoint(0xf04b2)
                    }

                    MouseArea {
                        id: sleepArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            islandPanel.expanded = false
                            Quickshell.execDetached(["systemctl", "suspend"])
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

    // Small month-view calendar, opened by the pill's calendar icon.
    // Deliberately just a viewer for now -- day cells aren't clickable
    // yet; a rofi-driven fullscreen version is planned separately later.
    PanelWindow {
        id: calendarPopup
        screen: Quickshell.screens.find(s => s.name === "DP-6")
        exclusionMode: ExclusionMode.Ignore
        // Tied to islandPanel.expanded too -- if the pill collapses, the
        // icon that's the only way to close this disappears with it, so
        // the popup would otherwise be stuck open with no way to dismiss.
        visible: islandPanel.expanded && islandPanel.calendarOpen

        anchors {
            bottom: true
            right: true
        }

        // Pill's own implicitHeight (32 fixed row + 20 padding +
        // hoverReserve 22 = 74) plus its own bottom margin (10) plus an
        // 8px gap, so the popup sits just above it without touching.
        margins {
            bottom: islandPanel.implicitHeight + 10 + 8
            right: 12
        }

        implicitWidth: 300
        implicitHeight: calendarColumn.implicitHeight + 32
        color: "transparent"

        readonly property date today: clock.date
        readonly property int gridYear: today.getFullYear()
        readonly property int gridMonth: today.getMonth() // 0-indexed
        readonly property int daysInMonth: new Date(gridYear, gridMonth + 1, 0).getDate()
        // JS Date.getDay(): Sunday=0..Saturday=6 -- shifted here to a
        // Monday-first week (Monday=0..Sunday=6).
        readonly property int leadingBlanks: (new Date(gridYear, gridMonth, 1).getDay() + 6) % 7

        Rectangle {
            anchors.fill: parent
            radius: 16
            color: "#e60d0e14" // alpha=0.9 (0xe6/255), same convention as the pill card
            border.width: 1
            border.color: "#292e42"

            Column {
                id: calendarColumn
                anchors.fill: parent
                anchors.margins: 16
                spacing: 10

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "#c0caf5"
                    font.family: "JetBrainsMono Nerd Font"
                    font.bold: true
                    font.pixelSize: 16
                    text: Qt.formatDateTime(calendarPopup.today, "MMMM yyyy")
                }

                Row {
                    width: parent.width

                    Repeater {
                        model: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

                        delegate: Text {
                            width: calendarColumn.width / 7
                            horizontalAlignment: Text.AlignHCenter
                            color: "#565f89"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            text: modelData
                        }
                    }
                }

                Grid {
                    width: parent.width
                    columns: 7

                    Repeater {
                        model: 42 // 6 weeks -- always enough to cover any month's layout

                        delegate: Item {
                            id: dayCell
                            width: calendarColumn.width / 7
                            height: 34

                            readonly property int dayNum: index - calendarPopup.leadingBlanks + 1
                            readonly property bool valid: dayNum >= 1 && dayNum <= calendarPopup.daysInMonth
                            readonly property bool isToday: valid && dayNum === calendarPopup.today.getDate()

                            Rectangle {
                                visible: dayCell.isToday
                                anchors.centerIn: parent
                                width: 26
                                height: 26
                                radius: 13
                                color: "#7aa2f7"
                            }

                            Rectangle {
                                visible: !dayCell.isToday && dayCell.valid && cellHover.containsMouse
                                anchors.centerIn: parent
                                width: 26
                                height: 26
                                radius: 13
                                color: "#292e42"
                            }

                            Text {
                                anchors.centerIn: parent
                                visible: dayCell.valid
                                color: dayCell.isToday ? "#1a1b26" : "#c0caf5"
                                font.family: "JetBrainsMono Nerd Font"
                                font.bold: dayCell.isToday
                                font.pixelSize: 12
                                text: dayCell.valid ? dayCell.dayNum : ""
                            }

                            MouseArea {
                                id: cellHover
                                anchors.fill: parent
                                hoverEnabled: true
                            }
                        }
                    }
                }
            }
        }
    }
}
