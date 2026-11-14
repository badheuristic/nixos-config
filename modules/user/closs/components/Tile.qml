import QtQuick
import qs.config

// Control-centre toggle: a capsule with a round glyph well and two lines of
// text. Left click toggles, right click opens the related settings.
Rectangle {
    id: root

    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property bool active: false
    signal clicked
    signal secondaryClicked

    implicitHeight: 60
    radius: height / 2
    color: mouse.containsMouse ? Colors.surface2 : Colors.surface
    scale: mouse.pressed ? 0.97 : 1

    Behavior on color {
        ColorAnimation { duration: Style.quick }
    }
    Behavior on scale {
        NumberAnimation { duration: Style.quick; easing.type: Easing.OutCubic }
    }

    Rectangle {
        id: well
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        width: 40
        height: 40
        radius: 20
        color: root.active ? Colors.primary : Colors.surface3

        Behavior on color {
            ColorAnimation { duration: Style.quick }
        }

        Icon {
            anchors.centerIn: parent
            icon: root.icon
            size: 20
            fill: root.active
            color: root.active ? Colors.primaryFg : Colors.fg
        }
    }

    Column {
        anchors.left: well.right
        anchors.leftMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 14
        anchors.verticalCenter: parent.verticalCenter
        spacing: 1

        Txt {
            width: parent.width
            text: root.title
            font.weight: Font.DemiBold
        }
        Txt {
            width: parent.width
            text: root.subtitle
            visible: text !== ""
            color: Colors.fgDim
            font.pixelSize: Style.fontSm
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: e => e.button === Qt.RightButton ? root.secondaryClicked() : root.clicked()
    }
}
