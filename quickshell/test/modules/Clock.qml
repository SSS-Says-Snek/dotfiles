import QtQuick
import qs.modules
import qs.settings
import qs.services

BarWidgetWrapper {
    Row {
        spacing: 5
        anchors.verticalCenter: parent.verticalCenter

        Icon {
            icon: "clock/2"
            size: 20
            color: Theme.mauve
        }

        Text {
            text: Time.time
            color: Theme.mauve

            anchors.verticalCenter: parent.verticalCenter

            font {
                family: Theme.font
                pixelSize: 13
                weight: 600
            }
        }
    }
}
