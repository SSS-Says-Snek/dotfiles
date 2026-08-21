pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    property PwNode sink: Pipewire.defaultAudioSink
    property PwNode source: Pipewire.defaultAudioSource

    property var allSources: Pipewire.nodes.values.filter(n => n.audio && !n.isSink && !n.isStream)
    property var allSinks: Pipewire.nodes.values.filter(n => n.audio && n.isSink && !n.isStream)

    property bool micMuted: source?.audio.muted ?? false
    property bool sinkMuted: sink?.audio.muted ?? false
    property real value: sink?.audio.volume ?? 0

    readonly property real maxVolume: 2.5

    PwObjectTracker {
        objects: {
            const list = [];
            for (const n of root.allSources) {
                if (n)
                    list.push(n);
            }
            for (const n of root.allSinks) {
                if (n)
                    list.push(n);
            }
            if (root.sink)
                list.push(root.sink);
            if (root.source)
                list.push(root.source);
            return list;
        }
    }

    function nodeIconName(node): string {
        const props = node?.properties;
        if (!props)
            return "";
        return props["device.icon-name"] || props["media.icon-name"] || props["application.icon-name"] || "";
    }

    function setSource(node): void {
        if (!node)
            return;
        Pipewire.preferredDefaultAudioSource = node;
    }

    function setSink(node): void {
        if (!node)
            return;
        Pipewire.preferredDefaultAudioSink = node;
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
            return
        if (volume < 0)
            volume = 0
        if (volume > maxVolume)
            volume = maxVolume
        sink.audio.volume = volume
    }

    function toggleMute() {
        sink.audio.muted = !sink.audio.muted
    }

    function toggleMic() {
        source.audio.muted = !source.audio.muted
    }
}
