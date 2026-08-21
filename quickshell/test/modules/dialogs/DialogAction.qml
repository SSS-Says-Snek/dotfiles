import QtQuick

import qs.settings

Rectangle {
    id: root

    property string label: ""
    property bool accent: false

    signal clicked

    implicitHeight: 38
    radius: 12
    opacity: enabled ? 1 : 0.4
    color: {
        if (!enabled)
            return Theme.surface0
        if (accent)
            return hover.hovered ? Qt.lighter(Theme.blue, 1.1) : Theme.blue
        return hover.hovered ? Theme.dashboardBg : Theme.surface0
    }

    Behavior on color {
        ColorAnimation {
            duration: 120
            easing.type: Easing.OutQuad
        }
    }

    Text {
        anchors.centerIn: parent
        text: root.label
        color: root.accent ? (root.enabled ? Theme.base : Theme.overlay2) : Theme.text
        font {
            family: Theme.font
            pixelSize: 14
            weight: 500
        }
    }

    HoverHandler {
        id: hover

        enabled: root.enabled
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        enabled: root.enabled
        onTapped: root.clicked()
    }
}
