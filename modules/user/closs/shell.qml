//@ pragma UseQApplication
//@ pragma IconTheme Papirus-Dark

// Closs — a single morphing island for Hyprland.
// Wallpaper, status, launcher, control centre, notifications, OSD, polkit
// agent, power menu and tray are all states of one surface.

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.services
import qs.island

ShellRoot {
    id: shell

    Variants {
        model: Quickshell.screens
        Wallpaper {}
    }

    Variants {
        model: Quickshell.screens
        Island {}
    }

    // Make sure singletons with side effects start immediately.
    Component.onCompleted: {
        Notifs.dnd;
        Polkit.registered;
    }

    // ── IPC: `qs -c closs ipc call <target> <fn> [args]` ─────────────
    IpcHandler {
        target: "island"
        function open(view: string): void { Closs.open(view); }
        function toggle(view: string): void { Closs.toggle(view); }
        function close(): void { Closs.close(); }
        // replay the workspace-switch animation (testing)
        function workspace(from: int, to: int): void { Closs.flashWorkspace(from, to); }
    }

    IpcHandler {
        target: "osd"
        function volumeUp(): void { Audio.step(0.05); }
        function volumeDown(): void { Audio.step(-0.05); }
        function volumeMute(): void { Audio.toggleMute(); }
        function micMute(): void { Audio.toggleMic(); }
        function brightnessUp(): void { Brightness.step(0.05); }
        function brightnessDown(): void { Brightness.step(-0.05); }
    }

    IpcHandler {
        target: "lock"
        function lock(): void { Session.lock(); }
    }

    IpcHandler {
        target: "wallpaper"
        function set(path: string): void { Wallpapers.set(path); }
        function get(): string { return Wallpapers.current; }
        function next(): void { Wallpapers.cycle(1); }
        function prev(): void { Wallpapers.cycle(-1); }
    }

    IpcHandler {
        target: "notifs"
        function toggleDnd(): void { Notifs.dnd = !Notifs.dnd; }
        function clear(): void { Notifs.clear(); }
    }

    // ── Hyprland global shortcuts: `bind = …, global, closs:<name>` ──
    LazyLoader {
        active: Compositor.hyprland

        Scope {
            GlobalShortcut {
                appid: "closs"
                name: "launcher"
                description: "Toggle the app launcher"
                onPressed: Closs.toggle("launcher")
            }
            GlobalShortcut {
                appid: "closs"
                name: "clipboard"
                description: "Toggle clipboard history"
                onPressed: Closs.toggle("clipboard")
            }
            GlobalShortcut {
                appid: "closs"
                name: "control"
                description: "Toggle the control centre"
                onPressed: Closs.toggle("control")
            }
            GlobalShortcut {
                appid: "closs"
                name: "dashboard"
                description: "Toggle the dashboard"
                onPressed: Closs.toggle("dashboard")
            }
            GlobalShortcut {
                appid: "closs"
                name: "calendar"
                description: "Toggle the calendar"
                onPressed: Closs.toggle("calendar")
            }
            GlobalShortcut {
                appid: "closs"
                name: "power"
                description: "Toggle the power menu"
                onPressed: Closs.toggle("power")
            }
            GlobalShortcut {
                appid: "closs"
                name: "wallpaper"
                description: "Toggle the wallpaper picker"
                onPressed: Closs.toggle("wallpaper")
            }
            GlobalShortcut {
                appid: "closs"
                name: "armoury"
                description: "Toggle the Armoury panel (ROG hardware controls)"
                onPressed: Closs.toggle("armoury")
            }
            GlobalShortcut {
                appid: "closs"
                name: "tray"
                description: "Toggle the tray"
                onPressed: Closs.toggle("tray")
            }
            GlobalShortcut {
                appid: "closs"
                name: "lock"
                description: "Lock the session"
                onPressed: Session.lock()
            }
        }
    }
}
