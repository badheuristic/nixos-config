import QtQuick
import qs.config

// Row used by launcher-style lists. The selected row gets a soft surface and
// a short accent tick on its leading edge.
Item {
    id: root

    property bool selected: false
    property string title: ""
    property string subtitle: ""
    property alias leading: leadingSlot.data
    signal clicked
    signal hovered

    implicitHeight: 52

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: Colors.surface
        opacity: root.selected ? 1 : mouse.containsMouse ? 0.5 : 0

        Behavior on opacity {
            NumberAnimation { duration: Style.quick }
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 3
        height: root.selected ? 22 : 0
        radius: 1.5
        color: Colors.primary

        Behavior on height {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
    }

    Item {
        id: leadingSlot
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        width: 36
        height: 36
    }

    Column {
        anchors.left: leadingSlot.right
        anchors.leftMargin: 12
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 1

        Txt {
            width: parent.width
            text: root.title
            font.weight: Font.Medium
        }
        Txt {
            width: parent.width
            text: root.subtitle
            visible: text !== ""
            font.pixelSize: Style.fontSm
            color: Colors.fgDim
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
        onPositionChanged: root.hovered()
    }
}
