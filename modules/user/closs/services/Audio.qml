pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    PwObjectTracker {
        objects: [root.sink, root.source]
    }

    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property bool micMuted: source?.audio?.muted ?? false
    readonly property string sinkName: sink?.description || sink?.nickname || "Output"

    readonly property string icon: muted || volume < 0.005 ? "volume_off"
        : volume < 0.34 ? "volume_mute"
        : volume < 0.67 ? "volume_down"
        : "volume_up"

    function setVolume(v: real): void {
        if (!sink?.audio)
            return;
        sink.audio.muted = false;
        sink.audio.volume = Math.max(0, Math.min(1, v));
    }

    function step(delta: real): void {
        setVolume(volume + delta);
        Closs.flashOsd("volume");
    }

    function toggleMute(): void {
        if (sink?.audio)
            sink.audio.muted = !sink.audio.muted;
        Closs.flashOsd("volume");
    }

    function toggleMic(): void {
        if (source?.audio)
            source.audio.muted = !source.audio.muted;
        Closs.flashOsd("mic");
    }
}
