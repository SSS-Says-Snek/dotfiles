import QtQuick

import qs.settings

Rectangle {
    id: root

    implicitWidth: loader.implicitWidth + 2 * 8
    implicitHeight: loader.implicitHeight + 2 * 4

    radius: 9999

    color: hoverHandler.hovered ? Theme.surface0 : "transparent"

    default property Component child
    signal clicked()
    signal wheel(WheelEvent event)

    Loader {
        id: loader
        anchors.centerIn: parent
        sourceComponent: root.child
    }

    HoverHandler {
        id: hoverHandler
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        onWheel: (event) => {
            root.wheel(event)
        }
        onClicked: root.clicked()
    }

    Behavior on color {
        ColorAnimation {
            duration: 200
            easing.type: Easing.OutQuad
        }
    }
}
