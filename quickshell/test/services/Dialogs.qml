pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    property bool visible: false
    property string kind: ""
    property var payload: ({})
    readonly property color dimColor: "#99000000"

    signal accepted(string kind, var result)
    signal dismissed(string kind)

    function open(kind: string, payload: var): void {
        root.kind = kind
        root.payload = payload ?? {}
        root.visible = true
    }

    function accept(result: var): void {
        const k = root.kind
        root.visible = false
        root.accepted(k, result ?? {})
        root.kind = ""
        root.payload = {}
    }

    function dismiss(): void {
        const k = root.kind
        if (!k && !root.visible)
            return
        root.visible = false
        root.dismissed(k)
        root.kind = ""
        root.payload = {}
    }
}
