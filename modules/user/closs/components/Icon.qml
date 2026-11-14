import QtQuick
import qs.config

// Material Symbols glyph. `fill` switches the variable FILL axis, which is
// how toggles read as "on" vs "off".
Text {
    id: root

    property string icon: ""
    property bool fill: false
    property real size: 20
    property int weight: 400

    text: icon
    color: Colors.fg
    font.family: Colors.fontIcons
    font.pixelSize: size
    font.variableAxes: ({
            "FILL": root.fill ? 1 : 0,
            "wght": root.weight,
            "GRAD": 0,
            "opsz": Math.max(20, Math.min(48, root.size))
        })
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    Behavior on color {
        ColorAnimation { duration: Style.quick }
    }
}
