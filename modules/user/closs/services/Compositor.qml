pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland

// Thin wrapper over Hyprland IPC. Everything degrades gracefully when the
// shell runs under another compositor (handy for previewing the shell).
Singleton {
    id: root

    readonly property bool hyprland: (Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") ?? "") !== ""

    // Name of the monitor that currently has focus.
    readonly property string focusedScreen: {
        if (hyprland && Hyprland.focusedMonitor)
            return Hyprland.focusedMonitor.name;
        return Quickshell.screens.length > 0 ? Quickshell.screens[0].name : "";
    }

    // Focused workspace and the regular (non-special) workspaces that exist
    readonly property int workspace: hyprland && Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 0
    readonly property var workspaces: hyprland
        ? Hyprland.workspaces.values.map(w => w.id).filter(id => id > 0).sort((a, b) => a - b)
        : []

    function hasFullscreen(screen: var): bool {
        if (!hyprland || !screen)
            return false;
        const mon = Hyprland.monitorFor(screen);
        return !!(mon && mon.activeWorkspace && mon.activeWorkspace.hasFullscreen);
    }

    function dispatch(request: string): void {
        if (hyprland)
            Hyprland.dispatch(request);
    }
}
