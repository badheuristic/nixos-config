import QtQuick
import qs.config

// Fat capsule slider with the glyph riding inside the fill, iOS-style.
Item {
    id: root

    property real value: 0
    property string icon: ""
    signal moved(real value)

    implicitHeight: 28

    readonly property real shown: Math.max(0, Math.min(1, value))

    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        color: Colors.surface2
        clip: true

        Rectangle {
            id: fillBar
            height: parent.height
            radius: height / 2
            width: Math.max(height, root.shown * parent.width)
            color: Colors.primary

            Behavior on width {
                enabled: !mouse.pressed
                NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
            }
        }

        Icon {
            anchors.left: parent.left
            anchors.leftMargin: 6
            anchors.verticalCenter: parent.verticalCenter
            icon: root.icon
            size: 16
            fill: true
            color: Colors.primaryFg
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        preventStealing: true

        function emit(x: real): void {
            root.moved(Math.max(0, Math.min(1, x / width)));
        }
        onPressed: e => emit(e.x)
        onPositionChanged: e => { if (pressed) emit(e.x); }
        onWheel: w => root.moved(Math.max(0, Math.min(1, root.value + (w.angleDelta.y > 0 ? 0.05 : -0.05))))
    }
}
