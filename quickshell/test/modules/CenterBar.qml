import Quickshell
import QtQuick

Rectangle {
    id: root
    property string targetMonitor: ""

    readonly property int rowSpacing: 10

    color: "#1e1e24"
    implicitWidth: centerBar.implicitWidth + 2 * rowSpacing

    radius: 9999

    Row {
        id: centerBar
        anchors.fill: parent
        spacing: root.rowSpacing
        anchors.leftMargin: root.rowSpacing

        Clock {
            anchors.verticalCenter: parent.verticalCenter
            onClicked: popup.expanded = !popup.expanded
        }

        Weather {
            anchors.verticalCenter: parent.verticalCenter
            onClicked: popup.expanded = !popup.expanded
        }
    }

    TapHandler {
        onTapped: popup.expanded = !popup.expanded
    }

    CenterPopup {
        id: popup

        anchorItem: root
    }
}
