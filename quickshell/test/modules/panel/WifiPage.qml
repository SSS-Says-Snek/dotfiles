pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs.services

Item {
    id: root

    property int connectionHeight: 52

    ColumnLayout {
        anchors.fill: parent
        spacing: 6

        NetworkConnection {
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? root.connectionHeight : 0

            visible: Network.wifiCurrent !== null
            connected: true
            modelData: Network.wifiCurrent ?? {
                ssid: "",
                icon: "0"
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
                width: list.width
                height: root.connectionHeight
                connected: false
                onClicked: (ssid) => {
                    console.log(ssid)
                }
            }
        }
    }
}
