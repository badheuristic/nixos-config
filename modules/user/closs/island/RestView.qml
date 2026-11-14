import QtQuick
import qs.config
import qs.services
import qs.components

// The idle pill: a centred clock, flanked by mirrored slots so the clock
// never drifts off-centre (album art ↔ equaliser, or status glyphs ↔ spacer).
Item {
    id: root

    readonly property bool media: Media.active && Media.playing
    readonly property var glyphs: [
        Notifs.dnd ? "do_not_disturb_on" : "",
        Audio.micMuted ? "mic_off" : "",
        Battery.low ? "battery_alert" : "",
        Battery.present && Battery.charging ? "bolt" : ""
    ].filter(g => g !== "")

    readonly property real side: media ? 20 : glyphs.length * 16

    implicitWidth: Math.max(128, clock.implicitWidth + 2 * side + (side > 0 ? 2 * 10 : 0) + 40)
    implicitHeight: Style.restHeight

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: e => {
            if (e.button === Qt.RightButton)
                Closs.open("control");
            else if (e.button === Qt.MiddleButton)
                Media.toggle();
            else
                Closs.open("dashboard");
        }
        onWheel: w => Audio.step(w.angleDelta.y > 0 ? 0.05 : -0.05)
    }

    // left: album art
    Item {
        anchors.right: clock.left
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        width: root.side
        height: 20

        RoundedImage {
            anchors.fill: parent
            visible: root.media
            radius: 6
            sourceSize: 64
            source: Media.art
        }
    }

    Txt {
        id: clock
        anchors.centerIn: parent
        anchors.verticalCenterOffset: Style.notch ? -1 : 0
        text: Time.hhmm
        font.family: Colors.fontRounded
        font.pixelSize: 14
        font.weight: Font.DemiBold
        font.features: ({ "tnum": 1 })
    }

    // right: equaliser or status glyphs
    Item {
        anchors.left: clock.right
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        width: root.side
        height: 20

        Equalizer {
            anchors.centerIn: parent
            visible: root.media
            playing: root.media
        }

        Row {
            anchors.centerIn: parent
            visible: !root.media
            spacing: 2
            Repeater {
                model: root.glyphs
                Icon {
                    required property string modelData
                    icon: modelData
                    size: 14
                    fill: true
                    color: modelData === "battery_alert" ? Colors.red : Colors.fgDim
                }
            }
        }
    }
}
