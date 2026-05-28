import QtQuick
import qs.modules
import qs.settings

import "../services" as Services

BarWidgetWrapper {
    Row {
        spacing: 5
        anchors.verticalCenter: parent.verticalCenter

        Icon {
            icon: "clarity-thermometer"
            size: 20
            color: Theme.yellow
        }

        Text {
            text: `${Services.SystemStats.cpuTemp}°C`
            color: Theme.yellow

            anchors.verticalCenter: parent.verticalCenter

            font {
                family: Theme.font
                pixelSize: 13
                weight: 600
            }
        }
    }
}
