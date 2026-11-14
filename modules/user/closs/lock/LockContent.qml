import QtQuick
import QtQuick.Effects
import Quickshell
import qs.config
import qs.services
import qs.components
import qs.island

FocusScope {
    id: root

    property var lock: null   // LockScreen scope (buffer/busy/failed/...)
    property var screen: null

    readonly property int length: lock?.buffer.length ?? 0
    readonly property bool typing: length > 0 || (lock?.busy ?? false)

    focus: true
    Component.onCompleted: forceActiveFocus()

    Keys.onPressed: e => {
        if (!root.lock)
            return;
        if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter)
            root.lock.submit();
        else if (e.key === Qt.Key_Backspace)
            (e.modifiers & Qt.ControlModifier) ? root.lock.clear() : root.lock.backspace();
        else if (e.key === Qt.Key_Escape)
            root.lock.clear();
        else if (e.text !== "" && e.text.charCodeAt(0) >= 32)
            root.lock.type(e.text);
        e.accepted = true;
    }

    // ── Background: the live wallpaper, blurred and dimmed ──────────────
    Image {
        id: wall
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        source: Wallpapers.current === "" ? "" : "file://" + Wallpapers.current
        sourceSize.width: Math.max(1, root.width / 2)
        sourceSize.height: Math.max(1, root.height / 2)
        visible: false
    }
    MultiEffect {
        anchors.fill: parent
        source: wall
        blurEnabled: true
        blur: 1.0
        blurMax: 64
        saturation: -0.1
        brightness: -0.08
    }
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.35) }
            GradientStop { position: 0.5; color: Qt.rgba(0, 0, 0, 0.10) }
            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.45) }
        }
    }

    // fade in
    opacity: 0
    NumberAnimation on opacity {
        from: 0
        to: 1
        duration: 350
        easing.type: Easing.OutCubic
    }

    // ── Status (top right) ──────────────────────────────────────────────
    Row {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 18
        spacing: 8
        opacity: 0.8
        Icon {
            icon: Net.icon
            size: 16
            fill: true
        }
        Icon {
            visible: Battery.present
            icon: Battery.charging ? "battery_charging_full" : "battery_full"
            size: 16
            fill: true
        }
        Txt {
            visible: Battery.present
            text: Math.round(Battery.level * 100) + "%"
            font.pixelSize: Style.fontSm
        }
    }

    // ── The island, now holding the password ────────────────────────────
    Item {
        id: island

        readonly property real w: root.typing ? Math.max(120, Math.min(root.length, 24) * 14 + 56) : 72
        readonly property real h: Style.restHeight + (root.typing ? 6 : 0)

        anchors.horizontalCenter: parent.horizontalCenter
        y: Style.notch ? 0 : Style.floatGap
        width: w
        height: h

        Behavior on width {
            NumberAnimation { duration: Style.morphDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Style.morphCurve }
        }
        Behavior on height {
            NumberAnimation { duration: Style.morphDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: Style.morphCurve }
        }

        transform: Translate {
            id: shakeOffset
        }

        Connections {
            target: root.lock
            function onShake() {
                shakeAnim.restart();
            }
        }

        SequentialAnimation {
            id: shakeAnim
            NumberAnimation { target: shakeOffset; property: "x"; to: -14; duration: 50 }
            NumberAnimation { target: shakeOffset; property: "x"; to: 12; duration: 70 }
            NumberAnimation { target: shakeOffset; property: "x"; to: -8; duration: 60 }
            NumberAnimation { target: shakeOffset; property: "x"; to: 5; duration: 60 }
            NumberAnimation { target: shakeOffset; property: "x"; to: 0; duration: 50 }
        }

        NotchShape {
            visible: Style.notch
            x: -f
            w: island.width
            h: island.height
            r: Style.restRadius
            flare: Style.flare
            color: Colors.black
        }
        Rectangle {
            visible: !Style.notch
            anchors.fill: parent
            radius: height / 2
            color: Colors.black
        }

        Icon {
            anchors.centerIn: parent
            visible: !root.typing
            icon: "lock"
            fill: true
            size: 16
            color: root.lock?.failed ? Colors.red : Colors.fg
        }

        Row {
            anchors.centerIn: parent
            visible: root.typing
            spacing: 6

            Repeater {
                model: Math.min(root.length, 24)
                Rectangle {
                    required property int index
                    width: 8
                    height: 8
                    radius: 4
                    color: Colors.fg
                    opacity: root.lock?.busy ? 0.35 + 0.65 * Math.abs(Math.sin((pulse.t + index * 0.35))) : 1
                    scale: 0
                    Component.onCompleted: scale = 1
                    Behavior on scale {
                        NumberAnimation { duration: 160; easing.type: Easing.OutBack }
                    }
                }
            }
        }

        QtObject {
            id: pulse
            property real t: 0
        }
        NumberAnimation {
            target: pulse
            property: "t"
            running: root.lock?.busy ?? false
            from: 0
            to: Math.PI * 2
            duration: 1200
            loops: Animation.Infinite
        }
    }

    // ── Date & clock ────────────────────────────────────────────────────
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height * 0.13
        spacing: -12

        Txt {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Time.longDate
            font.pixelSize: 24
            font.weight: Font.DemiBold
            color: Qt.rgba(1, 1, 1, 0.85)
        }
        Txt {
            id: bigClock
            anchors.horizontalCenter: parent.horizontalCenter
            text: Time.hhmm
            font.family: Colors.fontRounded
            font.pixelSize: Math.round(root.height * 0.15)
            font.weight: Font.Black
            font.features: ({ "tnum": 1 })
            color: Qt.rgba(1, 1, 1, 0.92)
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "black"
                shadowOpacity: 0.25
                shadowBlur: 1.0
                shadowVerticalOffset: 4
            }
        }
    }

    // ── User ────────────────────────────────────────────────────────────
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.height * 0.1
        spacing: 10

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 64
            height: 64
            radius: 32
            color: Qt.rgba(1, 1, 1, 0.14)

            RoundedImage {
                id: face
                anchors.fill: parent
                radius: 32
                color: "transparent"
                sourceSize: 128
                source: "file://" + (Quickshell.env("HOME") ?? "") + "/.face"
            }
            Icon {
                anchors.centerIn: parent
                visible: face.status !== Image.Ready
                icon: "person"
                fill: true
                size: 34
                color: Qt.rgba(1, 1, 1, 0.85)
            }
        }
        Txt {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Session.user
            font.pixelSize: Style.fontLg
            font.weight: Font.DemiBold
        }
        Txt {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.lock?.busy ? "Checking…"
                : root.lock?.failed ? "Incorrect password"
                : root.typing ? "Press Enter to unlock"
                : "Type your password to unlock"
            font.pixelSize: Style.fontSm
            color: root.lock?.failed ? Colors.red : Qt.rgba(1, 1, 1, 0.65)
        }
    }
}
