import QtQuick
import Quickshell
import qs.config
import qs.services
import qs.components

// Armoury: the ROG Flow Z13's hardware controls (via the z13ctl daemon).
// Opened by the Armoury Crate key or the control centre's Armoury tile.
//   General – profile, lighting, charge limit, firmware toggles
//   Tuning  – power limits, fan curve, Curve Optimizer, GPU memory
Item {
    id: root

    property string page: "general"

    implicitWidth: 440
    implicitHeight: (Armoury.available ? column.implicitHeight : offline.implicitHeight) + 2 * Style.pad

    function activate(): void {
        Armoury.refresh();
    }

    // Temperatures, fans and GPU memory move; keep them live while open.
    Timer {
        running: root.visible && Armoury.available
        interval: 2000
        repeat: true
        onTriggered: Armoury.refresh()
    }

    // Tab switches pages; 1–4 pick a profile.
    Keys.onPressed: e => {
        const i = e.key - Qt.Key_1;
        if (e.key === Qt.Key_Tab || e.key === Qt.Key_Backtab) {
            page = page === "general" ? "tuning" : "general";
            e.accepted = true;
        } else if (i >= 0 && i < Armoury.profiles.length) {
            root.pickProfile(Armoury.profiles[i].id);
            e.accepted = true;
        }
    }

    // Custom re-applies saved tuning; with nothing saved yet, open the
    // Tuning page instead so there is something to make custom.
    function pickProfile(id: string): void {
        if (id === "custom" && !Armoury.hasCustom)
            page = "tuning";
        else
            Armoury.setProfile(id);
    }

    function gb(bytes: real): string {
        const g = bytes / 1073741824;
        return g >= 10 ? g.toFixed(0) : g.toFixed(1);
    }

    // The fan curve shown in the editor. The firmware's own curve can repeat
    // a temperature (which z13ctl rejects), so fall back to a fixed grid and
    // keep the firmware's speeds.
    function fanCurve(): var {
        const fp = Armoury.fanPoints ?? [];
        const ok = fp.length === 8 && fp.every((p, i) => i === 0 || p.temp > fp[i - 1].temp);
        if (ok)
            return fp.map(p => ({ temp: p.temp, pwm: p.pwm }));
        const grid = [40, 50, 60, 65, 70, 75, 80, 90];
        const pwm = fp.length === 8 ? fp.map(p => p.pwm) : [0, 26, 51, 77, 102, 140, 191, 255];
        return grid.map((t, i) => ({ temp: t, pwm: pwm[i] }));
    }

    // ── small building blocks ────────────────────────────────────────────
    component Stat: Row {
        property string icon
        property string value
        spacing: 3
        Icon {
            anchors.verticalCenter: parent.verticalCenter
            icon: parent.icon
            size: 14
            color: Colors.fgDim
        }
        Txt {
            anchors.verticalCenter: parent.verticalCenter
            text: parent.value
            font.pixelSize: Style.fontSm
            font.weight: Font.DemiBold
            font.features: ({ "tnum": 1 })
        }
    }

    component SectionLabel: Txt {
        font.pixelSize: Style.fontSm
        font.weight: Font.DemiBold
        color: Colors.fgDim
    }

    component Link: Txt {
        id: link
        signal clicked
        font.pixelSize: Style.fontXs
        font.weight: Font.DemiBold
        color: linkMouse.containsMouse ? Colors.fg : Colors.fgDim
        MouseArea {
            id: linkMouse
            anchors.fill: parent
            anchors.margins: -6
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: link.clicked()
        }
    }

    // Card header: label on the left, optional detail + action on the right.
    component CardHeader: Item {
        id: ch
        property string label
        property string detail
        property string action
        signal acted
        width: parent.width
        height: 18
        SectionLabel {
            anchors.left: parent.left
            anchors.leftMargin: 2
            anchors.verticalCenter: parent.verticalCenter
            text: ch.label
        }
        Row {
            anchors.right: parent.right
            anchors.rightMargin: 2
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10
            Txt {
                visible: ch.detail !== ""
                text: ch.detail
                font.pixelSize: Style.fontXs
                color: Colors.fgFaint
            }
            Link {
                visible: ch.action !== ""
                text: ch.action
                onClicked: ch.acted()
            }
        }
    }

    // Slider over an integer range that commits once the hand stops moving.
    component ValueSlider: Column {
        id: vs
        property string label
        property string icon
        property int from: 0
        property int to: 100
        property int value: 0
        property string unit: ""
        property bool invert: false   // larger magnitude to the right for negatives
        property var pending: null
        signal committed(int value)

        readonly property int shown: pending === null ? value : pending
        width: parent.width
        spacing: 6

        Item {
            width: parent.width
            height: 16
            Txt {
                anchors.left: parent.left
                anchors.leftMargin: 2
                text: vs.label
                font.pixelSize: Style.fontXs
                color: Colors.fgDim
            }
            Txt {
                anchors.right: parent.right
                anchors.rightMargin: 2
                text: vs.shown + vs.unit
                font.pixelSize: Style.fontXs
                font.weight: Font.DemiBold
                font.features: ({ "tnum": 1 })
            }
        }
        Slider {
            width: parent.width
            icon: vs.icon
            value: vs.invert ? (vs.to - vs.shown) / (vs.to - vs.from) : (vs.shown - vs.from) / (vs.to - vs.from)
            onMoved: v => {
                const span = vs.to - vs.from;
                vs.pending = vs.invert ? Math.round(vs.to - v * span) : Math.round(vs.from + v * span);
                settle.restart();
            }
        }
        Timer {
            id: settle
            interval: 450
            onTriggered: {
                const v = vs.pending;
                vs.pending = null;
                vs.committed(v);
            }
        }
    }

    component MemBar: Column {
        id: mb
        property string label
        property real used
        property real total
        property color tint: Colors.primary
        width: parent.width
        spacing: 6
        Item {
            width: parent.width
            height: 16
            Txt {
                anchors.left: parent.left
                anchors.leftMargin: 2
                text: mb.label
                font.pixelSize: Style.fontXs
                color: Colors.fgDim
            }
            Txt {
                anchors.right: parent.right
                anchors.rightMargin: 2
                text: root.gb(mb.used) + " / " + root.gb(mb.total) + " GB"
                font.pixelSize: Style.fontXs
                font.weight: Font.DemiBold
                font.features: ({ "tnum": 1 })
            }
        }
        Rectangle {
            width: parent.width
            height: 8
            radius: 4
            color: Colors.surface2
            Rectangle {
                width: mb.total > 0 ? Math.max(height, parent.width * Math.min(1, mb.used / mb.total)) : 0
                height: parent.height
                radius: 4
                color: mb.tint
                Behavior on width {
                    NumberAnimation { duration: 500; easing.type: Easing.OutCubic }
                }
            }
        }
    }

    Column {
        id: column
        visible: Armoury.available
        anchors.fill: parent
        anchors.margins: Style.pad
        spacing: Style.gap

        // ── header: title + live readouts ────────────────────────────────
        Item {
            width: parent.width
            height: 24

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    icon: "memory"
                    size: 18
                    fill: true
                }
                Txt {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Armoury"
                    font.family: Colors.fontRounded
                    font.weight: Font.Bold
                    font.pixelSize: Style.fontLg
                }
            }

            Row {
                anchors.right: parent.right
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                Stat {
                    icon: "device_thermostat"
                    value: Armoury.temperature > 0 ? Armoury.temperature + "°" : "—"
                }
                Stat {
                    icon: "mode_fan"
                    value: Armoury.fanRpm > 0 ? (Armoury.fanRpm / 1000).toFixed(1) + "k" : "Off"
                }
                Stat {
                    visible: Armoury.tdp > 0
                    icon: "bolt"
                    value: Armoury.tdp + " W"
                }
            }
        }

        Segmented {
            width: parent.width
            model: [
                { id: "general", label: "General" },
                { id: "tuning", label: "Tuning" }
            ]
            current: root.page
            onPicked: id => root.page = id
        }

        // ── General ──────────────────────────────────────────────────────
        Column {
            width: parent.width
            spacing: Style.gap
            visible: root.page === "general"

            Segmented {
                width: parent.width
                accent: true
                model: Armoury.profiles
                current: Armoury.profile
                onPicked: id => root.pickProfile(id)
            }

            // lighting
            Card {
                width: parent.width
                height: lighting.implicitHeight + 24

                Column {
                    id: lighting
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    Item {
                        width: parent.width
                        height: 20

                        SectionLabel {
                            anchors.left: parent.left
                            anchors.leftMargin: 2
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Lighting"
                        }

                        // brightness: off · low · medium · high
                        Row {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 4

                            Repeater {
                                model: 4
                                Rectangle {
                                    required property int index
                                    readonly property int level: Armoury.lightOn ? Armoury.lightLevel : 0
                                    width: 28
                                    height: 20
                                    radius: 10
                                    color: index === level ? Colors.surface3 : levelMouse.containsMouse ? Colors.surface2 : "transparent"
                                    Behavior on color {
                                        ColorAnimation { duration: Style.quick }
                                    }
                                    Icon {
                                        anchors.centerIn: parent
                                        icon: ["light_off", "brightness_low", "brightness_medium", "brightness_high"][parent.index]
                                        size: 15
                                        fill: parent.index === parent.level
                                        color: parent.index === parent.level ? Colors.fg : Colors.fgDim
                                    }
                                    MouseArea {
                                        id: levelMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: Armoury.setLightLevel(parent.index)
                                    }
                                }
                            }
                        }
                    }

                    // which LEDs a change goes to
                    Segmented {
                        width: parent.width
                        model: [
                            { id: "", label: "Both" },
                            { id: "keyboard", label: "Keyboard" },
                            { id: "lightbar", label: "Lightbar" }
                        ]
                        current: Armoury.lightZone
                        onPicked: id => Armoury.lightZone = id
                    }

                    // colour: z13ctl's named colours, or the rice palette
                    Item {
                        width: parent.width
                        height: 16

                        Txt {
                            anchors.left: parent.left
                            anchors.leftMargin: 2
                            anchors.verticalCenter: parent.verticalCenter
                            text: swatches.currentName
                            color: Colors.fgDim
                            font.pixelSize: Style.fontSm
                        }

                        Row {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 12

                            Repeater {
                                model: [
                                    { id: "vivid", label: "Colours" },
                                    { id: "palette", label: "Palette" }
                                ]
                                Txt {
                                    required property var modelData
                                    readonly property bool on: Armoury.swatchSet === modelData.id
                                    text: modelData.label
                                    font.pixelSize: Style.fontSm
                                    font.weight: on ? Font.DemiBold : Font.Normal
                                    color: on ? Colors.fg : setMouse.containsMouse ? Colors.fgDim : Colors.fgFaint
                                    Behavior on color {
                                        ColorAnimation { duration: Style.quick }
                                    }
                                    MouseArea {
                                        id: setMouse
                                        anchors.fill: parent
                                        anchors.margins: -4
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: Armoury.swatchSet = parent.modelData.id
                                    }
                                }
                            }
                        }
                    }

                    Grid {
                        id: swatches
                        width: parent.width
                        columns: 8
                        readonly property var palette: [
                            { name: "Foreground", hex: Colors.fg },
                            { name: "Accent", hex: Colors.primary },
                            { name: "Red", hex: Colors.red },
                            { name: "Orange", hex: Colors.orange },
                            { name: "Yellow", hex: Colors.yellow },
                            { name: "Cyan", hex: Colors.cyan },
                            { name: "Blue", hex: Colors.blue },
                            { name: "Magenta", hex: Colors.magenta }
                        ].map(c => ({ name: c.name, hex: c.hex.toString().slice(1).toUpperCase() }))
                        readonly property var colors: Armoury.swatchSet === "palette" ? palette : Armoury.vividColors
                        readonly property bool tinted: Armoury.lightMode !== "cycle" && Armoury.lightMode !== "rainbow"
                        readonly property string currentName: {
                            if (!Armoury.lightOn)
                                return "Off";
                            if (!tinted)
                                return Armoury.lightMode === "rainbow" ? "Rainbow" : "Colour cycle";
                            const c = Armoury.vividColors.concat(palette).find(c => c.hex === Armoury.lightColor);
                            return c ? c.name : "#" + Armoury.lightColor;
                        }
                        columnSpacing: (width - columns * 30) / (columns - 1)
                        rowSpacing: 8
                        opacity: Armoury.lightOn ? 1 : 0.4

                        Repeater {
                            model: swatches.colors

                            Item {
                                id: sw
                                required property var modelData
                                readonly property string hex: modelData.hex
                                readonly property bool on: swatches.tinted && Armoury.lightOn && hex === Armoury.lightColor
                                width: 30
                                height: 30

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 30
                                    height: 30
                                    radius: 15
                                    color: "transparent"
                                    border.width: 2
                                    border.color: sw.on ? Colors.fg : "transparent"
                                    Behavior on border.color {
                                        ColorAnimation { duration: Style.quick }
                                    }
                                }
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: sw.on ? 20 : swMouse.containsMouse ? 26 : 24
                                    height: width
                                    radius: width / 2
                                    color: "#" + sw.hex
                                    // dark swatches (teal, brown) need an edge on the black island
                                    border.width: 1
                                    border.color: Qt.alpha(Colors.fg, 0.08)
                                    Behavior on width {
                                        NumberAnimation { duration: Style.quick; easing.type: Easing.OutCubic }
                                    }
                                }
                                MouseArea {
                                    id: swMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Armoury.setLightColor(sw.hex)
                                }
                            }
                        }
                    }

                    Segmented {
                        width: parent.width
                        model: [
                            { id: "static", label: "Static" },
                            { id: "breathe", label: "Breathe" },
                            { id: "cycle", label: "Cycle" },
                            { id: "rainbow", label: "Rainbow" }
                        ]
                        current: Armoury.lightOn ? Armoury.lightMode : ""
                        onPicked: id => Armoury.setLightMode(id)
                    }
                }
            }

            // battery charge limit
            Card {
                width: parent.width
                height: battery.implicitHeight + 24

                Column {
                    id: battery
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    CardHeader {
                        label: "Charge Limit"
                        detail: Armoury.batteryLimit >= 100 ? "Charges to full" : "Stops at " + Armoury.batteryLimit + "% to protect the battery"
                    }

                    Segmented {
                        width: parent.width
                        model: [
                            { id: "60", label: "60%" },
                            { id: "80", label: "80%" },
                            { id: "100", label: "100%" }
                        ]
                        current: String(Armoury.batteryLimit)
                        onPicked: id => Armoury.setBatteryLimit(parseInt(id))
                    }
                }
            }

            // firmware toggles
            Grid {
                width: parent.width
                columns: 2
                columnSpacing: Style.gap
                readonly property real cell: (width - columnSpacing) / 2

                Tile {
                    width: parent.cell
                    icon: "speed"
                    title: "Overdrive"
                    subtitle: Armoury.panelOverdrive ? "Faster pixels" : "Off"
                    active: Armoury.panelOverdrive
                    onClicked: Armoury.setPanelOverdrive(!Armoury.panelOverdrive)
                }
                Tile {
                    width: parent.cell
                    icon: Armoury.bootSound ? "volume_up" : "volume_off"
                    title: "Boot Sound"
                    subtitle: Armoury.bootSound ? "On" : "Silent"
                    active: Armoury.bootSound
                    onClicked: Armoury.setBootSound(!Armoury.bootSound)
                }
            }
        }

        // ── Tuning ───────────────────────────────────────────────────────
        Column {
            width: parent.width
            spacing: Style.gap
            visible: root.page === "tuning"

            // power limits
            Card {
                width: parent.width
                height: power.implicitHeight + 24

                Column {
                    id: power
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    CardHeader {
                        label: "Power Limits"
                        detail: Armoury.custom ? "" : "Managed by " + Armoury.profileLabel
                        action: Armoury.custom ? "Reset" : ""
                        onActed: Armoury.resetTdp()
                    }
                    ValueSlider {
                        label: "Sustained"
                        icon: "bolt"
                        from: Armoury.tdpMin
                        to: Armoury.tdpMaxSafe
                        value: Armoury.tdp
                        unit: " W"
                        onCommitted: v => Armoury.setTdp(v, Math.max(v, Armoury.tdpBoost))
                    }
                    ValueSlider {
                        label: "Boost"
                        icon: "electric_bolt"
                        from: Armoury.tdpMin
                        to: Armoury.tdpMax
                        value: Armoury.tdpBoost
                        unit: " W"
                        onCommitted: v => Armoury.setTdp(Math.min(Armoury.tdp, v), v)
                    }
                }
            }

            // fan curve
            Card {
                width: parent.width
                height: fans.implicitHeight + 24

                Column {
                    id: fans
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    CardHeader {
                        label: "Fan Curve"
                        detail: Armoury.fanMode === 1 ? "Custom" : Armoury.fanMode === 0 ? "Full speed" : "Automatic"
                        action: Armoury.fanMode === 1 ? "Automatic" : ""
                        onActed: Armoury.resetFanCurve()
                    }
                    FanCurve {
                        id: curve
                        width: parent.width
                        height: 136
                        liveTemp: Armoury.temperature
                        onEdited: pts => Armoury.setFanCurve(pts)
                        Component.onCompleted: points = root.fanCurve()
                        Connections {
                            target: Armoury
                            function onFanPointsChanged() {
                                if (curve.dragging < 0)
                                    curve.points = root.fanCurve();
                            }
                        }
                    }
                }
            }

            // Curve Optimizer
            Card {
                width: parent.width
                height: uv.implicitHeight + 24

                Column {
                    id: uv
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    CardHeader {
                        label: "Undervolt"
                        detail: !Armoury.undervoltAvailable ? "Needs the ryzen_smu module"
                            : Armoury.undervoltActive ? "Curve Optimizer active" : "Stock voltage"
                        action: Armoury.undervoltActive ? "Reset" : ""
                        onActed: Armoury.setUndervolt(0)
                    }
                    ValueSlider {
                        visible: Armoury.undervoltAvailable
                        label: "All-core offset"
                        icon: "bolt"
                        from: -40
                        to: 0
                        invert: true
                        value: Armoury.undervolt
                        onCommitted: v => Armoury.setUndervolt(v)
                    }
                }
            }

            // unified GPU memory
            Card {
                width: parent.width
                height: mem.implicitHeight + 24

                Column {
                    id: mem
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    CardHeader {
                        label: "Graphics Memory"
                        detail: "Shared memory is borrowed from RAM on demand"
                    }
                    MemBar {
                        label: "Dedicated"
                        used: Armoury.vramUsed
                        total: Armoury.vramTotal
                        tint: Colors.fg
                    }
                    MemBar {
                        label: "Shared"
                        used: Armoury.gttUsed
                        total: Armoury.gttTotal
                    }
                }
            }
        }
    }

    // ── daemon unreachable ───────────────────────────────────────────────
    Column {
        id: offline
        visible: !Armoury.available
        anchors.centerIn: parent
        width: parent.width - 2 * Style.pad
        spacing: 6

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 36
            height: 36
            radius: 18
            color: Colors.surface2
            Icon {
                anchors.centerIn: parent
                icon: "memory"
                size: 18
                color: Colors.fgDim
            }
        }
        Txt {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Armoury unavailable"
            font.weight: Font.DemiBold
        }
        Txt {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "The z13ctl daemon isn't running"
            font.pixelSize: Style.fontSm
            color: Colors.fgDim
        }
        Item { width: 1; height: 4 }
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: retry.implicitWidth + 28
            height: 30
            radius: 15
            color: retryMouse.containsMouse ? Colors.surface3 : Colors.surface2
            Txt {
                id: retry
                anchors.centerIn: parent
                text: "Try again"
                font.pixelSize: Style.fontSm
                font.weight: Font.DemiBold
            }
            MouseArea {
                id: retryMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Armoury.refresh()
            }
        }
    }
}
