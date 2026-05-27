pragma ComponentBehavior: Bound

import Quickshell
import QtQuick

import qs.modules
import qs.settings

Scope {
    id: root
    property string time

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

            Clock {
                anchors.centerIn: parent
            }
        }
    }
}
