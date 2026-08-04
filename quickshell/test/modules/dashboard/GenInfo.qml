import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Widgets
import Quickshell.Io

import qs.settings
import qs.services

Rectangle {
    id: root
    color: Theme.dashboardBg
    radius: 14

    property int osAge

    GridLayout {
        rows: 4
        columns: 2
        columnSpacing: 10
        anchors.margins: 20
        anchors.fill: parent

        ColumnLayout {
            Layout.row: 0
            Layout.column: 0
            Layout.rowSpan: 4

            ClippingRectangle {
                id: avatar

                width: 130
                height: 130
                radius: width / 2

                Image {
                    anchors.fill: parent
                    source: Quickshell.shellPath("assets/coco.jpg")
                    fillMode: Image.PreserveAspectCrop
                    sourceSize.width: Math.round(avatar.width * Screen.devicePixelRatio)
                    asynchronous: true
                }
            }

        }

        Text {
            text: "󰣇 Arch Linux" // Too lazy, hardcode
            color: Theme.text
            font {
                family: Theme.font
                pixelSize: 15
            }
        }

        Text {
            text: " " + SystemStats.username
            color: Theme.text
            font {
                family: Theme.font
                pixelSize: 15
            }
        }

        Text {
            text: "󰔠 " + SystemStats.uptime
            color: Theme.text
            font {
                family: Theme.font
                pixelSize: 15
            }
        }

        Text {
            text: " " + root.osAge + " days"
            color: Theme.text
            font {
                family: Theme.font
                pixelSize: 15
            }
        }
    }

    Process {
        id: osAgeProc
        command: ["stat", "-c", "%Y", "/lost+found"]
        running: true

        property int lostfoundTimestamp

        stdout: SplitParser {
            onRead: (data) => {
                osAgeProc.lostfoundTimestamp = parseInt(data)
            }
        }

        onExited: (code, status) => {
            let now = Date.now() / 1000
            root.osAge = (now - osAgeProc.lostfoundTimestamp) / 86400
        }
    }
}
