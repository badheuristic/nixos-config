import QtQuick
import qs.config
import qs.services
import qs.components

// Volume / brightness / mic feedback: the pill stretches into a level meter.
Item {
    id: root

    readonly property string kind: Closs.osdKind
    readonly property real value: kind === "brightness" ? Brightness.value
        : kind === "mic" ? (Audio.micMuted ? 0 : 1)
        : Audio.muted ? 0 : Audio.volume
    readonly property string icon: kind === "brightness" ? Brightness.icon
        : kind === "mic" ? (Audio.micMuted ? "mic_off" : "mic")
        : Audio.icon
    readonly property string label: kind === "mic" ? (Audio.micMuted ? "Muted" : "Live")
        : kind === "volume" && Audio.muted ? "Muted"
        : Math.round(value * 100) + ""

    implicitWidth: 300
    implicitHeight: 42

    Icon {
        id: glyph
        anchors.left: parent.left
        anchors.leftMargin: 18
        anchors.verticalCenter: parent.verticalCenter
        icon: root.icon
        fill: true
        size: 18
    }

    Rectangle {
        anchors.left: glyph.right
        anchors.leftMargin: 12
        anchors.right: pct.left
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        height: 6
        radius: 3
        color: Colors.surface2

        Rectangle {
            height: parent.height
            radius: parent.radius
            width: parent.width * Math.max(0, Math.min(1, root.value))
            color: Colors.fg
            Behavior on width {
                NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
            }
        }
    }

    Txt {
        id: pct
        anchors.right: parent.right
        anchors.rightMargin: 18
        anchors.verticalCenter: parent.verticalCenter
        width: 38
        horizontalAlignment: Text.AlignRight
        text: root.label
        font.family: Colors.fontRounded
        font.pixelSize: Style.fontSm
        font.weight: Font.DemiBold
        font.features: ({ "tnum": 1 })
        color: Colors.fgDim
    }
}
