import QtQuick
import qs.modules
import qs.settings

import "../services" as Services

BarWidgetWrapper {
    Row {
        spacing: 5
        anchors.verticalCenter: parent.verticalCenter

        Icon {
            icon: "tabler-cpu"
            size: 20
            color: Theme.sapphire
        }

        Text {
            text: `${Math.round(Services.SystemStats.cpuPercent)}%`
            color: Theme.sapphire

            anchors.verticalCenter: parent.verticalCenter

            font {
                family: Theme.font
                pixelSize: 13
                weight: 600
            }
        }
    }
}
