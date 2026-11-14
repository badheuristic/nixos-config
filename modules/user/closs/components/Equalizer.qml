import QtQuick
import qs.config

// Tiny "now playing" bars for the resting island.
Row {
    id: root

    property bool playing: false
    property color color: Colors.primary
    property int bars: 4

    spacing: 2
    height: 14

    Repeater {
        model: root.bars

        Rectangle {
            id: bar
            required property int index
            property real level: 0.3

            width: 3
            radius: 1.5
            anchors.bottom: parent.bottom
            height: Math.max(3, root.height * (root.playing ? level : 0.2))
            color: root.color

            Behavior on height {
                NumberAnimation { duration: 180; easing.type: Easing.OutQuad }
            }

            Timer {
                running: root.playing && root.visible
                repeat: true
                interval: 170 + bar.index * 37
                onTriggered: bar.level = 0.25 + Math.random() * 0.75
            }
        }
    }
}
