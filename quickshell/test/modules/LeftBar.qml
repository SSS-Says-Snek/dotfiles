pragma ComponentBehavior: Bound
import QtQuick
import qs.settings

Rectangle {
    id: root
    property string targetMonitor: ""

    readonly property int rowSpacing: 15

    color: "#1e1e24"
    implicitWidth: leftBar.implicitWidth + 2 * rowSpacing

    anchors.left: parent.left
    anchors.leftMargin: root.rowSpacing
    radius: 9999

    Row {
        id: leftBar
        anchors.fill: parent
        spacing: root.rowSpacing
        anchors.leftMargin: 15

        Image {
            id: archLogo
            source: "/home/bdon/.config/waybar/images/arch-logo.png"
            anchors.verticalCenter: parent.verticalCenter
            width: 25
            height: 25
            sourceSize.width: Math.round(width * Screen.devicePixelRatio)
            sourceSize.height: Math.round(height * Screen.devicePixelRatio)
            asynchronous: true
        }

        Workspaces {
            anchors.verticalCenter: parent.verticalCenter
            targetMonitor: root.targetMonitor
        }

        Mpris {
            id: mpris
            anchors.verticalCenter: parent.verticalCenter
            onClicked: popup.expanded = !popup.expanded
        }
    }

    // Outside the Row so it isn't treated as a layout child (same as CenterBar → CenterPopup).
    MediaPopup {
        id: popup
        anchorItem: mpris
    }
}
