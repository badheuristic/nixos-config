import QtQuick
import qs.config
import qs.services

// A notification as a row: icon, app · time, summary, body, actions.
Rectangle {
    id: root

    property var notif: null
    property bool showActions: true
    readonly property var arrived: new Date()

    implicitHeight: Math.max(74, content.implicitHeight + 20)
    radius: 14
    color: hover.hovered ? Colors.surface2 : Qt.lighter(Colors.surface, 1.3)

    HoverHandler {
        id: hover
    }

    Behavior on color {
        ColorAnimation { duration: Style.quick }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        cursorShape: Qt.PointingHandCursor
        onClicked: e => {
            if (e.button === Qt.MiddleButton) {
                root.notif?.dismiss();
                return;
            }
            Notifs.activate(root.notif);
            root.notif?.dismiss();
            Closs.close();
        }
    }

    RoundedImage {
        id: icon
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.top: parent.top
        anchors.topMargin: 10
        width: 36
        height: 36
        radius: 10
        sourceSize: 96
        color: Colors.surface2
        source: Notifs.iconFor(root.notif)

        Icon {
            anchors.centerIn: parent
            visible: icon.status !== Image.Ready
            icon: "notifications"
            size: 18
            color: Colors.fgDim
        }
    }

    Column {
        id: content
        anchors.left: icon.right
        anchors.leftMargin: 10
        anchors.right: close.left
        anchors.rightMargin: 6
        anchors.top: parent.top
        anchors.topMargin: 10
        spacing: 2

        Txt {
            width: parent.width
            text: (root.notif?.appName || "Notification") + "  ·  " + Qt.formatDateTime(root.arrived, "HH:mm")
            font.pixelSize: Style.fontXs
            color: Colors.fgDim
        }
        Txt {
            width: parent.width
            text: root.notif?.summary ?? ""
            font.weight: Font.DemiBold
        }
        Txt {
            width: parent.width
            text: root.notif?.body ?? ""
            visible: text !== ""
            maximumLineCount: 2
            wrapMode: Text.Wrap
            textFormat: Text.PlainText
            font.pixelSize: Style.fontSm
            color: Colors.fgDim
        }

        Row {
            visible: root.showActions && actions.count > 0
            spacing: 6
            topPadding: 4

            Repeater {
                id: actions
                model: (root.notif?.actions ?? []).filter(a => a.identifier !== "default")

                Rectangle {
                    required property var modelData
                    height: 26
                    width: label.implicitWidth + 20
                    radius: 13
                    color: actionMouse.containsMouse ? Colors.surface3 : Colors.surface2

                    Txt {
                        id: label
                        anchors.centerIn: parent
                        text: modelData.text
                        font.pixelSize: Style.fontXs
                        font.weight: Font.Medium
                    }
                    MouseArea {
                        id: actionMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: modelData.invoke()
                    }
                }
            }
        }
    }

    CircleButton {
        id: close
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.top: parent.top
        anchors.topMargin: 8
        implicitWidth: 22
        iconSize: 14
        icon: "close"
        flat: true
        tint: Colors.fgDim
        opacity: hover.hovered ? 1 : 0
        onClicked: root.notif?.dismiss()

        Behavior on opacity {
            NumberAnimation { duration: Style.quick }
        }
    }
}
