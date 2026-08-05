import QtQuick
import QtQuick.Layouts

import qs.settings
import qs.services
import qs.modules

Item {
    id: root

    // Deg F
    property real minTemp: 0
    property real maxTemp: 110
    property real thickness: 24

    readonly property real ringRadius: (Math.min(width, height) - thickness) / 2

    readonly property real progress: Audio.value / Audio.maxVolume
    readonly property color ringColor: Audio.sinkMuted ? Theme.overlay0 : Theme.peach

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: Theme.dashboardBg

        ProgressRing {
            baseColor: Theme.surface0
            accentColor: root.ringColor
            thickness: root.thickness
            ringRadius: root.ringRadius
            progress: root.progress
            transparentBg: true

            startAngle: 330
            sweep: -270
            interactive: true
            onMoved: value => Audio.setVolume(value * Audio.maxVolume)
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 0
        spacing: -5
        //
        // ColumnLayout {
        //     Layout.alignment:  Qt.AlignHCenter
        //     spacing: -2
        //
        //     Text {
        //         Layout.alignment:  Qt.AlignHCenter
        //         text: Math.round(Audio.value * 100) + "%"
        //         color: root.ringColor
        //
        //         font {
        //             family: Theme.font
        //             pixelSize: 14
        //         }
        //     }
        //
        //     Text {
        //         visible: Audio.sinkMuted
        //         Layout.alignment:  Qt.AlignHCenter
        //         text: "Muted"
        //         color: root.ringColor
        //
        //         font {
        //             family: Theme.font
        //             pixelSize: 14
        //         }
        //     }
        // }

        Text {
            Layout.alignment:  Qt.AlignHCenter
            text: Audio.sinkMuted ? "󰝟" : "󰕾"
            color: hoverHandler.hovered ? Theme.yellow : root.ringColor

            font {
                family: Theme.font
                pixelSize: Math.round(Math.min(root.width, root.height) * 0.40)
            }

            HoverHandler {
                id: hoverHandler
                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                onTapped: Audio.toggleMute()
            }

            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.OutQuad
                }
            }
        }

    }
}
