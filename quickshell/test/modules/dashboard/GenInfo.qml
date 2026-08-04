import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Widgets

import qs.modules
import qs.settings
import qs.services

Rectangle {
    color: "#a0181825"
    radius: 14

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
            text: " "
            color: Theme.text
            font {
                family: Theme.font
                pixelSize: 15
            }
        }
    }
}
