pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Warm screen tint via hyprsunset. The process lives as long as it's on.
Singleton {
    id: root

    property int temperature: 4200
    readonly property bool enabled: proc.running

    function toggle(): void {
        proc.running = !proc.running;
    }

    Process {
        id: proc
        command: ["hyprsunset", "-t", String(root.temperature)]
    }
}
