pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property real value: 0.5
    property bool available: false

    readonly property string icon: value < 0.34 ? "brightness_low"
        : value < 0.67 ? "brightness_medium"
        : "brightness_high"

    function set(v: real): void {
        v = Math.max(0.01, Math.min(1, v));
        value = v;
        Quickshell.execDetached(["brightnessctl", "-q", "set", Math.round(v * 100) + "%"]);
    }

    function step(delta: real): void {
        set(value + delta);
        Closs.flashOsd("brightness");
    }

    function refresh(): void {
        probe.running = true;
    }

    // brightnessctl -m prints: device,class,current,percent,max
    Process {
        id: probe
        command: ["brightnessctl", "-m", "info"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const f = text.trim().split(",");
                if (f.length >= 5 && parseInt(f[4]) > 0) {
                    root.value = parseInt(f[2]) / parseInt(f[4]);
                    root.available = true;
                }
            }
        }
    }
}
