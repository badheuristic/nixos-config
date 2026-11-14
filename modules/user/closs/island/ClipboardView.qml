import QtQuick
import qs.config
import qs.services
import qs.components

// Clipboard history. Enter copies, Shift+Delete removes an entry.
Item {
    id: root

    readonly property int maxRows: 7
    readonly property var results: {
        const q = search.text.trim().toLowerCase();
        return q === "" ? Clipboard.entries : Clipboard.entries.filter(e => e.text.toLowerCase().includes(q));
    }

    property int index: 0
    onResultsChanged: index = Math.min(index, Math.max(0, results.length - 1))

    implicitWidth: 540
    implicitHeight: Style.pad + search.implicitHeight + 8 + list.height + Style.pad

    function activate(): void {
        search.text = "";
        index = 0;
        Clipboard.refresh();
        search.focusInput();
    }

    function accept(): void {
        const e = results[index];
        if (!e)
            return;
        Clipboard.copy(e);
        Closs.close();
    }

    function move(d: int): void {
        if (results.length === 0)
            return;
        index = (index + d + results.length) % results.length;
        list.positionViewAtIndex(index, ListView.Contain);
    }

    function isImage(e: var): bool {
        return e.text.startsWith("[[ binary data");
    }

    SearchField {
        id: search
        anchors.top: parent.top
        anchors.topMargin: Style.pad - 4
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Style.pad + 4
        anchors.rightMargin: Style.pad + 4
        placeholder: "Search clipboard"
        trailing: Clipboard.entries.length + " items"
        onAccepted: root.accept()
        onNavigate: e => {
            const ctrl = e.modifiers & Qt.ControlModifier;
            if (e.key === Qt.Key_Down || e.key === Qt.Key_Tab || (ctrl && (e.key === Qt.Key_J || e.key === Qt.Key_N))) {
                root.move(1);
                e.accepted = true;
            } else if (e.key === Qt.Key_Up || e.key === Qt.Key_Backtab || (ctrl && (e.key === Qt.Key_K || e.key === Qt.Key_P))) {
                root.move(-1);
                e.accepted = true;
            } else if (e.key === Qt.Key_Delete && (e.modifiers & Qt.ShiftModifier)) {
                Clipboard.remove(root.results[root.index]);
                e.accepted = true;
            }
        }
    }

    ListView {
        id: list
        anchors.top: search.bottom
        anchors.topMargin: 8
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Style.pad - 4
        anchors.rightMargin: Style.pad - 4
        height: Math.max(1, Math.min(root.results.length, root.maxRows)) * 52 + Math.max(0, Math.min(root.results.length, root.maxRows) - 1) * spacing
        spacing: 2
        clip: true
        model: root.results
        boundsBehavior: Flickable.StopAtBounds

        delegate: ListRow {
            required property var modelData
            required property int index
            width: ListView.view.width
            selected: index === root.index
            title: root.isImage(modelData) ? "Image" : modelData.text
            subtitle: root.isImage(modelData) ? modelData.text.replace(/^\[\[ binary data |\]\]$/g, "") : ""
            leading: Rectangle {
                width: 36
                height: 36
                radius: 10
                color: Colors.surface
                Icon {
                    anchors.centerIn: parent
                    icon: root.isImage(modelData) ? "image" : "content_paste"
                    size: 18
                    color: Colors.fgDim
                }
            }
            onClicked: {
                root.index = index;
                root.accept();
            }
            onHovered: root.index = index
        }

        Txt {
            anchors.centerIn: parent
            visible: root.results.length === 0
            text: "Clipboard is empty"
            color: Colors.fgFaint
        }
    }
}
