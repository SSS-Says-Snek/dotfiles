import QtQuick
import Quickshell
import QtQuick.Effects

import qs.settings

Item {
    id: root

    property int size: 24
    property string icon: ""
    property color color: Theme.text
    property bool interactive: false

    readonly property bool hovered: hover.hovered

    signal clicked()

    implicitWidth: size
    implicitHeight: size

    scale: interactive && hovered ? 1.15 : 1.0
    opacity: enabled ? 1 : 0.35

    Behavior on scale {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutQuad
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutQuad
        }
    }

    Image {
        id: image
        anchors.fill: parent

        source: Quickshell.shellPath("assets/" + root.icon + ".svg")
        sourceSize.width: Math.round(root.size * Screen.devicePixelRatio)
        sourceSize.height: Math.round(root.size * Screen.devicePixelRatio)
        asynchronous: true

        visible: false
    }

    MultiEffect {
        anchors.fill: parent

        source: image
        colorization: 1.0
        colorizationColor: root.interactive && root.hovered ? Theme.accent : root.color

        Behavior on colorizationColor {
            ColorAnimation {
                duration: 150
                easing.type: Easing.OutQuad
            }
        }
    }

    HoverHandler {
        id: hover
        enabled: root.interactive
        cursorShape: root.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
    }

    TapHandler {
        enabled: root.interactive && root.enabled
        onTapped: root.clicked()
    }
}
