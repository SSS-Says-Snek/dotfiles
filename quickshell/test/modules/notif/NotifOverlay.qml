pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.services

PanelWindow {
    id: root
    WlrLayershell.layer: WlrLayer.Overlay

    implicitWidth: 420
    implicitHeight: Math.max(1, list.contentHeight)
    color: "transparent"

    exclusionMode: ExclusionMode.Ignore

    ListView {
        id: list

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: contentHeight

        model: NotifServer.trackedNotifications
        verticalLayoutDirection: ListView.BottomToTop
        interactive: false
        clip: false
        spacing: 0

        delegate: Item {
            id: wrap

            required property var modelData
            required property int index

            width: list.width
            height: notif.height

            Notif {
                id: notif

                width: parent.width
                index: wrap.index
                summary: wrap.modelData.summary
                body: wrap.modelData.body
                appName: wrap.modelData.appName
                image: wrap.modelData.image || ""
                appIcon: wrap.modelData.appIcon || ""
                time: new Date()
                urgency: wrap.modelData.urgency

                onDismiss: {
                    wrap.modelData.dismiss()
                }
                onExplicitDismiss: {
                    NotifServer.forget(index)
                    wrap.modelData.dismiss()
                }
            }
        }
    }
}
