import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Widgets

import qs.modules

Rectangle {
    color: "#a0181825"
    radius: 14

    GridLayout {
        rows: 4
        columns: 2
        columnSpacing: 30
        anchors.margins: 20
        anchors.fill: parent

        ColumnLayout {
            Layout.row: 0
            Layout.column: 0
            Layout.rowSpan: 4

            ClippingRectangle {
                id: avatar

                width: 140
                height: 140
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

        Rectangle {
            width: 150
            height: 20
        }
        Rectangle {
            width: 100
            height: 20
        }
        Rectangle {
            width: 100
            height: 20
        }
        Rectangle {
            width: 100
            height: 20
        }
    }
}
