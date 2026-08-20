pragma ComponentBehavior: Bound

import QtQuick

import qs.services
import qs.settings
import qs.modules.notif

Item {
    id: root

    readonly property int headerHeight: 28

    property bool closeAll: false

    Text {
        id: clearAll

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: 4
        height: root.headerHeight

        visible: list.count > 0
        verticalAlignment: Text.AlignVCenter
        text: "Clear All"
        color: clearHover.hovered ? Theme.accent : Theme.subtext

        font {
            family: Theme.font
            pixelSize: 14
        }

        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }

        HoverHandler {
            id: clearHover

            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped: {
                root.closeAll = true
                resetCloseAll.restart()
            }
        }

        Timer {
            id: resetCloseAll
            interval: 100
            onTriggered: root.closeAll = false
        }
    }

    ListView {
        id: list

        anchors.top: parent.top
        anchors.topMargin: list.count > 0 ? root.headerHeight : 0
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
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

            externalClose: root.closeAll

            // forget() also releases the notification's retain lock.
            onExplicitDismiss: {
                NotifServer.forget(entry.index)
            }
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
