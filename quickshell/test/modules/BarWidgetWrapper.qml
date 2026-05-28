import QtQuick

import qs.settings

Rectangle {
    id: root

    implicitWidth: loader.implicitWidth + 2 * 8
    implicitHeight: loader.implicitHeight + 2 * 4

    radius: 9999

    color: hoverHandler.hovered ? Theme.surface0 : "transparent"

    default property Component child

    Loader {
        id: loader
        anchors.centerIn: parent
        sourceComponent: root.child
    }

    HoverHandler {
        id: hoverHandler
    }

    Behavior on color {
        ColorAnimation {
            duration: 200
            easing.type: Easing.OutQuad
        }
    }
}
