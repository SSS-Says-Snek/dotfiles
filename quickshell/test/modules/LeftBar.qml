import QtQuick
import qs.settings

Rectangle {
    id: root
    property string targetMonitor: ""

    readonly property int rowSpacing: 15

    color: "#1e1e24"
    implicitWidth: leftBar.implicitWidth + 2 * 15

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

        }

        Workspaces {
            anchors.verticalCenter: parent.verticalCenter
            targetMonitor: root.targetMonitor
        }

    }
}
