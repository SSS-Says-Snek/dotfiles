import QtQuick

import qs.settings

Item {
    id: root

    property string text: ""
    property color color: Theme.text
    property int pixelSize: 14
    property int weight: Font.Normal
    property int gap: 40
    property int pauseMs: 0
    property int pixelsPerSecond: 40

    readonly property real textWidth: label.implicitWidth
    readonly property bool overflowing: textWidth > width && text.length > 0

    property real scrollOffset: 0

    width: 220
    implicitHeight: label.implicitHeight
    clip: true

    Row {
        id: row

        spacing: root.gap
        x: root.overflowing ? root.scrollOffset : (root.width - root.textWidth) / 2

        Text {
            id: label
            text: root.text
            color: root.color
            font {
                family: Theme.font
                pixelSize: root.pixelSize
                weight: root.weight
            }
        }

        Text {
            visible: root.overflowing
            text: root.text
            color: root.color
            font: label.font
        }
    }

    SequentialAnimation {
        id: scroll

        running: root.overflowing && root.visible
        loops: Animation.Infinite

        PropertyAction {
            target: root
            property: "scrollOffset"
            value: 0
        }
        PauseAnimation {
            duration: root.pauseMs
        }
        NumberAnimation {
            target: root
            property: "scrollOffset"
            from: 0
            to: -(root.textWidth + root.gap)
            duration: Math.max(1, Math.round((root.textWidth + root.gap) / root.pixelsPerSecond * 1000))
            easing.type: Easing.Linear
        }
        PauseAnimation {
            duration: root.pauseMs / 2
        }

        onRunningChanged: if (!running)
            root.scrollOffset = 0
    }

    onTextChanged: {
        root.scrollOffset = 0;
        if (scroll.running)
            scroll.restart();
    }
}
