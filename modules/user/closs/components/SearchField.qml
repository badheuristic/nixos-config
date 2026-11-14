import QtQuick
import qs.config

// Search row used by the launcher, clipboard and wallpaper views.
// Navigation keys are handled by the owning view via `keys`.
Item {
    id: root

    property alias text: input.text
    property string placeholder: "Search…"
    property string trailing: ""
    property bool password: false
    signal accepted
    signal navigate(var event)

    implicitHeight: 42

    function focusInput(): void {
        input.forceActiveFocus();
    }

    Icon {
        id: glyph
        anchors.left: parent.left
        anchors.leftMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        icon: "search"
        size: 18
        color: Colors.fgDim
    }

    TextInput {
        id: input
        anchors.left: glyph.right
        anchors.leftMargin: 10
        anchors.right: trailingText.left
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        color: Colors.fg
        selectionColor: Colors.primary
        selectedTextColor: Colors.primaryFg
        font.family: Colors.fontUi
        font.pixelSize: Style.fontLg
        echoMode: root.password ? TextInput.Password : TextInput.Normal
        passwordCharacter: "●"
        clip: true
        focus: true
        cursorDelegate: Rectangle {
            width: 2
            radius: 1
            color: Colors.primary
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                running: input.activeFocus
                NumberAnimation { to: 0; duration: 500; easing.type: Easing.InOutQuad }
                NumberAnimation { to: 1; duration: 500; easing.type: Easing.InOutQuad }
            }
        }

        Keys.onPressed: e => {
            if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) {
                root.accepted();
                e.accepted = true;
            } else {
                root.navigate(e);
            }
        }

        Txt {
            anchors.fill: parent
            text: root.placeholder
            color: Colors.fgFaint
            font.pixelSize: Style.fontLg
            visible: input.text === ""
        }
    }

    Txt {
        id: trailingText
        anchors.right: parent.right
        anchors.rightMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        text: root.trailing
        color: Colors.fgFaint
        font.pixelSize: Style.fontSm
    }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: Colors.surface2
    }
}
