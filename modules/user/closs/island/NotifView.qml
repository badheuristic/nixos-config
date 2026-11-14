import QtQuick
import qs.config
import qs.services
import qs.components

// A new notification drops out of the island, then folds back up.
Item {
    id: root

    implicitWidth: 420
    implicitHeight: card.implicitHeight + 16

    NotifCard {
        id: card
        anchors.fill: parent
        anchors.margins: 8
        color: "transparent"
        notif: Notifs.popup
        onNotifChanged: if (!notif) Closs.clearTransient()
    }
}
