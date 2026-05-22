pragma ComponentBehavior: Bound

import Quickshell
import QtQuick

import qs.modules

Scope {
    id: root
    property string time

    Variants {
        model: Quickshell.screens;

        PanelWindow {
            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 30

            Clock {
                anchors.centerIn: parent
            }
        }
    }
}
