import QtQuick
import Quickshell
import qs.config
import qs.services
import qs.components

// Polkit authentication, inside the island.
Item {
    id: root

    readonly property var flow: Polkit.flow
    property bool shake: false

    implicitWidth: 420
    implicitHeight: column.implicitHeight + 2 * Style.pad + 4

    function activate(): void {
        field.text = "";
        field.forceActiveFocus();
    }

    function submit(): void {
        if (!flow || !flow.isResponseRequired)
            return;
        Polkit.submit(field.text);
        field.text = "";
    }

    Connections {
        target: root.flow
        ignoreUnknownSignals: true
        function onAuthenticationFailed() {
            shakeAnim.restart();
        }
        function onIsResponseRequiredChanged() {
            if (root.flow?.isResponseRequired)
                field.forceActiveFocus();
        }
    }

    Column {
        id: column
        anchors.top: parent.top
        anchors.topMargin: Style.pad + 4
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Style.pad + 4
        anchors.rightMargin: Style.pad + 4
        spacing: 10

        Row {
            width: parent.width
            spacing: 12

            Rectangle {
                width: 44
                height: 44
                radius: 22
                color: Colors.surface2
                Icon {
                    anchors.centerIn: parent
                    icon: "shield_lock"
                    fill: true
                    size: 22
                }
            }

            Column {
                width: parent.width - 56
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2
                Txt {
                    width: parent.width
                    text: "Authentication required"
                    font.weight: Font.DemiBold
                    font.pixelSize: Style.fontMd + 1
                }
                Txt {
                    width: parent.width
                    text: root.flow?.message ?? ""
                    wrapMode: Text.Wrap
                    maximumLineCount: 3
                    font.pixelSize: Style.fontSm
                    color: Colors.fgDim
                }
            }
        }

        // password field
        Rectangle {
            id: box
            width: parent.width
            height: 42
            radius: 21
            color: Colors.surface
            border.width: 1
            border.color: field.activeFocus ? Colors.surface3 : "transparent"

            transform: Translate {
                id: shakeOffset
            }

            SequentialAnimation {
                id: shakeAnim
                loops: 1
                NumberAnimation { target: shakeOffset; property: "x"; to: -10; duration: 50 }
                NumberAnimation { target: shakeOffset; property: "x"; to: 9; duration: 70 }
                NumberAnimation { target: shakeOffset; property: "x"; to: -6; duration: 60 }
                NumberAnimation { target: shakeOffset; property: "x"; to: 4; duration: 60 }
                NumberAnimation { target: shakeOffset; property: "x"; to: 0; duration: 50 }
            }

            Icon {
                id: keyIcon
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                icon: "key"
                size: 16
                color: Colors.fgDim
            }

            TextInput {
                id: field
                anchors.left: keyIcon.right
                anchors.leftMargin: 10
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                echoMode: root.flow?.responseVisible ? TextInput.Normal : TextInput.Password
                passwordCharacter: "●"
                color: Colors.fg
                font.family: Colors.fontUi
                font.pixelSize: Style.fontMd
                font.letterSpacing: echoMode === TextInput.Password ? 2 : 0
                clip: true
                focus: true
                onAccepted: root.submit()

                Txt {
                    anchors.fill: parent
                    visible: field.text === ""
                    text: (root.flow?.inputPrompt || "Password").replace(/:\s*$/, "")
                    color: Colors.fgFaint
                }
            }
        }

        Txt {
            width: parent.width
            visible: text !== ""
            text: root.flow?.supplementaryMessage ?? ""
            color: root.flow?.supplementaryIsError ? Colors.red : Colors.fgDim
            font.pixelSize: Style.fontSm
            wrapMode: Text.Wrap
        }

        Row {
            anchors.right: parent.right
            spacing: 8

            Rectangle {
                width: 96
                height: 34
                radius: 17
                color: cancelMouse.containsMouse ? Colors.surface3 : Colors.surface2
                Txt {
                    anchors.centerIn: parent
                    text: "Cancel"
                    font.weight: Font.Medium
                }
                MouseArea {
                    id: cancelMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Polkit.cancel()
                }
            }
            Rectangle {
                width: 120
                height: 34
                radius: 17
                color: okMouse.containsMouse ? Colors.primaryHi : Colors.primary
                Txt {
                    anchors.centerIn: parent
                    text: "Authenticate"
                    font.weight: Font.DemiBold
                    color: Colors.primaryFg
                }
                MouseArea {
                    id: okMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.submit()
                }
            }
        }
    }
}
