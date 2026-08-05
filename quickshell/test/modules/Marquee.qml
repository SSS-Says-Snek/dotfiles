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

    readonly property bool overflowing: metrics.width > width

    width: 220
    implicitHeight: metrics.height
    clip: true

    TextMetrics {
        id: metrics
        text: root.text
        font: label.font
    }

    Row {
        id: row

        spacing: root.gap
        // center when it fits, start flush left for the scroll.
        x: root.overflowing ? 0 : (root.width - metrics.width) / 2

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
        running: root.overflowing && root.visible && root.text.length > 0
        loops: Animation.Infinite

        PauseAnimation {
            duration: root.pauseMs
        }
        NumberAnimation {
            target: row
            property: "x"
            from: 0
            to: -(metrics.width + root.gap)
            duration: Math.max(1, Math.round((metrics.width + root.gap) / root.pixelsPerSecond * 1000))
            easing.type: Easing.Linear
        }
        PauseAnimation {
            duration: root.pauseMs / 2
        }

        onRunningChanged: if (!running)
            row.x = root.overflowing ? 0 : (root.width - metrics.width) / 2
    }

    onOverflowingChanged: {
        scroll.restart()
        if (!overflowing)
            row.x = (root.width - metrics.width) / 2
    }

    onTextChanged: scroll.restart()
}
