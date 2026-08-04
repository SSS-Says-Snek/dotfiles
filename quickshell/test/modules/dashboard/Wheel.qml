pragma ComponentBehavior: Bound

import QtQuick

Item {
    id: root

    default property list<Component> tabs

    property Component background: null

    readonly property int count: tabs.length
    readonly property real sliceAngle: count > 0 ? 360 / count : 0

    property int currentIndex: 0
    readonly property int currentTab: count > 0 ? ((currentIndex % count) + count) % count : 0

    function step(delta: int): void {
        currentIndex += delta;
    }

    rotation: -currentIndex * sliceAngle

    Behavior on rotation {
        NumberAnimation {
            duration: 500
            easing.type: Easing.OutBack
            easing.overshoot: 1.1
        }
    }

    Loader {
        anchors.fill: parent
        active: root.background !== null
        sourceComponent: root.background
    }

    Repeater {
        model: root.count

        Item {
            id: slice

            required property int index

            anchors.fill: parent
            rotation: slice.index * root.sliceAngle

            Loader {
                y: parent.height / 2
                width: parent.width
                height: parent.height / 2
                sourceComponent: root.tabs[slice.index]
            }
        }
    }
}
