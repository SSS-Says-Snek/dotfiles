import QtQuick

import qs.settings

Item {
    id: root

    property real progress
    property int barRadius: 20
    property int barWidth: 20

    property color baseColor: Theme.surface0
    property color accentColor: Theme.mauve

    implicitWidth: barWidth

    Rectangle {
        id: bar

        anchors.fill: parent
        color: root.baseColor
        radius: root.barRadius

        Rectangle {
            width: parent.width
            y: parent.height - height
            height: parent.height * Math.max(0, Math.min(1, root.progress))

            color: root.accentColor
            radius: root.barRadius

            Behavior on height {
                NumberAnimation {
                    duration: 400
                    easing: Easing.OutCubic
                }
            }
        }
    }
}
