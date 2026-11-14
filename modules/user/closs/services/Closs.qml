pragma Singleton

import QtQuick
import Quickshell
import qs.config

// The island is one surface; this is the single place that decides which
// state it is in.
//
//   view       – what the user explicitly opened (launcher, control, ...)
//   ambient  – short-lived ambient states (osd, notif) shown only at rest
//   polkit     – overrides everything while an auth request is pending
Singleton {
    id: root

    // Views that the user can open. "rest" is the idle pill.
    readonly property var views: ["dashboard", "launcher", "clipboard", "control", "calendar", "power", "wallpaper", "armoury"]

    property string view: "rest"
    property string ambient: ""
    property string screen: Compositor.focusedScreen
    property string osdKind: "volume" // volume | mic | brightness
    property bool hold: false         // pointer is over a ambient state

    readonly property bool polkit: Polkit.active
    onPolkitChanged: if (polkit) screen = Compositor.focusedScreen
    readonly property bool interactive: view !== "rest" || polkit
    readonly property string effective: polkit ? "polkit"
        : view !== "rest" ? view
        : ambient !== "" ? ambient
        : "rest"

    function open(name: string): void {
        if (!views.includes(name))
            return;
        screen = Compositor.focusedScreen;
        ambient = "";
        view = name;
    }

    function toggle(name: string): void {
        if (view === name)
            close();
        else
            open(name);
    }

    function close(): void {
        view = "rest";
    }

    function flashOsd(kind: string): void {
        osdKind = kind;
        if (view !== "rest")
            return;
        screen = Compositor.focusedScreen;
        ambient = "osd";
        osdTimer.restart();
    }

    function flashNotif(): void {
        if (view !== "rest" || ambient === "osd")
            return;
        screen = Compositor.focusedScreen;
        ambient = "notif";
        notifTimer.restart();
    }

    // Workspace switch: the resting pill briefly shows page dots and the
    // active one slides from the old workspace to the new.
    property int wsFrom: 0
    property int wsTo: 0
    property int lastWorkspace: 0

    Connections {
        target: Compositor
        function onWorkspaceChanged(): void {
            const ws = Compositor.workspace;
            const prev = root.lastWorkspace;
            root.lastWorkspace = ws;
            if (ws <= 0 || prev <= 0 || ws === prev)
                return;                      // startup, or a special workspace
            root.flashWorkspace(prev, ws);
        }
    }

    function flashWorkspace(from: int, to: int): void {
        if (view !== "rest" || ambient === "osd" || ambient === "notif")
            return;
        wsFrom = ambient === "workspace" ? wsTo : from;
        wsTo = to;
        screen = Compositor.focusedScreen;
        ambient = "workspace";
        wsTimer.restart();
    }

    Timer {
        id: wsTimer
        interval: 1100
        onTriggered: {
            if (root.hold)
                restart();
            else if (root.ambient === "workspace")
                root.ambient = "";
        }
    }

    function clearTransient(): void {
        ambient = "";
    }

    Component.onCompleted: lastWorkspace = Compositor.workspace

    Timer {
        id: osdTimer
        interval: Style.osdTimeout
        onTriggered: {
            if (root.hold)
                restart();
            else if (root.ambient === "osd")
                root.ambient = "";
        }
    }

    Timer {
        id: notifTimer
        interval: Style.notifTimeout
        onTriggered: {
            if (root.hold)
                restart();
            else if (root.ambient === "notif")
                root.ambient = "";
        }
    }
}
