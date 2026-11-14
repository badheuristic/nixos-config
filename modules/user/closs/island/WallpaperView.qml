import QtQuick
import qs.config
import qs.services
import qs.components

// Wallpaper carousel: type to filter, ←/→ to browse, Enter to apply.
Item {
    id: root

    readonly property var results: {
        const q = search.text.trim().toLowerCase();
        return Wallpapers.files.filter(f => q === "" || f.split("/").pop().toLowerCase().includes(q));
    }
    readonly property string selected: results[carousel.currentIndex] ?? ""

    implicitWidth: 760
    implicitHeight: Style.pad + search.implicitHeight + 12 + carousel.height + 12 + 18 + Style.pad

    function activate(): void {
        search.text = "";
        Wallpapers.refresh();
        Qt.callLater(() => carousel.currentIndex = Math.max(0, results.indexOf(Wallpapers.current)));
        search.focusInput();
    }

    function apply(): void {
        if (selected !== "")
            Wallpapers.set(selected);
    }

    SearchField {
        id: search
        anchors.top: parent.top
        anchors.topMargin: Style.pad - 4
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Style.pad + 4
        anchors.rightMargin: Style.pad + 4
        placeholder: "Search wallpapers"
        onAccepted: root.apply()
        onNavigate: e => {
            if (e.key === Qt.Key_Right || e.key === Qt.Key_Tab || e.key === Qt.Key_Down) {
                carousel.incrementCurrentIndex();
                e.accepted = true;
            } else if (e.key === Qt.Key_Left || e.key === Qt.Key_Backtab || e.key === Qt.Key_Up) {
                carousel.decrementCurrentIndex();
                e.accepted = true;
            }
        }
    }

    ListView {
        id: carousel
        anchors.top: search.bottom
        anchors.topMargin: 12
        anchors.left: parent.left
        anchors.right: parent.right
        height: 128
        orientation: ListView.Horizontal
        spacing: 10
        clip: true
        model: root.results
        highlightRangeMode: ListView.StrictlyEnforceRange
        preferredHighlightBegin: (width - 200) / 2
        preferredHighlightEnd: (width + 200) / 2
        highlightMoveDuration: 260
        boundsBehavior: Flickable.StopAtBounds

        delegate: Item {
            id: thumb
            required property string modelData
            required property int index
            readonly property bool current: ListView.isCurrentItem

            width: current ? 200 : 140
            height: carousel.height
            Behavior on width {
                NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
            }

            RoundedImage {
                anchors.centerIn: parent
                width: parent.width
                height: thumb.current ? 120 : 86
                radius: 14
                sourceSize: 400
                source: "file://" + thumb.modelData
                opacity: thumb.current ? 1 : 0.55

                Behavior on height {
                    NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
                }
                Behavior on opacity {
                    NumberAnimation { duration: 200 }
                }

                // ring on the wallpaper that's currently applied
                Rectangle {
                    anchors.fill: parent
                    radius: 14
                    color: "transparent"
                    border.width: 2
                    border.color: Colors.primary
                    visible: thumb.modelData === Wallpapers.current
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (thumb.current)
                        root.apply();
                    else
                        carousel.currentIndex = thumb.index;
                }
            }
        }

        WheelHandler {
            onWheel: e => e.angleDelta.y > 0 ? carousel.decrementCurrentIndex() : carousel.incrementCurrentIndex()
        }
    }

    Txt {
        anchors.left: parent.left
        anchors.leftMargin: Style.pad + 4
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.pad
        text: root.selected.split("/").pop()
        font.pixelSize: Style.fontXs
        color: Colors.fgDim
    }
    Txt {
        anchors.right: parent.right
        anchors.rightMargin: Style.pad + 4
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.pad
        text: root.results.length > 0 ? (carousel.currentIndex + 1) + "/" + root.results.length : "No images in " + Colors.wallpaperDir
        font.pixelSize: Style.fontXs
        color: Colors.fgFaint
    }
}
