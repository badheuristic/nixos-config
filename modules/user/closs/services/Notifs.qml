pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    property bool dnd: false
    property var since: new Date()
    property Notification popup: null

    readonly property list<Notification> list: server.trackedNotifications.values.slice().reverse()
    readonly property int count: list.length

    function clear(): void {
        for (const n of server.trackedNotifications.values.slice())
            n.dismiss();
        since = new Date();
    }

    function iconFor(n: var): string {
        if (!n)
            return "";
        if (n.image)
            return n.image;
        if (n.appIcon)
            return n.appIcon.startsWith("/") || n.appIcon.startsWith("file:") ? n.appIcon : Quickshell.iconPath(n.appIcon, true);
        const entry = n.desktopEntry ? DesktopEntries.heuristicLookup(n.desktopEntry) : null;
        return entry ? Quickshell.iconPath(entry.icon, true) : "";
    }

    function activate(n: var): void {
        if (!n)
            return;
        const def = n.actions.find(a => a.identifier === "default");
        if (def)
            def.invoke();
        else if (n.actions.length === 1)
            n.actions[0].invoke();
    }

    NotificationServer {
        id: server
        keepOnReload: true
        persistenceSupported: true
        bodySupported: true
        bodyMarkupSupported: false
        actionsSupported: true
        imageSupported: true
        // Synchronous OSD-style hints from older scripts are ignored.
        extraHints: []

        onNotification: n => {
            n.tracked = true;
            // Volume/brightness notifications from legacy tools would just
            // duplicate the island OSD.
            if (n.hints["x-canonical-private-synchronous"] !== undefined) {
                n.dismiss();
                return;
            }
            root.popup = n;
            if (!root.dnd || n.urgency === NotificationUrgency.Critical)
                Closs.flashNotif();
        }
    }
}
