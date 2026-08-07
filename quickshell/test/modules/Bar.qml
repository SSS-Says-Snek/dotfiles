pragma ComponentBehavior: Bound

import Quickshell
import QtQuick

import qs.modules
import qs.settings

Variants {
    model: Quickshell.screens;

    PanelWindow {
        required property var modelData
        screen: modelData
        id: panelWindow

        anchors {
            top: true
            left: true
            right: true
        }

        implicitHeight: Theme.barHeight

        color: "transparent"

        LeftBar {
            implicitHeight: panelWindow.implicitHeight
            targetMonitor: panelWindow.modelData.name
        }

        CenterBar {
            id: centerBar
            implicitHeight: panelWindow.implicitHeight
            anchors.centerIn: parent
        }

        RightBar {
            implicitHeight: panelWindow.implicitHeight
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
