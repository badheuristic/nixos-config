import QtQuick
import Quickshell.Widgets
import qs.config

ClippingRectangle {
    id: root

    property alias source: img.source
    property alias status: img.status
    property int sourceSize: 256

    radius: 10
    color: Colors.surface2

    Image {
        id: img
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        sourceSize.width: root.sourceSize
        sourceSize.height: root.sourceSize
        opacity: status === Image.Ready ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }
    }
}
