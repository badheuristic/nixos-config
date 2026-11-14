import QtQuick
import qs.config
import qs.services
import qs.components

// Session actions. ←/→ (or h/l) to move, Enter to confirm.
Item {
    id: root

    readonly property var actions: [
        { icon: "bedtime", label: "Suspend", run: () => Session.suspend() },
        { icon: "logout", label: "Log Out", run: () => Session.logout() },
        { icon: "lock", label: "Lock", run: () => Session.lock() },
        { icon: "restart_alt", label: "Restart", run: () => Session.reboot() },
        { icon: "power_settings_new", label: "Shut Down", run: () => Session.poweroff() }
    ]
    property int index: 2

    implicitWidth: 380
    implicitHeight: 150

    function activate(): void {
        index = 2;
        Session.refreshUptime();
    }

    function run(i: int): void {
        const a = actions[i];
        Closs.close();
        a.run();
    }

    Keys.onPressed: e => {
        if (e.key === Qt.Key_Left || e.key === Qt.Key_H || e.key === Qt.Key_Backtab) {
            index = (index + actions.length - 1) % actions.length;
            e.accepted = true;
        } else if (e.key === Qt.Key_Right || e.key === Qt.Key_L || e.key === Qt.Key_Tab) {
            index = (index + 1) % actions.length;
            e.accepted = true;
        } else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter || e.key === Qt.Key_Space) {
            run(index);
            e.accepted = true;
        }
    }

    Txt {
        anchors.top: parent.top
        anchors.topMargin: Style.pad
        anchors.horizontalCenter: parent.horizontalCenter
        text: Session.uptime
        font.pixelSize: Style.fontXs
        color: Colors.fgDim
    }

    Row {
        id: row
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 2
        spacing: 14

        Repeater {
            model: root.actions

            CircleButton {
                required property var modelData
                required property int index
                implicitWidth: 52
                iconSize: 22
                icon: modelData.icon
                active: index === root.index
                onClicked: root.run(index)

                HoverHandler {
                    onHoveredChanged: if (hovered) root.index = parent.index
                }
            }
        }
    }

    Txt {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.pad
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.actions[root.index].label
        font.pixelSize: Style.fontSm
        font.weight: Font.DemiBold
    }
}
