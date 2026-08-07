import Quickshell // for PanelWindow
import QtQuick

import qs.modules
import qs.settings

Scope {
    Bar {
        id: bar
    }

    Variants {
        model: Quickshell.screens

        NotifOverlay {
            required property var modelData
            screen: modelData

            anchors {
                top: true
                right: true
            }

            margins.top: Theme.barHeight + 20
            margins.right: 20
        }
    }
}
