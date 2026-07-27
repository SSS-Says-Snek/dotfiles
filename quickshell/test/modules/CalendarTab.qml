import QtQuick

import qs.settings

// Dummy from Claude
Item {
    id: root

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 24
        spacing: 10

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 120
            height: 22
            radius: height / 2
            color: Theme.surface1
        }

        Grid {
            anchors.horizontalCenter: parent.horizontalCenter
            columns: 7
            spacing: 5

            Repeater {
                model: 28

                Rectangle {
                    required property int index

                    width: 22
                    height: 22
                    radius: 6
                    color: index === 12 ? Theme.mauve : Theme.surface0
                }
            }
        }
    }
}
