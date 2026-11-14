import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import qs.config
import qs.services
import qs.components

// Control centre: toggles, sliders, now playing, notifications.
Item {
    id: root

    implicitWidth: 440
    implicitHeight: column.implicitHeight + 2 * Style.pad

    function activate(): void {
        Brightness.refresh();
        Phone.refresh();
        Armoury.refresh();
    }

    Column {
        id: column
        anchors.fill: parent
        anchors.margins: Style.pad
        spacing: Style.gap

        // header
        Item {
            width: parent.width
            height: 24

            Txt {
                anchors.left: parent.left
                anchors.leftMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                text: Time.hhmm
                font.family: Colors.fontRounded
                font.weight: Font.Bold
                font.pixelSize: Style.fontLg
            }

            Row {
                anchors.right: parent.right
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6
                visible: Battery.present

                Txt {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Battery.label
                    color: Colors.fgDim
                    font.pixelSize: Style.fontSm
                }
                Txt {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Math.round(Battery.level * 100) + "%"
                    font.pixelSize: Style.fontSm
                    font.weight: Font.DemiBold
                }
                // battery glyph drawn as a capsule so it matches the type
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 24
                    height: 12
                    radius: 4
                    color: "transparent"
                    border.width: 1.2
                    border.color: Colors.fgDim
                    Rectangle {
                        x: 2
                        y: 2
                        height: parent.height - 4
                        width: Math.max(2, (parent.width - 4) * Battery.level)
                        radius: 2
                        color: Battery.low ? Colors.red : Battery.charging ? Colors.green : Colors.fg
                    }
                    Rectangle {
                        anchors.left: parent.right
                        anchors.leftMargin: 1
                        anchors.verticalCenter: parent.verticalCenter
                        width: 2
                        height: 4
                        radius: 1
                        color: Colors.fgDim
                    }
                }
            }
        }

        Grid {
            width: parent.width
            columns: 2
            columnSpacing: Style.gap
            rowSpacing: Style.gap

            readonly property real cell: (width - columnSpacing) / 2

            Tile {
                width: parent.cell
                icon: Net.icon
                title: "Wi-Fi"
                subtitle: Net.label
                active: Net.wifiEnabled && Net.connected
                onClicked: Net.toggleWifi()
                onSecondaryClicked: { Quickshell.execDetached(["nmgui"]); Closs.close(); }
            }
            Tile {
                width: parent.cell
                icon: Notifs.dnd ? "do_not_disturb_on" : "do_not_disturb_off"
                title: "Focus"
                subtitle: Notifs.dnd ? "On" : "Off"
                active: Notifs.dnd
                onClicked: Notifs.dnd = !Notifs.dnd
            }
            Tile {
                width: parent.cell
                icon: Bt.icon
                title: "Bluetooth"
                subtitle: Bt.label
                active: Bt.enabled
                onClicked: Bt.toggle()
                onSecondaryClicked: { Quickshell.execDetached(["blueman-manager"]); Closs.close(); }
            }
            Tile {
                width: parent.cell
                icon: "nightlight"
                title: "Night Light"
                subtitle: NightLight.enabled ? NightLight.temperature + "K" : "Off"
                active: NightLight.enabled
                onClicked: NightLight.toggle()
            }
            Tile {
                width: parent.cell
                icon: Phone.connected ? "phone_iphone" : "mobile_off"
                title: "Phone"
                subtitle: Phone.connected ? Phone.name : "Not connected"
                active: Phone.connected
                onClicked: Phone.connected ? Phone.ring() : Phone.refresh()
                onSecondaryClicked: { Phone.open(); Closs.close(); }
            }
            // Armoury (z13ctl): click opens the panel, right click cycles
            // the performance profile. Falls back to power-profiles-daemon.
            Tile {
                width: parent.cell
                icon: Armoury.available ? Armoury.profileIcon : Battery.profileIcon
                title: Armoury.available ? "Armoury" : "Power Mode"
                subtitle: Armoury.available ? Armoury.profileLabel : Battery.profileLabel
                active: Armoury.available ? Armoury.profile !== "balanced" : Battery.profile !== 1
                onClicked: Armoury.available ? Closs.open("armoury") : Battery.cycleProfile()
                onSecondaryClicked: Armoury.available ? Armoury.cycleProfile() : Battery.cycleProfile()
            }
        }

        // island shape: hangs from the edge (notch) or floats (pill)
        Tile {
            width: parent.width
            icon: Style.notch ? "top_panel_open" : "pill"
            title: "Island"
            subtitle: Style.notch ? "Notch · click for pill" : "Pill · click for notch"
            active: false
            onClicked: Style.setNotch(!Style.notch)
        }

        // tray: click an app for its menu in the island
        Card {
            width: parent.width
            height: 48

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Closs.openTray("")
            }

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Repeater {
                    model: SystemTray.items.values.slice(0, 9)

                    Item {
                        id: trayApp
                        required property var modelData
                        width: 34
                        height: 34

                        Rectangle {
                            anchors.fill: parent
                            radius: 10
                            color: Colors.surface2
                            opacity: trayMouse.containsMouse ? 1 : 0
                            Behavior on opacity {
                                NumberAnimation { duration: Style.quick }
                            }
                        }
                        IconImage {
                            anchors.centerIn: parent
                            implicitSize: 18
                            source: trayApp.modelData.icon
                            asynchronous: true
                        }
                        MouseArea {
                            id: trayMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                            onClicked: e => e.button === Qt.MiddleButton ? trayApp.modelData.secondaryActivate() : Closs.openTray(trayApp.modelData.id)
                        }
                    }
                }
            }

            Txt {
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                visible: SystemTray.items.values.length === 0
                text: "No apps in the tray"
                color: Colors.fgDim
                font.pixelSize: Style.fontSm
            }
            Txt {
                anchors.right: trayChevron.left
                anchors.rightMargin: 2
                anchors.verticalCenter: parent.verticalCenter
                text: "Tray"
                color: Colors.fgDim
                font.pixelSize: Style.fontSm
            }
            Icon {
                id: trayChevron
                anchors.right: parent.right
                anchors.rightMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                icon: "chevron_right"
                size: 18
                color: Colors.fgDim
            }
        }

        SliderCard {
            width: parent.width
            visible: Brightness.available
            label: "Display"
            icon: "light_mode"
            value: Brightness.value
            showMore: false
            onMoved: v => Brightness.set(v)
        }

        SliderCard {
            width: parent.width
            label: "Sound · " + Audio.sinkName
            icon: Audio.muted ? "volume_off" : "volume_up"
            value: Audio.muted ? 0 : Audio.volume
            onMoved: v => Audio.setVolume(v)
            onMore: { Quickshell.execDetached(["pavucontrol"]); Closs.close(); }
        }

        MediaCard {
            width: parent.width
            compact: true
            visible: Media.active
        }

        // notifications
        Card {
            width: parent.width
            height: Notifs.count === 0 ? 120 : header.height + notifList.height + 20

            Item {
                id: header
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 12
                height: 18
                visible: Notifs.count > 0

                Txt {
                    anchors.left: parent.left
                    anchors.leftMargin: 2
                    text: "Notifications"
                    font.pixelSize: Style.fontSm
                    font.weight: Font.DemiBold
                    color: Colors.fgDim
                }
                Txt {
                    anchors.right: parent.right
                    anchors.rightMargin: 2
                    text: "Clear all"
                    font.pixelSize: Style.fontSm
                    color: clearMouse.containsMouse ? Colors.fg : Colors.fgDim
                    MouseArea {
                        id: clearMouse
                        anchors.fill: parent
                        anchors.margins: -6
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Notifs.clear()
                    }
                }
            }

            ListView {
                id: notifList
                visible: Notifs.count > 0
                anchors.top: header.bottom
                anchors.topMargin: 8
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 8
                height: Math.min(contentHeight, 3 * 74 + 2 * spacing)
                spacing: 6
                clip: true
                model: Notifs.list
                boundsBehavior: Flickable.StopAtBounds

                add: Transition {
                    NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
                }
                displaced: Transition {
                    NumberAnimation { property: "y"; duration: 220; easing.type: Easing.OutCubic }
                }

                delegate: NotifCard {
                    required property var modelData
                    width: ListView.view.width
                    notif: modelData
                }
            }

            Column {
                anchors.centerIn: parent
                visible: Notifs.count === 0
                spacing: 6

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 32
                    height: 32
                    radius: 16
                    color: Colors.surface2
                    Icon {
                        anchors.centerIn: parent
                        icon: "notifications"
                        size: 16
                        color: Colors.fgDim
                    }
                }
                Txt {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "All caught up"
                    font.weight: Font.DemiBold
                    font.pixelSize: Style.fontSm
                }
                Txt {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Nothing new since " + Qt.formatDateTime(Notifs.since, "HH:mm")
                    font.pixelSize: Style.fontXs
                    color: Colors.fgDim
                }
            }
        }
    }
}
