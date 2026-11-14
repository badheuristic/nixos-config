import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import qs.config
import qs.services
import qs.components

// The system tray as an island state: app icons across the top, the
// selected app's menu below, drawn by the island instead of a popup.
// Click an icon for its menu, double-click to open the app, middle-click
// for its secondary action. ←/→ pick an app, ↑/↓ and Enter use the menu,
// Backspace leaves a submenu.
Item {
    id: root

    readonly property var items: SystemTray.items.values
    property int index: 0
    readonly property var item: items.length > 0 ? items[Math.min(index, items.length - 1)] : null

    // submenu path; empty = the app's top-level menu
    property var stack: []
    readonly property var menu: stack.length > 0 ? stack[stack.length - 1] : (item?.hasMenu ? item.menu : null)
    readonly property var entries: opener.children ? opener.children.values : []
    property int row: -1

    implicitWidth: 360
    implicitHeight: column.implicitHeight + 2 * Style.pad

    function activate(): void {
        const i = items.findIndex(t => t.id === Closs.trayItem);
        select(i < 0 ? 0 : i);
    }

    function select(i: int): void {
        index = i;
        flick.contentY = 0;
        stack = [];
        row = -1;
    }

    function name(t): string {
        if (!t)
            return "";
        return t.tooltipTitle || t.title || t.id;
    }

    function open(): void {
        if (!item)
            return;
        item.activate();
        Closs.close();
    }

    function run(e): void {
        if (!e || e.isSeparator || !e.enabled)
            return;
        if (e.hasChildren) {
            stack = stack.concat([e]);
            row = -1;
            flick.contentY = 0;
            return;
        }
        e.triggered();
        Closs.close();
    }

    function back(): void {
        if (stack.length > 0) {
            stack = stack.slice(0, -1);
            row = -1;
        }
    }

    onRowChanged: Qt.callLater(() => {
        const r = row >= 0 ? menuColumn.children[row + 2] : null;
        if (!r)
            return;
        const top = r.y, bottom = r.y + r.height;
        if (top < flick.contentY)
            flick.contentY = top;
        else if (bottom > flick.contentY + flick.height)
            flick.contentY = bottom - flick.height;
    })

    function step(d: int): void {
        const n = entries.length;
        for (let k = 1; k <= n; k++) {
            const r = ((row < 0 ? (d > 0 ? -1 : n) : row) + d * k % n + n) % n;
            const e = entries[r];
            if (e && !e.isSeparator && e.enabled) {
                row = r;
                return;
            }
        }
    }

    Keys.onPressed: e => {
        const n = items.length;
        if (n > 0 && (e.key === Qt.Key_Left || e.key === Qt.Key_H))
            select((index + n - 1) % n);
        else if (n > 0 && (e.key === Qt.Key_Right || e.key === Qt.Key_L || e.key === Qt.Key_Tab))
            select((index + 1) % n);
        else if (e.key === Qt.Key_Down || e.key === Qt.Key_J)
            step(1);
        else if (e.key === Qt.Key_Up || e.key === Qt.Key_K)
            step(-1);
        else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter || e.key === Qt.Key_Space)
            row >= 0 ? run(entries[row]) : open();
        else if (e.key === Qt.Key_Backspace)
            back();
        else
            return;
        e.accepted = true;
    }

    QsMenuOpener {
        id: opener
        menu: root.menu
    }

    Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Style.pad
        spacing: Style.gap

        // ── apps ─────────────────────────────────────────────────────────
        Flow {
            width: parent.width
            spacing: 6

            Repeater {
                model: root.items

                Item {
                    id: app
                    required property var modelData
                    required property int index
                    readonly property bool selected: index === root.index
                    width: 40
                    height: 40

                    Rectangle {
                        anchors.fill: parent
                        radius: Style.controlRadius
                        color: Colors.surface2
                        opacity: app.selected ? 1 : appMouse.containsMouse ? 0.5 : 0
                        Behavior on opacity {
                            NumberAnimation { duration: Style.quick }
                        }
                    }

                    IconImage {
                        anchors.centerIn: parent
                        implicitSize: 20
                        source: app.modelData.icon
                        asynchronous: true
                    }

                    // needs-attention dot
                    Rectangle {
                        visible: app.modelData.status === Status.NeedsAttention
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 6
                        width: 6
                        height: 6
                        radius: 3
                        color: Colors.primary
                    }

                    MouseArea {
                        id: appMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                        onClicked: e => {
                            if (e.button === Qt.MiddleButton)
                                app.modelData.secondaryActivate();
                            else
                                root.select(app.index);
                        }
                        onDoubleClicked: root.open()
                        onWheel: w => app.modelData.scroll(w.angleDelta.y, false)
                    }
                }
            }
        }

        Txt {
            visible: root.items.length === 0
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: "Nothing in the tray"
            color: Colors.fgDim
            font.pixelSize: Style.fontSm
        }

        // ── the selected app's menu ──────────────────────────────────────
        Card {
            visible: root.item !== null
            width: parent.width
            // long menus (Steam's) scroll instead of growing past the screen
            height: Math.min(menuColumn.implicitHeight, 420) + 12

            Flickable {
                id: flick
                anchors.fill: parent
                anchors.margins: 6
                contentHeight: menuColumn.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

            Column {
                id: menuColumn
                width: flick.width

                // title row: app name, or "‹ Back" inside a submenu
                MenuRow {
                    width: parent.width
                    text: root.stack.length > 0 ? root.stack[root.stack.length - 1].text.replace(/_/g, "") : root.name(root.item)
                    glyph: root.stack.length > 0 ? "chevron_left" : ""
                    bold: true
                    trailing: root.stack.length > 0 || (root.item?.onlyMenu ?? true) ? "" : "open_in_new"
                    onClicked: root.stack.length > 0 ? root.back() : root.open()
                }

                Rectangle {
                    visible: root.entries.length > 0
                    width: parent.width
                    height: 1
                    color: Colors.surface3
                    opacity: 0.6
                }

                Repeater {
                    model: root.entries

                    Loader {
                        id: entry
                        required property var modelData
                        required property int index
                        width: menuColumn.width
                        sourceComponent: modelData.isSeparator ? separator : button

                        Component {
                            id: separator
                            Item {
                                height: 9
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: parent.width - 16
                                    height: 1
                                    color: Colors.surface3
                                    opacity: 0.6
                                }
                            }
                        }

                        Component {
                            id: button
                            MenuRow {
                                text: entry.modelData.text.replace(/_/g, "")
                                image: entry.modelData.icon
                                enabled: entry.modelData.enabled
                                selected: root.row === entry.index
                                glyph: entry.modelData.buttonType === QsMenuButtonType.None ? ""
                                    : entry.modelData.checkState === Qt.Checked
                                        ? (entry.modelData.buttonType === QsMenuButtonType.RadioButton ? "radio_button_checked" : "check_box")
                                        : (entry.modelData.buttonType === QsMenuButtonType.RadioButton ? "radio_button_unchecked" : "check_box_outline_blank")
                                trailing: entry.modelData.hasChildren ? "chevron_right" : ""
                                onClicked: root.run(entry.modelData)
                                onHovered: root.row = entry.index
                            }
                        }
                    }
                }
            }
            }
        }
    }

    component MenuRow: Item {
        id: mr
        property string text: ""
        property string glyph: ""
        property string image: ""
        property string trailing: ""
        property bool bold: false
        property bool selected: false
        signal clicked
        signal hovered

        implicitHeight: 34
        opacity: enabled ? 1 : 0.4

        Rectangle {
            anchors.fill: parent
            radius: 10
            color: Colors.surface2
            opacity: mr.selected || mrMouse.containsMouse ? 1 : 0
            Behavior on opacity {
                NumberAnimation { duration: Style.quick }
            }
        }

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.right: trail.left
            anchors.rightMargin: 6
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            Icon {
                visible: mr.glyph !== ""
                anchors.verticalCenter: parent.verticalCenter
                icon: mr.glyph
                size: 16
                color: Colors.fgDim
            }
            IconImage {
                visible: mr.image !== "" && mr.glyph === ""
                anchors.verticalCenter: parent.verticalCenter
                implicitSize: 16
                source: mr.image
            }
            Txt {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - x
                text: mr.text
                elide: Text.ElideRight
                font.pixelSize: Style.fontMd
                font.weight: mr.bold ? Font.DemiBold : Font.Normal
            }
        }

        Icon {
            id: trail
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            visible: mr.trailing !== ""
            width: visible ? 16 : 0
            icon: mr.trailing
            size: 16
            color: Colors.fgDim
        }

        MouseArea {
            id: mrMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: mr.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: mr.clicked()
            onContainsMouseChanged: if (containsMouse) mr.hovered()
        }
    }
}
