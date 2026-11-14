pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

Singleton {
    id: root

    property string current: Colors.defaultWallpaper
    property list<string> files: []

    function set(path: string): void {
        if (path === "")
            return;
        current = path;
        store.setText(path + "\n");
    }

    function cycle(delta: int): void {
        if (files.length === 0)
            return;
        const i = files.indexOf(current);
        set(files[((i < 0 ? 0 : i + delta) % files.length + files.length) % files.length]);
    }

    function refresh(): void {
        scan.running = true;
    }

    FileView {
        id: store
        path: Quickshell.statePath("wallpaper")
        printErrors: false
        onLoaded: {
            const t = text().trim();
            if (t !== "")
                root.current = t;
        }
    }

    Process {
        id: scan
        running: true
        command: ["sh", "-c", "find -L \"$1\" -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) | sort", "sh", Colors.wallpaperDir]
        stdout: StdioCollector {
            onStreamFinished: root.files = text.split("\n").filter(l => l !== "")
        }
    }
}
