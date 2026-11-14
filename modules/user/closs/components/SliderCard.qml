import QtQuick
import qs.config

// Labelled slider inside a card, e.g. "Display" / "Sound".
Card {
    id: root

    property string label: ""
    property string icon: ""
    property real value: 0
    property bool showMore: true
    signal moved(real value)
    signal more

    implicitHeight: 76

    Txt {
        anchors.left: parent.left
        anchors.leftMargin: 14
        anchors.top: parent.top
        anchors.topMargin: 10
        text: root.label
        font.pixelSize: Style.fontSm
        font.weight: Font.DemiBold
        color: Colors.fgDim
    }

    CircleButton {
        visible: root.showMore
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.top: parent.top
        anchors.topMargin: 6
        implicitWidth: 22
        iconSize: 16
        icon: "chevron_right"
        tint: Colors.fgDim
        onClicked: root.more()
    }

    Slider {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 10
        icon: root.icon
        value: root.value
        onMoved: v => root.moved(v)
    }
}
