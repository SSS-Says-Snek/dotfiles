import QtQuick
import qs.modules
import qs.settings

import "../services" as Services

BarWidgetWrapper {
    Row {
        spacing: 5
        anchors.verticalCenter: parent.verticalCenter

        Icon {
            icon: "mdi-harddisk"
            size: 20
            color: Theme.peach
        }

        Text {
            text: Services.SystemStats.rootDisk.percentText
            color: Theme.peach

            anchors.verticalCenter: parent.verticalCenter

            font {
                family: Theme.font
                pixelSize: 13
                weight: 600
            }
        }
    }
}
