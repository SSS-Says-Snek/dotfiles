pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs.services

Item {
    id: root

    property int connectionHeight: 52
    property string connectingSsid: ""

    function needsPassword(security): bool {
        const s = String(security ?? "").trim().toUpperCase();
        return s !== "" && s !== "--" && s !== "NONE" && s !== "OPEN";
    }

    function connectWifi(ssid: string, password = "") {
        Network.connectWifi(ssid, password)
        root.connectingSsid = ssid
    }

    function promptWifi(net): void {
        if (!net || !net.ssid) {
            return;
        }
        if (!root.needsPassword(net.security) || net.saved) {
            root.connectWifi(net.ssid);
            return;
        }

        Dialogs.open("wifiPassword", {
            ssid: net.ssid,
            security: net.security,
            saved: !!net.saved
        })
    }

    Connections {
        target: Dialogs

        function onAccepted(kind: string, result: var): void {
            if (kind !== "wifiPassword") {
                return;
            }

            root.connectWifi(result.ssid, result.password)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 6

        NetworkConnection {
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? root.connectionHeight : 0

            clip: true
            visible: Network.wifiCurrent !== null
            status: "Connected"
            modelData: Network.wifiCurrent ?? {
                ssid: "",
                icon: "0"
            }

            Behavior on Layout.preferredHeight {
                NumberAnimation {
                    duration: 240
                    easing.type: Easing.OutCubic
                }
            }
        }

        ListView {
            id: list

            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 6
            model: Network.wifiNetworks

            delegate: NetworkConnection {
                id: entry

                required property string ssid
                required property string icon
                required property string security
                required property bool saved

                width: list.width
                clip: true

                modelData: ({
                    ssid: entry.ssid,
                    icon: entry.icon,
                    security: entry.security,
                    saved: entry.saved
                })

                status: {
                    if (Network.wifiDevice?.state == 1 && entry.ssid == root.connectingSsid) {
                        return "Connecting"
                    }
                    return entry.saved ? "Saved" : "Unknown"
                }
                onClicked: root.promptWifi(entry.modelData)

                NumberAnimation on height {
                    from: 0
                    to: root.connectionHeight
                    duration: 240
                    easing.type: Easing.OutCubic
                }
            }
        }
    }
}
