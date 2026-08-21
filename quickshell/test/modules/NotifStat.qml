import QtQuick
import qs.modules
import qs.settings

import qs.services

BarWidgetWrapper {
    cursorShape: Qt.PointingHandCursor

    Row {
        spacing: 5
        anchors.verticalCenter: parent.verticalCenter

        Icon {
            icon: NotifServer.doNotDisturb ? "mdi-notif-off" : "mdi-notif"
            size: 20
            color: Theme.text
        }

        Text {
            text: NotifServer.history.count
            color: Theme.text

            anchors.verticalCenter: parent.verticalCenter

            font {
                family: Theme.font
                pixelSize: 13
                weight: 600
            }
        }
    }
}
