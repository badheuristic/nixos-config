import QtQuick
import qs.config
import qs.services
import qs.components

// Clicking the resting island: mirrored media card ↔ clock card.
Item {
    id: root

    implicitWidth: 600
    implicitHeight: 120 + 2 * Style.pad

    Row {
        anchors.fill: parent
        anchors.margins: Style.pad
        spacing: Style.gap

        MediaCard {
            width: (parent.width - parent.spacing) / 2
            height: parent.height
        }

        Card {
            width: (parent.width - parent.spacing) / 2
            height: parent.height

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Closs.open("calendar")
            }

            Column {
                anchors.centerIn: parent
                spacing: 6

                Txt {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Time.hhmm
                    font.family: Colors.fontRounded
                    font.pixelSize: 38
                    font.weight: Font.Bold
                    font.features: ({ "tnum": 1 })
                }

                // week strip centred on today
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 4

                    Repeater {
                        model: 7
                        Column {
                            id: day
                            required property int index
                            readonly property date d: new Date(Time.now.getFullYear(), Time.now.getMonth(), Time.now.getDate() + index - 3)
                            readonly property bool today: index === 3
                            spacing: 2
                            width: 26

                            Txt {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: Qt.formatDate(day.d, "ddd").slice(0, 1)
                                font.pixelSize: 9
                                font.weight: Font.DemiBold
                                color: day.today ? Colors.fg : Colors.fgFaint
                            }
                            Rectangle {
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: 22
                                height: 22
                                radius: 11
                                color: day.today ? Colors.primary : "transparent"
                                Txt {
                                    anchors.centerIn: parent
                                    text: day.d.getDate()
                                    font.pixelSize: Style.fontXs
                                    font.weight: day.today ? Font.Bold : Font.Normal
                                    color: day.today ? Colors.primaryFg : Colors.fgDim
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
