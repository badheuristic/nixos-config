import QtQuick
import qs.config

// Eight-point fan curve editor. Temperatures sit on a fixed grid; drag a
// point up or down to change fan speed. Neighbours are pushed along so the
// curve never decreases (the firmware rejects that).
Item {
    id: root

    property var points: []         // [{ temp, pwm (0–255) }] × 8
    property real liveTemp: 0       // current APU temperature, drawn as a marker
    property bool enabled: true
    property int dragging: -1
    signal edited(var points)

    readonly property real tMin: 30
    readonly property real tMax: 100
    readonly property real padX: 10
    readonly property real plotW: width - 2 * padX
    readonly property real plotH: height - 18   // room for temperature labels

    function px(t: real): real {
        return padX + (t - tMin) / (tMax - tMin) * plotW;
    }
    function py(pwm: real): real {
        return plotH - pwm / 255 * (plotH - 8) - 4;
    }

    function drag(i: int, y: real): void {
        const v = Math.round(Math.max(0, Math.min(255, (plotH - 4 - y) / (plotH - 8) * 255)));
        const next = points.map(p => ({ temp: p.temp, pwm: p.pwm }));
        next[i].pwm = v;
        for (let j = 0; j < i; j++)
            next[j].pwm = Math.min(next[j].pwm, v);
        for (let j = i + 1; j < next.length; j++)
            next[j].pwm = Math.max(next[j].pwm, v);
        points = next;
    }

    onPointsChanged: canvas.requestPaint()
    onWidthChanged: canvas.requestPaint()
    opacity: enabled ? 1 : 0.45

    // gridlines at 25 / 50 / 75 / 100 %
    Repeater {
        model: 4
        Rectangle {
            required property int index
            x: root.padX
            width: root.plotW
            y: root.py((index + 1) * 255 / 4)
            height: 1
            color: Colors.surface2
        }
    }

    // live temperature marker
    Rectangle {
        visible: root.liveTemp > root.tMin && root.liveTemp < root.tMax
        x: root.px(root.liveTemp)
        width: 1
        height: root.plotH
        color: Colors.fgFaint
        Behavior on x {
            NumberAnimation { duration: 600; easing.type: Easing.OutCubic }
        }
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            const pts = root.points;
            if (pts.length < 2)
                return;
            const xy = pts.map(p => [root.px(p.temp), root.py(p.pwm)]);
            // soft fill under the curve
            const grad = ctx.createLinearGradient(0, 0, 0, root.plotH);
            grad.addColorStop(0, Qt.alpha(Colors.primary, 0.28));
            grad.addColorStop(1, Qt.alpha(Colors.primary, 0.0));
            ctx.beginPath();
            ctx.moveTo(xy[0][0], root.plotH);
            for (const [x, y] of xy)
                ctx.lineTo(x, y);
            ctx.lineTo(xy[xy.length - 1][0], root.plotH);
            ctx.closePath();
            ctx.fillStyle = grad;
            ctx.fill();
            // the curve
            ctx.beginPath();
            ctx.moveTo(xy[0][0], xy[0][1]);
            for (const [x, y] of xy)
                ctx.lineTo(x, y);
            ctx.lineWidth = 2;
            ctx.lineJoin = "round";
            ctx.strokeStyle = Colors.primary;
            ctx.stroke();
        }
    }

    Repeater {
        model: root.points.length

        Item {
            id: handle
            required property int index
            readonly property var point: root.points[index] ?? { temp: 0, pwm: 0 }
            readonly property bool active: root.dragging === index || mouse.containsMouse

            x: root.px(point.temp) - width / 2
            y: root.py(point.pwm) - height / 2
            width: 22
            height: 22

            Rectangle {
                anchors.centerIn: parent
                width: handle.active ? 14 : 10
                height: width
                radius: width / 2
                color: Colors.fg
                border.width: 2
                border.color: Colors.primary
                Behavior on width {
                    NumberAnimation { duration: Style.quick; easing.type: Easing.OutCubic }
                }
            }

            // speed bubble while hovering / dragging
            Rectangle {
                visible: handle.active
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.top
                anchors.bottomMargin: 2
                width: bubble.implicitWidth + 12
                height: 18
                radius: 9
                color: Colors.surface3
                Txt {
                    id: bubble
                    anchors.centerIn: parent
                    text: Math.round(handle.point.pwm / 2.55) + "%"
                    font.pixelSize: Style.fontXs
                    font.weight: Font.DemiBold
                    font.features: ({ "tnum": 1 })
                }
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                enabled: root.enabled
                hoverEnabled: true
                preventStealing: true
                cursorShape: Qt.SizeVerCursor
                onPressed: root.dragging = handle.index
                onPositionChanged: e => {
                    if (pressed)
                        root.drag(handle.index, mapToItem(root, e.x, e.y).y);
                }
                onReleased: {
                    root.dragging = -1;
                    root.edited(root.points);
                }
            }
        }
    }

    // temperature labels
    Repeater {
        model: root.points.length
        Txt {
            required property int index
            readonly property var point: root.points[index] ?? { temp: 0 }
            x: root.px(point.temp) - width / 2
            y: root.plotH + 4
            text: point.temp + "°"
            font.pixelSize: 10
            font.features: ({ "tnum": 1 })
            color: Colors.fgFaint
        }
    }
}
