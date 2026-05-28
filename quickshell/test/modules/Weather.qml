import QtQuick

import qs.settings
import "../services" as Services

BarWidgetWrapper {
    Row {
        id: row
        spacing: 5

        Icon {
            anchors.verticalCenter: parent.verticalCenter
            icon: "mdi-weather"
            size: 20
            color: Theme.accent
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter

            text: Services.Weather.data.temp !== "∞" ? parseFloat(Services.Weather.data.temp).toFixed(1) + " °F" : "∞"
            color: Theme.accent

            font {
                family: Theme.font
                pixelSize: 13
                weight: 600
            }
        }
    }
}
