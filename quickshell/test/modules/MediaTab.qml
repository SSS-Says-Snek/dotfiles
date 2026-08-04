import QtQuick

import qs.settings

// Dummy test from Claude
Item {
    id: root

    implicitWidth: content.implicitWidth
    implicitHeight: content.y + content.implicitHeight

    Column {
        id: content

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 28
        spacing: 14

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 14

            Rectangle {
                width: 72
                height: 72
                radius: width / 2
                color: Theme.sapphire
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Rectangle {
                    width: 140
                    height: 14
                    radius: height / 2
                    color: Theme.surface2
                }

                Rectangle {
                    width: 96
                    height: 12
                    radius: height / 2
                    color: Theme.surface1
                }

                Rectangle {
                    width: 160
                    height: 6
                    radius: height / 2
                    color: Theme.surface0
                }
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 16

            Repeater {
                model: 3

                Rectangle {
                    required property int index

                    anchors.verticalCenter: parent.verticalCenter
                    width: index === 1 ? 40 : 28
                    height: width
                    radius: width / 2
                    color: index === 1 ? Theme.mauve : Theme.surface1
                }
            }
        }
    }
}
