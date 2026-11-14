pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// cliphist-backed clipboard history.
Singleton {
    id: root

    // [{ id, text, line }]
    property var entries: []

    function refresh(): void {
        list.running = true;
    }

    function copy(entry: var): void {
        if (!entry)
            return;
        Quickshell.execDetached(["sh", "-c", "printf '%s' \"$1\" | cliphist decode | wl-copy", "sh", entry.line]);
    }

    function remove(entry: var): void {
        if (!entry)
            return;
        Quickshell.execDetached(["sh", "-c", "printf '%s' \"$1\" | cliphist delete", "sh", entry.line]);
        entries = entries.filter(e => e.id !== entry.id);
    }

    function wipe(): void {
        Quickshell.execDetached(["cliphist", "wipe"]);
        entries = [];
    }

    Process {
        id: list
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.entries = text.split("\n").filter(l => l !== "").slice(0, 200).map(line => {
                    const tab = line.indexOf("\t");
                    return {
                        id: line.slice(0, tab),
                        text: line.slice(tab + 1).replace(/\s+/g, " ").trim(),
                        line: line
                    };
                });
            }
        }
    }
}
