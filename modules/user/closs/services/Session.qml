pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Lock state is mirrored to a marker file so that if the shell ever
    // crashes while locked, it re-locks immediately when systemd restarts it.
    property bool locked: false
    property bool ready: false

    readonly property string user: Quickshell.env("USER") ?? "user"
    property string uptime: ""

    function lock(): void {
        if (locked)
            return;
        Closs.close();
        locked = true;
        marker.setText("1\n");
    }

    function unlocked(): void {
        locked = false;
        marker.setText("");
    }

    function suspend(): void {
        Quickshell.execDetached(["systemctl", "suspend"]);
    }
    function logout(): void {
        Compositor.dispatch("exit");
    }
    function reboot(): void {
        Quickshell.execDetached(["systemctl", "reboot"]);
    }
    function poweroff(): void {
        Quickshell.execDetached(["systemctl", "poweroff"]);
    }

    function refreshUptime(): void {
        uptimeFile.reload();
    }

    FileView {
        id: marker
        path: Quickshell.statePath("locked")
        printErrors: false
        onLoaded: {
            if (text().trim() === "1")
                root.locked = true;
            root.ready = true;
        }
        onLoadFailed: root.ready = true
    }

    FileView {
        id: uptimeFile
        path: "/proc/uptime"
        onLoaded: {
            const s = Math.floor(parseFloat(text().split(" ")[0]));
            const d = Math.floor(s / 86400), h = Math.floor((s % 86400) / 3600), m = Math.floor((s % 3600) / 60);
            root.uptime = "Up " + (d > 0 ? `${d}d ` : "") + (h > 0 ? `${h}h ` : "") + `${m}min`;
        }
    }
}
