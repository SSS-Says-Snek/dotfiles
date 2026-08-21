import QtQuick
import QtQuick.Layouts

import qs.settings

Rectangle {
    id: root

    property int index: -1
    required property var modelData
    property string status: ""

    radius: 16
    color: hover.hovered ? Theme.dashboardBg : "#80000000"

    signal clicked()

    Behavior on color {
        ColorAnimation {
            duration: 120
            easing.type: Easing.OutQuad
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 12

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: root.modelData.ssid
                color: Theme.text
                elide: Text.ElideRight
                font {
                    family: Theme.font
                    pixelSize: 14
                    weight: 700
                }
            }

            Text {
                Layout.fillWidth: true
                text: root.status
                color: root.status == "Connected" ? Theme.green : Theme.subtext
                font {
                    family: Theme.font
                    pixelSize: 12
                }
            }
        }

        Text {
            text: "▂▄▆█".slice(0, Math.max(1, root.modelData.icon))
            color: Theme.overlay1
            font {
                family: Theme.font
                pixelSize: 12
            }
        }
    }

    HoverHandler {
        id: hover

        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        id: tap
        onTapped: root.clicked()
    }
}
