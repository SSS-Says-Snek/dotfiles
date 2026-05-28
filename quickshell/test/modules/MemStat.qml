import QtQuick
import qs.modules
import qs.settings

import "../services" as Services

BarWidgetWrapper {
    Row {
        spacing: 5
        anchors.verticalCenter: parent.verticalCenter

        Icon {
            icon: "mdi-mem"
            size: 20
            color: Theme.green
        }

        Text {
            text: `${Math.round(Services.SystemStats.memPercent)}%`
            color: Theme.green

            anchors.verticalCenter: parent.verticalCenter

            font {
                family: Theme.font
                pixelSize: 13
                weight: 600
            }
        }
    }
}
