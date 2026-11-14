pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

// Picks the most relevant MPRIS player: whichever is playing, else the
// last one that was.
Singleton {
    id: root

    readonly property list<MprisPlayer> players: Mpris.players.values
    property MprisPlayer last: null

    // Kept separate from `player` so remembering `last` can't loop back.
    readonly property MprisPlayer playingPlayer: players.find(p => p.isPlaying) ?? null
    onPlayingPlayerChanged: if (playingPlayer) last = playingPlayer

    readonly property MprisPlayer player: {
        if (playingPlayer)
            return playingPlayer;
        if (last && players.includes(last))
            return last;
        return players.length > 0 ? players[0] : null;
    }

    readonly property bool active: player !== null && (player.trackTitle ?? "") !== ""
    readonly property bool playing: player?.isPlaying ?? false
    readonly property string title: player?.trackTitle || "Nothing playing"
    readonly property string artist: player?.trackArtist || player?.identity || ""
    readonly property string art: player?.trackArtUrl ?? ""
    readonly property real length: player?.length ?? 0
    readonly property real position: player?.position ?? 0

    function toggle(): void { if (player?.canTogglePlaying) player.togglePlaying(); }
    function next(): void { if (player?.canGoNext) player.next(); }
    function previous(): void { if (player?.canGoPrevious) player.previous(); }

    // MPRIS only reports position on demand; poke it while visible & playing.
    property int listeners: 0
    Timer {
        running: root.playing && root.listeners > 0
        interval: 1000
        repeat: true
        onTriggered: root.player?.positionChanged()
    }
}
