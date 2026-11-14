pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// KDE Connect status: the first reachable, paired device.
Singleton {
    id: root

    property string name: ""
    property string deviceId: ""
    readonly property bool connected: deviceId !== ""

    function refresh(): void {
        if (!list.running)
            list.running = true;
    }

    function open(): void {
        Quickshell.execDetached(["kdeconnect-app"]);
    }

    function ring(): void {
        if (connected)
            Quickshell.execDetached(["kdeconnect-cli", "-d", deviceId, "--ring"]);
    }

    Process {
        id: list
        command: ["kdeconnect-cli", "--list-available", "--id-name-only"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                // "<id> <name>" per line
                const line = text.split("\n").find(l => l.trim() !== "") ?? "";
                const sep = line.indexOf(" ");
                root.deviceId = sep > 0 ? line.slice(0, sep) : "";
                root.name = sep > 0 ? line.slice(sep + 1).trim() : "";
            }
        }
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }
}
