import QtQuick
import QtQuick.Effects
import qs.settings

Rectangle {
    id: root
    property string targetMonitor: ""

    readonly property int rowSpacing: 10

    color: "#1e1e24"
    implicitWidth: centerBar.implicitWidth + 2 * rowSpacing

    anchors.leftMargin: root.rowSpacing
    radius: 9999

    Row {
        id: centerBar
        anchors.fill: parent
        spacing: root.rowSpacing
        anchors.leftMargin: root.rowSpacing

        Clock {
            anchors.verticalCenter: parent.verticalCenter
        }

        Weather {
            anchors.verticalCenter: parent.verticalCenter
        }

        HoverHandler {
            id: centerArea
        }
    }
}
