pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs.services
import qs.settings
import qs.modules.notif

Item {
    id: root

    GridLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        columns: 2
        columnSpacing: 20
        rowSpacing: 20

        ControlButton {
            Layout.fillWidth: true
            icon: "mdi-dashboard"
            text: "Control Panel"
            active: true
            hasSubmenu: true
        }

        ControlButton {
            Layout.fillWidth: true
            icon: "mdi-dashboard"
            text: "Control Panel"
            hasSubmenu: true
        }

        ControlButton {
            Layout.fillWidth: true
            icon: "mdi-dashboard"
            text: "Control Panel"
        }

        ControlButton {
            Layout.fillWidth: true
            icon: "mdi-dashboard"
            text: "Control Panel"
        }

        ControlButton {
            Layout.fillWidth: true
            icon: "mdi-dashboard"
            text: "Control Panel"
        }

        ControlButton {
            Layout.fillWidth: true
            icon: "mdi-dashboard"
            text: "Control Panel"
        }
    }
}
