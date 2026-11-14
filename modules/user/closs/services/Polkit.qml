pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Polkit

// The shell is the session's polkit agent: password prompts appear inside
// the island instead of a separate dialog.
Singleton {
    id: root

    readonly property var flow: agent.flow
    readonly property bool active: agent.isActive && flow !== null
    readonly property bool registered: agent.isRegistered

    function submit(text: string): void {
        flow?.submit(text);
    }

    function cancel(): void {
        flow?.cancelAuthenticationRequest();
    }

    PolkitAgent {
        id: agent
    }
}
