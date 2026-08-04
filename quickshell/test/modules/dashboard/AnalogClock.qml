pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

import qs.modules
import qs.services
import qs.settings

Item {
    id: root

    property color accent: Theme.mauve

    readonly property date now: Time.date
    readonly property real plateRadius: Math.min(width, height) / 2

    function fade(base, alpha) {
        const c = Qt.color(base);

        return Qt.rgba(c.r, c.g, c.b, alpha);
    }

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: "#a0181825"
    }

    // Inner circle
    Rectangle {
        anchors.centerIn: parent
        width: parent.width - 34
        height: width
        radius: width / 2
        color: "transparent"
        border.width: 1
        border.color: root.fade(Theme.text, 0.12)
    }

    // Outer engravings
    Repeater {
        model: 60

        Item {
            id: tick

            required property int index

            readonly property bool isHour: index % 5 === 0
            readonly property bool isCardinal: index % 15 === 0

            anchors.fill: parent
            rotation: index * 6

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                y: 10

                visible: !tick.isCardinal
                width: tick.isHour ? 2 : 1
                height: tick.isHour ? 9 : 4
                color: root.fade(Theme.text, tick.isHour ? 0.55 : 0.25)
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                y: 9

                visible: tick.isCardinal
                width: 7
                height: 7
                rotation: 45
                color: root.fade(root.accent, 0.85)
            }
        }
    }

    // Hr hand
    Item {
        anchors.fill: parent
        rotation: 30 * (root.now.getHours() % 12) + 0.5 * root.now.getMinutes()

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height / 2 - height

            width: 5
            height: root.plateRadius * 0.5
            radius: width / 2
            color: Theme.text
        }
    }

    // Minute hand 
    Item {
        anchors.fill: parent
        rotation: 6 * root.now.getMinutes() + 0.1 * root.now.getSeconds()

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height / 2 - height

            width: 3
            height: root.plateRadius * 0.74
            radius: width / 2
            color: Theme.text
        }
    }

    // Second hand
    Item {
        anchors.fill: parent
        rotation: 6 * root.now.getSeconds()

        // Drawn past the pivot so the hand reads as balanced on its point.
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height / 2 - height + root.plateRadius * 0.16

            width: 1.5
            height: root.plateRadius * 0.82 + root.plateRadius * 0.16
            radius: width / 2
            color: root.accent
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: 9
        height: width
        radius: width / 2
        color: Theme.text

        Rectangle {
            anchors.centerIn: parent
            width: 3
            height: width
            radius: width / 2
            color: Theme.crust
        }
    }
}
