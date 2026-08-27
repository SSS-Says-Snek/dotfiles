import Quickshell // for PanelWindow
import QtQuick

import qs.modules
import qs.modules.notif
import qs.modules.dialogs
import qs.settings
import qs.services

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

    Variants {
        model: Quickshell.screens

        DialogHost {
            required property var modelData
            screen: modelData
        }
    }

    Component.onCompleted: {
        let _forceload = Wallpaper._forceload
    }
}
