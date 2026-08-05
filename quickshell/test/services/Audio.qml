pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    property PwNode sink: Pipewire.defaultAudioSink
    property PwNode source: Pipewire.defaultAudioSource

    property bool micMuted: source?.audio.muted ?? false
    property bool sinkMuted: sink?.audio.muted ?? false
    property real value: sink?.audio.volume ?? 0

    readonly property real maxVolume: 2.5

    PwObjectTracker {
        objects: [sink, source]
    }

    function incVolume() {
        let temp = value
        temp += 0.01
        if (temp > maxVolume) {
            temp = maxVolume
        }

        sink.audio.volume = temp
    }

    function decVolume() {
        let temp = value
        temp -= 0.01
        if (temp < 0) {
            temp = 0
        }

        sink.audio.volume = temp
    }

    function setVolume(volume) {
        if (!sink?.audio)
            return;
        if (volume < 0)
            volume = 0;
        if (volume > maxVolume)
            volume = maxVolume;
        sink.audio.volume = volume;
    }

    function toggleMute() {
        sink.audio.muted = !sink.audio.muted
    }
}
