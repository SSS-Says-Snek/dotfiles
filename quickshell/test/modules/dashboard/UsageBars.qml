import QtQuick
import QtQuick.Layouts

import qs.settings
import qs.modules
import qs.services

Rectangle {
    id: root
    color: Theme.dashboardBg
    radius: 14

    readonly property int barWidth: 20
    readonly property int barRadius: 10

    RowLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 20

        ColumnLayout {
            Layout.fillHeight: true

            ProgressBar {
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignCenter
                accentColor: Theme.yellow
                barWidth: 15
                progress: SystemStats.cpuTemp / 100
            }

            Icon {
                Layout.alignment: Qt.AlignCenter

                icon: "clarity-thermometer"
                size: 20
                color: Theme.yellow
            }
        }

        ColumnLayout {
            Layout.fillHeight: true

            ProgressBar {
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignCenter

                accentColor: Theme.sapphire
                progress: SystemStats.cpuPercent / 100
                barWidth: 15
            }

            Icon {
                Layout.alignment: Qt.AlignCenter

                icon: "tabler-cpu"
                size: 20
                color: Theme.sapphire
            }
        }

        ColumnLayout {
            Layout.fillHeight: true

            ProgressBar {
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignCenter

                accentColor: Theme.green
                progress: SystemStats.memPercent / 100
                barWidth: 15
            }

            Icon {
                Layout.alignment: Qt.AlignCenter

                icon: "mdi-mem"
                size: 20
                color: Theme.green
            }
        }
    }
}
