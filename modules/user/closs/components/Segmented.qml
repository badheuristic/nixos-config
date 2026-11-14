import QtQuick
import qs.config

// Apple-style segmented control: a recessed track with a raised thumb that
// slides to the chosen segment. model: [{ id, label, icon? }, …]
Rectangle {
    id: root

    property var model: []
    property string current: ""
    property bool accent: false     // fill the thumb with the accent colour
    signal picked(string id)

    readonly property int index: model.findIndex(m => m.id === current)
    readonly property real segment: (width - 6) / Math.max(1, model.length)
    readonly property bool hasIcons: model.some(m => !!m.icon)

    implicitHeight: hasIcons ? 54 : 32
    radius: hasIcons ? 16 : height / 2
    color: Colors.surface2

    Rectangle {
        id: thumb
        visible: root.index >= 0
        x: 3 + Math.max(0, root.index) * root.segment
        y: 3
        width: root.segment
        height: parent.height - 6
        radius: root.radius - 3
        color: root.accent ? Colors.primary : Colors.surface3

        Behavior on x {
            NumberAnimation { duration: 320; easing.type: Easing.BezierSpline; easing.bezierCurve: Style.morphCurve }
        }
        Behavior on color {
            ColorAnimation { duration: Style.quick }
        }
    }

    Row {
        x: 3
        y: 3

        Repeater {
            model: root.model

            Item {
                id: seg
                required property var modelData
                required property int index
                readonly property bool on: index === root.index
                readonly property color ink: on && root.accent ? Colors.primaryFg : on ? Colors.fg : Colors.fgDim

                width: root.segment
                height: root.height - 6

                Column {
                    anchors.centerIn: parent
                    spacing: 2

                    Icon {
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: !!seg.modelData.icon
                        icon: seg.modelData.icon ?? ""
                        size: 18
                        fill: seg.on
                        color: seg.ink
                    }
                    Txt {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: seg.modelData.label
                        font.pixelSize: root.hasIcons ? Style.fontXs : Style.fontSm
                        font.weight: seg.on ? Font.DemiBold : Font.Medium
                        color: seg.ink
                        Behavior on color {
                            ColorAnimation { duration: Style.quick }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.picked(seg.modelData.id)
                }
            }
        }
    }
}
