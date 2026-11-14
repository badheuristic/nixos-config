pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Geometry and motion tokens. Colours and fonts live in Colors.qml,
// which is generated from theme.nix.
Singleton {
    // ── Island ──────────────────────────────────────────────────────────
    // true: the island hangs from the top edge like a notch (flat top,
    // concave "flares" into the bezel). false: a floating pill.
    // Toggled from the control centre and remembered across restarts.
    property bool notch: true
    function setNotch(on: bool): void {
        notch = on;
        shapeStore.setText(on ? "notch" : "pill");
    }
    readonly property int flare: 12          // notch flare radius
    readonly property int floatGap: 8         // gap above the pill when !notch
    readonly property int restHeight: 32
    readonly property int restRadius: 14
    readonly property int radius: 28          // expanded island corner radius
    readonly property int pad: 16             // inner padding of expanded views

    // ── Cards & controls ────────────────────────────────────────────────
    readonly property int cardRadius: 18
    readonly property int controlRadius: 12
    readonly property int gap: 10
    readonly property int rowHeight: 48

    // ── Type scale ──────────────────────────────────────────────────────
    readonly property int fontXs: 11
    readonly property int fontSm: 12
    readonly property int fontMd: 14
    readonly property int fontLg: 17
    readonly property int fontXl: 26

    // ── Motion ──────────────────────────────────────────────────────────
    // Morph: a gentle spring-like overshoot, the island "settles" into shape.
    readonly property int morphDuration: 480
    readonly property var morphCurve: [0.32, 1.22, 0.42, 1.0, 1.0, 1.0]
    // Content cross-fade
    readonly property int fadeIn: 240
    readonly property int fadeOut: 110
    readonly property int fadeDelay: 90
    // Small UI feedback (hover, press, toggles)
    readonly property int quick: 160
    readonly property var standardCurve: [0.2, 0.0, 0.0, 1.0, 1.0, 1.0]

    // ── Behaviour ───────────────────────────────────────────────────────
    readonly property int osdTimeout: 1400
    readonly property int notifTimeout: 5000
    readonly property real scrimOpacity: 0.32

    FileView {
        id: shapeStore
        path: Quickshell.statePath("island-shape")
        printErrors: false
        onLoaded: notch = text().trim() !== "pill"
    }
}
