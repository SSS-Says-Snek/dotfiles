pragma Singleton

import Quickshell

import QtQml
import QtQml.Models

import Quickshell.Networking
import Quickshell.Io

Singleton {
    id: root
    property var wifiDevice: Networking.devices.values.find(d => d.type == DeviceType.Wifi)
    property var wifiConn: wifiDevice ? wifiDevice.networks.values.find(n => n.connected) : null // undefined if no conned network, null if no device
    property bool wifiConnected
    property bool wifiEnabled: Networking.wifiEnabled

    property var ethDevice: Networking.devices.values.find(d => d.type == DeviceType.Wired)
    property var ethConn: ethDevice ? ethDevice.networks.values.find(n => n.connected) : null // undefined if no conned network, null if no device
    property bool ethActive: ethConn == null ? false : true

    readonly property alias wifiNetworks: wifiNetworkModel
    property var wifiCurrent: null

    property string lastWifiJson: ""
    property bool running: false

    ListModel {
        id: wifiNetworkModel
    }

    function rowFor(n) {
        return {
            ssid: String(n.ssid ?? ""),
            icon: String(n.icon ?? "0"),
            signal: String(n.signal ?? ""),
            security: String(n.security ?? ""),
            saved: n.saved === true
        }
    }

    function syncNetworks(nets) {
        for (let i = wifiNetworkModel.count - 1; i >= 0; i--) {
            const ssid = wifiNetworkModel.get(i).ssid
            if (!nets.some(n => String(n.ssid ?? "") === ssid))
                wifiNetworkModel.remove(i)
        }

        for (let i = 0; i < nets.length; i++) {
            const row = root.rowFor(nets[i])
            if (!row.ssid)
                continue
            let at = -1
            for (let j = 0; j < wifiNetworkModel.count; j++) {
                if (wifiNetworkModel.get(j).ssid === row.ssid) {
                    at = j
                    break
                }
            }

            if (at === -1) {
                wifiNetworkModel.insert(Math.min(i, wifiNetworkModel.count), row)
                continue
            }

            if (at !== i)
                wifiNetworkModel.move(at, i, 1)

            const existing = wifiNetworkModel.get(i)
            for (const key of ["icon", "signal", "security", "saved"]) {
                if (existing[key] !== row[key])
                    wifiNetworkModel.setProperty(i, key, row[key])
            }
        }
    }

    function processWifiJson(text: string) {
        let data = JSON.parse(text)
        root.wifiConnected = data.connected !== null
        root.wifiCurrent = data.connected
        root.syncNetworks(data.networks ?? [])
    }

    function connectWifi(ssid: string, password = "") {
        connectWifiProc.command = ["nmcli", "device", "wifi", "connect", ssid]
        if (password) {
            connectWifiProc.command.push(...["password", password])
        }
        connectWifiProc.running = true
    }

    function disconnectWifi() {
        if (wifiConn === null) {
            return false
        }
        disconnectWifiProc.running = true
    }

    function disableWifi() {
        Networking.wifiEnabled = false
    }

    function enableWifi() {
        Networking.wifiEnabled = true
    }

    Process {
        id: connectWifiProc
        running: false
    }

    Process {
        id: disconnectWifiProc
        command: ["nmcli", "device", "disconnect", root.wifiDevice.name]
        running: false
    }

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
            if (!wifiProc.running)
                wifiProc.running = true
        }
    }
}
