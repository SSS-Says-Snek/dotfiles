pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.services

PanelWindow {
    id: root

    visible: Dialogs.visible
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: Dialogs.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors {
        left: true
        right: true
        top: true
        bottom: true
    }

    function componentFor(kind: string): Component {
        switch (kind) {
        case "wifiPassword":
            return wifiPasswordDialog;
        default:
            return null;
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Dialogs.dimColor
        //
        // TapHandler {
        //     onTapped: Dialogs.dismiss()
        // }
    }

    Loader {
        id: card

        z: 1
        anchors.centerIn: parent
        active: Dialogs.visible && Dialogs.kind !== ""
        sourceComponent: root.componentFor(Dialogs.kind)
    }

    Component {
        id: wifiPasswordDialog

        WifiPasswordDialog {}
    }
}
