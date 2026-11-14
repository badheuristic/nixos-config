pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

Singleton {
    id: root

    readonly property string user: Quickshell.env("USER") ?? "user"
    property string uptime: ""

    // hyprlock does the locking. It reads the wallpaper through a link
    // (refreshed here so it matches the desktop) and has one config per
    // island shape so its island matches too.
    function lock(): void {
        Closs.close();
        Quickshell.execDetached(["sh", "-c",
            'mkdir -p "$HOME/.cache/closs" && ln -sfn "$1" "$HOME/.cache/closs/lock-wallpaper"; pidof hyprlock >/dev/null || exec hyprlock -c "$HOME/.config/hypr/hyprlock-$2.conf"',
            "sh", Wallpapers.current, Style.notch ? "notch" : "pill"]);
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
        id: uptimeFile
        path: "/proc/uptime"
        onLoaded: {
            const s = Math.floor(parseFloat(text().split(" ")[0]));
            const d = Math.floor(s / 86400), h = Math.floor((s % 86400) / 3600), m = Math.floor((s % 3600) / 60);
            root.uptime = "Up " + (d > 0 ? `${d}d ` : "") + (h > 0 ? `${h}h ` : "") + `${m}min`;
        }
    }
}
