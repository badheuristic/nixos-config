import QtQuick
import qs.config
import qs.services

// Workspace switch: page dots, iOS style. The active dot is a short pill
// that slides (and stretches mid-flight) from the old workspace to the new.
Item {
    id: root

    readonly property var existing: Compositor.workspaces
    readonly property int count: Math.min(10, Math.max(5, Closs.wsTo, Closs.wsFrom, ...existing))

    readonly property int dot: 6
    readonly property int gap: 9
    readonly property int pillW: 18

    // x of slot i (1-based); dots after the pill shift right by its extra
    // width, easing over as it passes so the row reflows smoothly
    function slotX(i: real): real {
        return (i - 1) * (dot + gap);
    }

    property real pos: Closs.wsFrom > 0 ? Closs.wsFrom : Closs.wsTo
    Behavior on pos {
        NumberAnimation { duration: 520; easing.type: Easing.BezierSpline; easing.bezierCurve: Style.morphCurve }
    }
    // start once the dots have faded in, so the slide is seen whole
    Timer {
        running: true
        interval: Style.fadeDelay + 60
        onTriggered: root.pos = Closs.wsTo
    }
    Connections {
        target: Closs
        function onWsToChanged(): void { root.pos = Closs.wsTo; }
    }

    // a little stretch while travelling, like a drop of ink
    readonly property real travel: Math.abs(pos - Math.round(pos))
    readonly property real stretch: Math.min(1, travel * 2.4)

    implicitWidth: row.width + 44
    implicitHeight: Style.restHeight

    Item {
        id: row
        anchors.centerIn: parent
        anchors.verticalCenterOffset: Style.notch ? -1 : 0
        width: root.slotX(root.count) + root.dot + (root.pillW - root.dot)
        height: root.dot

        Repeater {
            model: root.count
            Rectangle {
                required property int index
                readonly property int ws: index + 1
                // dots past the pill make room for its extra width
                x: root.slotX(ws) + Math.max(0, Math.min(1, ws - root.pos)) * (root.pillW - root.dot)
                width: root.dot
                height: root.dot
                radius: root.dot / 2
                color: root.existing.includes(ws) ? Colors.fgDim : Colors.surface3
                opacity: Math.min(1, Math.abs(ws - root.pos) * 1.5)
            }
        }

        // the active pill
        Rectangle {
            readonly property real baseX: root.slotX(root.pos)
            x: baseX - root.stretch * 6
            width: root.pillW + root.stretch * 12
            height: root.dot
            radius: root.dot / 2
            color: Colors.primary
        }
    }
}
