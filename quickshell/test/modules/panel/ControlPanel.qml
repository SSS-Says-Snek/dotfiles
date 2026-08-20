pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs.settings
import qs.modules
import qs.services

Item {
    id: root

    property int page: 0
    property string submenuTitle: ""
    property Component submenu: null

    function push(comp: Component, title: string): void {
        root.submenu = comp;
        root.submenuTitle = title;
        root.page = 1;
    }

    function pop(): void {
        root.page = 0;
    }

    clip: true

    Row {
        id: strip

        height: parent.height
        x: -root.page * root.width

        Behavior on x {
            NumberAnimation {
                duration: 280
                easing.type: Easing.OutCubic
            }
        }

        Item {
            width: root.width
            height: root.height

            GridLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                columns: 2
                columnSpacing: 20
                rowSpacing: 20
                uniformCellWidths: true

                ControlButton {
                    id: wifiBtn

                    Layout.fillWidth: true
                    icon: "mdi-dashboard"
                    title: "Wi-Fi"
                    text: {
                        if (!Network.wifiEnabled) {
                            return "Off"
                        }
                        if (!Network.wifiConn) {
                            return "Not Connected"
                        }
                        return Network.wifiConn.name
                    }
                    active: Network.wifiConn != null
                    hasSubmenu: true
                    submenu: wifiPage
                    onClicked: root.push(wifiBtn.submenu, wifiBtn.title)
                    onInnerClicked: {
                        if (active)
                            Network.disconnectWifi()
                    }
                }

                ControlButton {
                    id: btBtn

                    Layout.fillWidth: true
                    icon: "mdi-dashboard"
                    title: "Bluetooth"
                    text: "Not connected"
                    hasSubmenu: true
                    submenu: bluetoothPage
                    onClicked: root.push(btBtn.submenu, btBtn.title)
                }

                ControlButton {
                    Layout.fillWidth: true
                    icon: "mdi-dashboard"
                    title: "Quiet Mode"
                    text: "Off"
                }

                ControlButton {
                    Layout.fillWidth: true
                    icon: "mdi-dashboard"
                    title: "Night Light"
                    text: "On"
                    active: true
                }

                ControlButton {
                    Layout.fillWidth: true
                    icon: "mdi-dashboard"
                    text: "Control Panel"
                }

                ControlButton {
                    Layout.fillWidth: true
                    icon: "mdi-dashboard"
                    text: "Control Panel"
                }
            }
        }

        Item {
            width: root.width
            height: root.height

            ColumnLayout {
                anchors.fill: parent
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Icon {
                        icon: "mdi-previous"
                        size: 22
                        color: backHover.hovered ? Theme.accent : Theme.text
                        interactive: true
                        onClicked: root.pop()
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.submenuTitle
                        color: Theme.text
                        font {
                            family: Theme.font
                            pixelSize: 16
                            weight: 800
                        }

                        HoverHandler {
                            id: backHover
                            cursorShape: Qt.PointingHandCursor
                        }

                        TapHandler {
                            onTapped: root.pop()
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 2
                    color: Theme.surface2
                }

                Loader {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    active: root.submenu !== null
                    sourceComponent: root.submenu
                }
            }
        }
    }

    Component {
        id: wifiPage

        WifiPage {}
    }

    Component {
        id: bluetoothPage

        Item {
            ListView {
                anchors.fill: parent
                clip: true
                spacing: 6
                model: ["WH-1000XM5", "Keychron K2", "Xbox Controller"]

                delegate: Rectangle {
                    required property string modelData

                    width: ListView.view.width
                    height: 48
                    radius: 16
                    color: "#80000000"

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 14
                        text: modelData
                        color: Theme.text
                        font {
                            family: Theme.font
                            pixelSize: 14
                            weight: 700
                        }
                    }
                }
            }
        }
    }
}
