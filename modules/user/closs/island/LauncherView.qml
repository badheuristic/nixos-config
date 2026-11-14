import QtQuick
import Quickshell
import qs.config
import qs.services
import qs.components

// App launcher + runner.
//   text     → fuzzy app search (frequently launched apps rank higher)
//   >cmd     → run a shell command
//   maths    → "12*4.5", "=2^10", "10km to miles", "72f to c": the result
//              shows large above the list and Enter copies it
Item {
    id: root

    readonly property int maxRows: 7
    readonly property string query: search.text
    readonly property string mode: query.startsWith(">") ? "run" : query.startsWith("=") ? "calc" : "apps"
    // Computed answer, if the query is maths or a unit conversion
    readonly property var answer: mode === "run" ? null : Calc.evaluate(mode === "calc" ? query.slice(1) : query)

    readonly property var results: {
        if (mode === "run") {
            const cmd = query.slice(1).trim();
            return cmd === "" ? [] : [{ kind: "run", title: cmd, subtitle: "Run command", icon: "utilities-terminal" }];
        }
        if (mode === "calc")
            return [];
        return Apps.query(query).slice(0, 60).map(a => ({ kind: "app", app: a, title: a.name, subtitle: a.comment || a.genericName || "", icon: a.icon }));
    }

    property int index: 0
    onResultsChanged: index = 0

    implicitWidth: 540
    implicitHeight: Style.pad + search.implicitHeight + 8 + (answer ? hero.height + (results.length ? 8 : 0) : 0) + (results.length || !answer ? list.height : 0) + Style.pad

    function activate(): void {
        search.text = "";
        index = 0;
        search.focusInput();
    }

    function accept(): void {
        if (answer) {
            Quickshell.execDetached(["wl-copy", String(Number(answer.value.toPrecision(12)))]);
            Closs.close();
            return;
        }
        const r = results[index];
        if (!r)
            return;
        if (r.kind === "app")
            Apps.launch(r.app);
        else if (r.kind === "run")
            Apps.run(r.title);
        Closs.close();
    }

    function move(d: int): void {
        if (results.length === 0)
            return;
        index = (index + d + results.length) % results.length;
        list.positionViewAtIndex(index, ListView.Contain);
    }

    SearchField {
        id: search
        anchors.top: parent.top
        anchors.topMargin: Style.pad - 4
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Style.pad + 4
        anchors.rightMargin: Style.pad + 4
        placeholder: "Search apps, > run, or do maths"
        trailing: root.mode === "apps" && root.query !== "" && !root.answer ? root.results.length + " results" : ""
        onAccepted: root.accept()
        onNavigate: e => {
            const ctrl = e.modifiers & Qt.ControlModifier;
            if (e.key === Qt.Key_Down || e.key === Qt.Key_Tab || (ctrl && (e.key === Qt.Key_J || e.key === Qt.Key_N))) {
                root.move(1);
                e.accepted = true;
            } else if (e.key === Qt.Key_Up || e.key === Qt.Key_Backtab || (ctrl && (e.key === Qt.Key_K || e.key === Qt.Key_P))) {
                root.move(-1);
                e.accepted = true;
            }
        }
    }

    // The answer, big: like the selected row in the inspo's theme picker
    Card {
        id: hero
        anchors.top: search.bottom
        anchors.topMargin: 8
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Style.pad - 4
        anchors.rightMargin: Style.pad - 4
        height: 92
        visible: root.answer !== null
        color: Colors.surface2

        Column {
            anchors.left: parent.left
            anchors.right: copyHint.left
            anchors.leftMargin: 18
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Txt {
                width: parent.width
                text: root.answer ? root.answer.detail : ""
                color: Colors.fgDim
                font.pixelSize: Style.fontMd
                elide: Text.ElideRight
            }
            Txt {
                width: parent.width
                text: root.answer ? root.answer.display : ""
                font.pixelSize: 34
                font.weight: Font.DemiBold
                font.features: ({ "tnum": 1 })
                fontSizeMode: Text.HorizontalFit
                minimumPixelSize: 18
                elide: Text.ElideRight
            }
        }

        Row {
            id: copyHint
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6
            Icon {
                anchors.verticalCenter: parent.verticalCenter
                icon: "content_copy"
                size: 15
                color: Colors.fgFaint
            }
            Txt {
                anchors.verticalCenter: parent.verticalCenter
                text: "Enter"
                color: Colors.fgFaint
                font.pixelSize: Style.fontSm
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.accept()
        }
    }

    ListView {
        id: list
        anchors.top: root.answer ? hero.bottom : search.bottom
        anchors.topMargin: 8
        visible: root.results.length > 0 || !root.answer
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Style.pad - 4
        anchors.rightMargin: Style.pad - 4
        height: Math.max(1, Math.min(root.results.length, root.maxRows)) * 52 + Math.max(0, Math.min(root.results.length, root.maxRows) - 1) * spacing
        spacing: 2
        clip: true
        model: root.results
        boundsBehavior: Flickable.StopAtBounds
        currentIndex: root.index
        highlightFollowsCurrentItem: false

        delegate: ListRow {
            required property var modelData
            required property int index
            width: ListView.view.width
            selected: index === root.index && !root.answer
            title: modelData.title
            subtitle: modelData.subtitle
            leading: AppIcon {
                icon: modelData.icon
                iconSize: 24
            }
            onClicked: {
                root.index = index;
                root.accept();
            }
            onHovered: root.index = index
        }

        Txt {
            anchors.centerIn: parent
            visible: root.results.length === 0 && !root.answer
            text: root.mode === "calc" ? "Try 12*4.5 or 10km to miles" : root.mode === "run" ? "Type a command" : "No matches"
            color: Colors.fgFaint
        }
    }
}
