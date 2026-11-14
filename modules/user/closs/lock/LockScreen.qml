import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import qs.services

// Session lock (ext-session-lock). Password entry lives in the island on
// the lock surface, so locking feels like the same object changing state.
Scope {
    id: root

    property string buffer: ""
    property bool busy: false
    property bool failed: false

    signal shake

    function type(text: string): void {
        if (busy)
            return;
        failed = false;
        buffer += text;
    }

    function backspace(): void {
        if (!busy)
            buffer = buffer.slice(0, -1);
    }

    function clear(): void {
        if (!busy)
            buffer = "";
    }

    function submit(): void {
        if (busy || buffer === "")
            return;
        busy = true;
        if (!pam.start()) {
            busy = false;
            fail();
        }
    }

    function fail(): void {
        buffer = "";
        failed = true;
        shake();
    }

    PamContext {
        id: pam
        // NixOS: security.pam.services.closs
        config: "closs"

        onResponseRequiredChanged: {
            if (responseRequired) {
                respond(root.buffer);
            }
        }
        onCompleted: result => {
            root.busy = false;
            if (result === PamResult.Success) {
                root.buffer = "";
                root.failed = false;
                Session.unlocked();
            } else {
                root.fail();
            }
        }
        onError: () => {
            root.busy = false;
            root.fail();
        }
    }

    WlSessionLock {
        id: lock
        locked: Session.ready && Session.locked

        WlSessionLockSurface {
            id: surface
            color: "black"

            LockContent {
                anchors.fill: parent
                lock: root
                screen: surface.screen
            }
        }
    }
}
