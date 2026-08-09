pragma ComponentBehavior: Bound

import QtQuick

import qs.services
import qs.settings

Item {
    id: root

    ListView {
        id: list

        anchors.fill: parent
        topMargin: 8
        bottomMargin: 8
        clip: true
        spacing: 0
        interactive: true
        verticalLayoutDirection: ListView.TopToBottom

        model: NotifServer.history

        delegate: Notif {
            id: entry

            width: list.width
            autoClose: false

            onExplicitDismiss: NotifServer.history.remove(entry.index)
        }

        Text {
            anchors.centerIn: parent
            visible: list.count === 0
            text: "No notifications"
            color: Theme.subtext
            font {
                family: Theme.font
                pixelSize: 14
            }
        }
    }
}
