import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.config

// App icon sitting in a soft rounded well, like the launcher in the inspo.
Rectangle {
    id: root

    property string icon: ""
    property real iconSize: 24

    implicitWidth: 36
    implicitHeight: 36
    radius: 10
    color: Colors.surface

    IconImage {
        anchors.centerIn: parent
        implicitSize: root.iconSize
        source: root.icon === "" ? "" : root.icon.startsWith("/") || root.icon.includes("://") ? root.icon : Quickshell.iconPath(root.icon, "application-x-executable")
        asynchronous: true
    }
}
