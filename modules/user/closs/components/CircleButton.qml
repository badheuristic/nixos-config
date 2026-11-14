import QtQuick
import qs.config

Rectangle {
    id: root

    property string icon: ""
    property real iconSize: 18
    property bool active: false
    property bool flat: false
    property color tint: Colors.fg
    signal clicked

    implicitWidth: 34
    implicitHeight: implicitWidth
    radius: width / 2
    color: active ? Colors.primary
        : mouse.pressed ? Colors.surface3
        : mouse.containsMouse ? Colors.surface2
        : flat ? "transparent" : Colors.surface
    scale: mouse.pressed ? 0.94 : 1

    Behavior on color {
        ColorAnimation { duration: Style.quick }
    }
    Behavior on scale {
        NumberAnimation { duration: Style.quick; easing.type: Easing.OutCubic }
    }

    Icon {
        anchors.centerIn: parent
        icon: root.icon
        size: root.iconSize
        fill: root.active
        color: root.active ? Colors.primaryFg : root.tint
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
