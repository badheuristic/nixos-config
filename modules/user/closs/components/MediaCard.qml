import QtQuick
import qs.config
import qs.services

// Now-playing card: art, titles, transport, progress.
Card {
    id: root

    property bool compact: false

    implicitHeight: compact ? 84 : 120

    Component.onCompleted: Media.listeners++
    Component.onDestruction: Media.listeners--

    RoundedImage {
        id: art
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        width: root.compact ? 60 : 84
        height: width
        radius: 12
        source: Media.art

        Icon {
            anchors.centerIn: parent
            visible: art.status !== Image.Ready
            icon: "music_note"
            size: 28
            color: Colors.fgFaint
        }
    }

    Column {
        anchors.left: art.right
        anchors.leftMargin: 12
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: root.compact ? 4 : 6

        Txt {
            width: parent.width
            text: Media.title
            font.weight: Font.DemiBold
            color: Media.active ? Colors.fg : Colors.fgDim
        }
        Txt {
            width: parent.width
            text: Media.artist
            visible: text !== ""
            font.pixelSize: Style.fontSm
            color: Colors.fgDim
        }

        // progress
        Rectangle {
            visible: !root.compact && Media.length > 0
            width: parent.width
            height: 3
            radius: 1.5
            color: Colors.surface3

            Rectangle {
                height: parent.height
                radius: parent.radius
                width: parent.width * Math.max(0, Math.min(1, Media.position / Math.max(1, Media.length)))
                color: Colors.fg
                Behavior on width {
                    NumberAnimation { duration: 900 }
                }
            }
        }

        Row {
            spacing: 6
            CircleButton {
                implicitWidth: 28
                flat: true
                icon: "skip_previous"
                iconSize: 18
                onClicked: Media.previous()
            }
            CircleButton {
                implicitWidth: 28
                active: true
                icon: Media.playing ? "pause" : "play_arrow"
                iconSize: 18
                onClicked: Media.toggle()
            }
            CircleButton {
                implicitWidth: 28
                flat: true
                icon: "skip_next"
                iconSize: 18
                onClicked: Media.next()
            }
        }
    }
}
