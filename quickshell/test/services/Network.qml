pragma Singleton
import Quickshell

import QtQml

import Quickshell.Networking
import Quickshell.Io

Singleton {
    id: root
    property var wifiDevice: Networking.devices.values.find(d => d.type == DeviceType.Wifi)
    property var wifiConn:  wifiDevice ? wifiDevice.networks.values.find(n => n.connected) : null // undefined if no conned network, null if no device
    property bool wifiPresent
    property bool wifiConnected
    property bool wifiEnabled: true

    property var ethDevice: Networking.devices.values.find(d => d.type == DeviceType.Wired)
    property var ethConn:  ethDevice ? ethDevice.networks.values.find(n => n.connected) : null // undefined if no conned network, null if no device
    property bool ethActive: ethConn == null ? false : true

    property var wifiNetworks: []
    property var wifiCurrent: null

    property string lastWifiJson: ""
    property bool running: false

    function processWifiJson(text: string) {
        console.log(text)
        let data = JSON.parse(text)
        root.wifiPresent = data.present
        root.wifiConnected = data.connected !== null
        root.wifiEnabled = data.power == "on"
        root.wifiCurrent = data.connected
        root.wifiNetworks = data.networks ? data.networks : []
    }

    function disconnectWifi() {
        if (wifiConn === null) {
            return false
        }
        disconnectWifiProc.running = true
    }

    // function toggleWifi() {
    //     if (wifiEnabled) {
    //         toggleWifiProc.command = ["nmcli", "radio", "wifi", "off"]
    //     } else {
    //         toggleWifiProc.command = ["nmcli", "radio", "wifi", "on"]
    //     }
    //     toggleWifiProc.running = true
    // }

    Process {
        id: disconnectWifiProc
        command: ["nmcli", "device", "disconnect", root.wifiDevice.name]
        running: false
    }

    // Process {
    //     id: toggleWifiProc
    //     running: false
    // }

    Process {
        id: wifiProc
        command: ["bash", Quickshell.shellPath("services/wifi_panel_logic.sh")]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root.lastWifiJson = this.text.trim()
                root.processWifiJson(root.lastWifiJson)
            }
        }
    }

    Timer {
        running: true
        repeat: true
        interval: 1000
        onTriggered: {
            if (!wifiProc.running) wifiProc.running = true
        }
    }
}
