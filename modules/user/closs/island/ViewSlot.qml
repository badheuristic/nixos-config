import QtQuick
import qs.config

// One state of the island. Only the current slot is loaded; it fades in a
// beat after the silhouette starts morphing and fades out quickly.
Item {
    id: slot

    required property string name
    property string current: ""
    property Component content

    readonly property bool shown: current === name
    readonly property Item item: loader.item

    implicitWidth: loader.item ? loader.item.implicitWidth : 0
    implicitHeight: loader.item ? loader.item.implicitHeight : 0
    width: implicitWidth
    height: implicitHeight
    anchors.horizontalCenter: parent.horizontalCenter

    opacity: shown ? 1 : 0
    scale: shown ? 1 : 0.95
    transformOrigin: Item.Top
    visible: opacity > 0.001
    enabled: shown

    Behavior on opacity {
        SequentialAnimation {
            PauseAnimation { duration: slot.shown ? Style.fadeDelay : 0 }
            NumberAnimation {
                duration: slot.shown ? Style.fadeIn : Style.fadeOut
                easing.type: Easing.OutCubic
            }
        }
    }
    Behavior on scale {
        NumberAnimation { duration: Style.morphDuration; easing.type: Easing.OutCubic }
    }

    onShownChanged: {
        if (shown)
            Qt.callLater(() => {
                if (!loader.item)
                    return;
                // Focus the view first, then let activate() hand focus to a
                // child (e.g. the search field) without it being taken back.
                loader.item.forceActiveFocus();
                if (loader.item.activate)
                    loader.item.activate();
            });
    }

    Loader {
        id: loader
        active: slot.shown || slot.visible
        sourceComponent: slot.content
        focus: true
    }
}
