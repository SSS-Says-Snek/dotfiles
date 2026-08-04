import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts

import qs.settings
import qs.services
import qs.modules

Item {
    id: root

    // Deg F
    property real minTemp: 0
    property real maxTemp: 110
    property real thickness: 24


    readonly property real ringRadius: (Math.min(width, height) - thickness) / 2

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: Theme.dashboardBg

        ProgressRing {
            baseColor: Theme.surface0
            accentColor: Theme.peach
            thickness: root.thickness
            ringRadius: root.ringRadius
            progress: 1

            startAngle: -30
            sweep: -190
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 0
        spacing: -5

        ColumnLayout {
            Layout.alignment:  Qt.AlignHCenter
            spacing: -2

            // Text {
            //     Layout.alignment:  Qt.AlignHCenter
            //     text: Math.round(Weather.data.temp) + "°F"
            //     color: root.tempColor
            //
            //     font {
            //         family: Theme.font
            //         pixelSize: 14
            //     }
            // }
            //
            // Text {
            //     Layout.alignment:  Qt.AlignHCenter
            //     text: Weather.text
            //     color: root.tempColor
            //
            //     font {
            //         family: Theme.font
            //         pixelSize: 14
            //     }
            // }
        }

        Text {
            Layout.alignment:  Qt.AlignHCenter
            text: ""
            color: Theme.peach

            font {
                family: Theme.font
                pixelSize: Math.round(Math.min(root.width, root.height) * 0.40)
            }
        }

    }
}
