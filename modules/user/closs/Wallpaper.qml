import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services

// The shell paints the wallpaper itself so changes cross-fade and the lock
// screen can reuse the exact same image.
PanelWindow {
    id: root

    required property ShellScreen modelData

    screen: modelData
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore
    color: "black"
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "closs-wallpaper"

    Image {
        id: back
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        sourceSize.width: root.width
        sourceSize.height: root.height
        asynchronous: true
    }

    Image {
        id: front
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        sourceSize.width: root.width
        sourceSize.height: root.height
        asynchronous: true
        source: Wallpapers.current === "" ? "" : "file://" + Wallpapers.current
        opacity: 0

        onSourceChanged: opacity = 0
        onStatusChanged: if (status === Image.Ready) fade.restart()

        NumberAnimation {
            id: fade
            target: front
            property: "opacity"
            from: 0
            to: 1
            duration: 700
            easing.type: Easing.InOutQuad
            onFinished: back.source = front.source
        }
    }
}
