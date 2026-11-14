import QtQuick
import qs.config
import qs.services
import qs.components

Item {
    id: root

    property int offset: 0 // months from now
    readonly property date month: new Date(Time.now.getFullYear(), Time.now.getMonth() + offset, 1)
    // Monday-first grid start
    readonly property date gridStart: {
        const lead = (month.getDay() + 6) % 7;
        return new Date(month.getFullYear(), month.getMonth(), 1 - lead);
    }

    implicitWidth: 340
    implicitHeight: column.implicitHeight + 2 * Style.pad

    function activate(): void {
        offset = 0;
    }

    Keys.onPressed: e => {
        if (e.key === Qt.Key_Left || e.key === Qt.Key_H) {
            offset--;
            e.accepted = true;
        } else if (e.key === Qt.Key_Right || e.key === Qt.Key_L) {
            offset++;
            e.accepted = true;
        } else if (e.key === Qt.Key_T || e.key === Qt.Key_Home) {
            offset = 0;
            e.accepted = true;
        }
    }

    WheelHandler {
        onWheel: e => root.offset += e.angleDelta.y > 0 ? -1 : 1
    }

    Column {
        id: column
        anchors.fill: parent
        anchors.margins: Style.pad
        spacing: 8

        Item {
            width: parent.width
            height: 30

            CircleButton {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                implicitWidth: 28
                icon: "chevron_left"
                onClicked: root.offset--
            }
            Txt {
                anchors.centerIn: parent
                text: Qt.formatDate(root.month, "MMMM yyyy")
                font.weight: Font.DemiBold
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.offset = 0
                }
            }
            CircleButton {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                implicitWidth: 28
                icon: "chevron_right"
                onClicked: root.offset++
            }
        }

        Grid {
            columns: 7
            width: parent.width
            readonly property real cell: width / 7

            Repeater {
                model: ["M", "T", "W", "T", "F", "S", "S"]
                Txt {
                    required property string modelData
                    width: parent.cell
                    height: 22
                    horizontalAlignment: Text.AlignHCenter
                    text: modelData
                    font.pixelSize: Style.fontXs
                    font.weight: Font.DemiBold
                    color: Colors.fgFaint
                }
            }

            Repeater {
                model: 42
                Item {
                    id: cellItem
                    required property int index
                    readonly property date d: new Date(root.gridStart.getFullYear(), root.gridStart.getMonth(), root.gridStart.getDate() + index)
                    readonly property bool inMonth: d.getMonth() === root.month.getMonth()
                    readonly property bool today: d.toDateString() === Time.now.toDateString()

                    width: parent.cell
                    height: 36

                    Rectangle {
                        anchors.centerIn: parent
                        width: 32
                        height: 32
                        radius: 16
                        color: cellItem.today ? Colors.primary : cellMouse.containsMouse ? Colors.surface2 : "transparent"
                    }
                    Txt {
                        anchors.centerIn: parent
                        text: cellItem.d.getDate()
                        font.pixelSize: Style.fontSm
                        font.weight: cellItem.today ? Font.Bold : Font.Normal
                        color: cellItem.today ? Colors.primaryFg : cellItem.inMonth ? Colors.fg : Colors.fgFaint
                    }
                    MouseArea {
                        id: cellMouse
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                }
            }
        }
    }
}
