pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property var all: DesktopEntries.applications.values
        .filter(a => !a.noDisplay)
        .sort((a, b) => a.name.localeCompare(b.name))

    // Launch counts, persisted, so frequently used apps float up.
    property var counts: ({})

    function score(app: var, q: string): real {
        const name = app.name.toLowerCase();
        let s = 0;
        if (name === q)
            s = 100;
        else if (name.startsWith(q))
            s = 80;
        else if (name.split(/[\s\-_.]+/).some(w => w.startsWith(q)))
            s = 60;
        else if (name.includes(q))
            s = 45;
        else {
            const extra = [app.genericName, app.comment, app.id, ...(app.keywords ?? [])].join(" ").toLowerCase();
            if (extra.includes(q))
                s = 30;
            else {
                // in-order subsequence ("ffx" -> firefox)
                let i = 0;
                for (const c of name)
                    if (c === q[i])
                        i++;
                if (i === q.length)
                    s = 10;
            }
        }
        return s > 0 ? s + Math.min(counts[app.id] ?? 0, 25) : 0;
    }

    function query(text: string): var {
        const q = text.trim().toLowerCase();
        if (q === "")
            return all.slice().sort((a, b) => (counts[b.id] ?? 0) - (counts[a.id] ?? 0) || a.name.localeCompare(b.name));
        return all.map(a => ({ a, s: score(a, q) }))
            .filter(x => x.s > 0)
            .sort((x, y) => y.s - x.s || x.a.name.localeCompare(y.a.name))
            .map(x => x.a);
    }

    function launch(app: var): void {
        if (!app)
            return;
        counts[app.id] = (counts[app.id] ?? 0) + 1;
        store.setText(JSON.stringify(counts));
        if (app.runInTerminal)
            Quickshell.execDetached(["kitty", "-e", ...app.command]);
        else
            app.execute();
    }

    function run(command: string): void {
        Quickshell.execDetached(["sh", "-c", command]);
    }

    FileView {
        id: store
        path: Quickshell.statePath("launches.json")
        printErrors: false
        onLoaded: {
            try {
                root.counts = JSON.parse(text());
            } catch (e) {
                root.counts = {};
            }
        }
    }
}
