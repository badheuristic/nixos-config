import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.config
import qs.services

// One island per monitor. Expanded states only appear on the monitor that
// was focused when they were opened; the others stay at rest.
Scope {
    id: scope

    required property ShellScreen modelData

    readonly property bool mine: Closs.screen === modelData.name
    readonly property string current: mine ? Closs.effective : "rest"
    readonly property bool expanded: current !== "rest"
    readonly property bool interactive: mine && Closs.interactive
    readonly property bool modal: interactive && ["launcher", "clipboard", "power", "wallpaper", "polkit"].includes(current)
    // Over fullscreen windows only the resting notch retracts; popups (osd,
    // notif) and summoned views still drop down, then leave again.
    readonly property bool hidden: (current === "rest" || current === "workspace") && Compositor.hasFullscreen(modelData)

    // ── Scrim: dims the desktop and catches clicks outside the island ────
    PanelWindow {
        id: scrim

        screen: scope.modelData
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "closs-scrim"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        visible: scope.interactive || shade.opacity > 0

        Rectangle {
            id: shade
            anchors.fill: parent
            color: "black"
            opacity: !scope.interactive ? 0 : scope.modal ? Style.scrimOpacity : 0.12

            Behavior on opacity {
                NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: scope.interactive
            onClicked: if (!Closs.polkit) Closs.close()
        }
    }

    // ── The island ───────────────────────────────────────────────────────
    PanelWindow {
        id: win

        screen: scope.modelData
        anchors {
            top: true
            left: true
            right: true
        }
        // full height so tall views (control centre) are never clipped;
        // the mask keeps everything but the island click-through
        implicitHeight: scope.modelData.height
        color: "transparent"
        exclusiveZone: Style.notch ? Style.restHeight : Style.restHeight + Style.floatGap
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "closs"
        WlrLayershell.keyboardFocus: scope.interactive ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        // Only the island itself takes input; the rest of the surface is
        // click-through.
        mask: Region {
            item: hit
        }

        Item {
            id: hit
            x: body.x - Style.flare
            y: body.y
            width: body.width + 2 * Style.flare
            height: body.height
        }

        Item {
            id: body

            readonly property Item slot: views.slotFor(scope.current)
            // the resting pill is fully round: a 14px radius on a 32px body
            // left a short flat edge where the two corners should meet
            property real radius: scope.expanded ? Style.radius : Style.notch ? Style.restRadius : Style.restHeight / 2

            width: Math.max(slot ? slot.implicitWidth : 0, 80)
            height: Math.max(slot ? slot.implicitHeight : 0, Style.restHeight)
            x: Math.round((win.width - width) / 2)
            y: scope.hidden ? -height - Style.flare - 12 : Style.notch ? 0 : Style.floatGap

            Behavior on width {
                NumberAnimation { duration: Style.morphDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Style.morphCurve }
            }
            Behavior on height {
                NumberAnimation { duration: Style.morphDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Style.morphCurve }
            }
            Behavior on y {
                NumberAnimation { duration: 380; easing.type: Easing.OutCubic }
            }
            Behavior on radius {
                NumberAnimation { duration: Style.morphDuration; easing.type: Easing.OutCubic }
            }

            // Silhouette + soft shadow
            Item {
                id: silhouette
                anchors.fill: parent
                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: "black"
                    shadowBlur: 0.9
                    shadowOpacity: scope.expanded ? 0.55 : 0.25
                    shadowVerticalOffset: 6
                    autoPaddingEnabled: true
                }

                NotchShape {
                    visible: Style.notch
                    x: -f
                    w: body.width
                    h: body.height
                    r: body.radius
                    flare: Style.flare
                    color: Colors.black
                }

                Rectangle {
                    visible: !Style.notch
                    anchors.fill: parent
                    radius: Math.min(body.radius, height / 2)
                    color: Colors.black
                }
            }

            ClippingRectangle {
                anchors.fill: parent
                radius: Math.min(body.radius, height / 2)
                color: "transparent"

                FocusScope {
                    id: views

                    anchors.fill: parent
                    focus: true

                    function slotFor(name: string): Item {
                        for (const c of children)
                            if (c.name === name)
                                return c;
                        return restSlot;
                    }

                    Keys.onEscapePressed: {
                        if (Closs.polkit)
                            Polkit.cancel();
                        else
                            Closs.close();
                    }

                    ViewSlot {
                        id: restSlot
                        name: "rest"
                        current: scope.current
                        content: Component { RestView {} }
                    }
                    ViewSlot {
                        name: "dashboard"
                        current: scope.current
                        content: Component { DashboardView {} }
                    }
                    ViewSlot {
                        name: "launcher"
                        current: scope.current
                        content: Component { LauncherView {} }
                    }
                    ViewSlot {
                        name: "clipboard"
                        current: scope.current
                        content: Component { ClipboardView {} }
                    }
                    ViewSlot {
                        name: "control"
                        current: scope.current
                        content: Component { ControlView {} }
                    }
                    ViewSlot {
                        name: "calendar"
                        current: scope.current
                        content: Component { CalendarView {} }
                    }
                    ViewSlot {
                        name: "power"
                        current: scope.current
                        content: Component { PowerView {} }
                    }
                    ViewSlot {
                        name: "wallpaper"
                        current: scope.current
                        content: Component { WallpaperView {} }
                    }
                    ViewSlot {
                        name: "armoury"
                        current: scope.current
                        content: Component { ArmouryView {} }
                    }
                    ViewSlot {
                        name: "tray"
                        current: scope.current
                        content: Component { TrayView {} }
                    }
                    ViewSlot {
                        name: "polkit"
                        current: scope.current
                        content: Component { PolkitView {} }
                    }
                    ViewSlot {
                        name: "workspace"
                        current: scope.current
                        content: Component { WorkspaceView {} }
                    }
                    ViewSlot {
                        name: "osd"
                        current: scope.current
                        content: Component { OsdView {} }
                    }
                    ViewSlot {
                        name: "notif"
                        current: scope.current
                        content: Component { NotifView {} }
                    }
                }
            }

            HoverHandler {
                onHoveredChanged: {
                    if (scope.mine)
                        Closs.hold = hovered;
                }
            }
        }
    }
}
