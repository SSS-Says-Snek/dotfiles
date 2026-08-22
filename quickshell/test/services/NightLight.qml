pragma Singleton

import QtQml

import Quickshell
import Quickshell.Io

// Make sure these day/night values are CORRECT as per ~/.config/hypr/hyprsunset.conf if you wanna use
Singleton {
    id: root

    readonly property int day: 6000
    readonly property int night: 5200

    property bool isOn

    function toggle() {
        const command = ["hyprctl", "hyprsunset", "temperature", isOn ? root.day : root.night]
        toggleProc.command = command
        toggleProc.running = true
        if (isOn) {
            turnOffProcTimer.restart()
        }
        isOn = !isOn
    }

    Process {
        id: nightLightProc
        command: ["hyprctl", "hyprsunset", "temperature"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root.isOn = !(parseInt(this.text) == root.day)
            }
        }
    }

    Process {
        id: toggleProc
        running: false
    }

    Process {
        id: turnOffProc
        command: ["hyprctl", "hyprsunset", "identity"]
        running: false
    }

    Timer {
        id: turnOffProcTimer
        repeat: false
        running: false
        interval: 500
        onTriggered: if (!root.isOn) turnOffProc.running = true
    }

    Timer {
        running: true
        repeat: true
        interval: 3000
        onTriggered: nightLightProc.running = true
    }
}
