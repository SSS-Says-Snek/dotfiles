import QtQuick
import qs.modules
import qs.settings

import "../services" as Services

BarWidgetWrapper {
    Row {
        spacing: 5
        anchors.verticalCenter: parent.verticalCenter

        Icon {
            id: icon
            icon: "tabler-vinyl"
            size: 20
            color: Theme.accent

            states: [
                State {
                    name: "spinning"
                    when: Services.MprisController.isPlaying
                    PropertyChanges { target: icon; rotation: icon.rotation + 360 }
                },
                State {
                    name: "stopped"
                    when: !Services.MprisController.isPlaying
                    PropertyChanges { target: icon; rotation: icon.rotation }
                }
            ]

            transitions: [
                Transition {
                    from: "stopped"; to: "spinning"
                    PropertyAnimation {
                        target: icon
                        property: "rotation"
                        duration: 5000
                        loops: Animation.Infinite
                    }
                },

                Transition {
                    from: "spinning"; to: "stopped"
                    PropertyAnimation {
                        target: icon
                        property: "rotation"
                        duration: 1000
                    }
                }
            ]
        }

        Item {
            id: wrap
            width: Math.min(250, text.implicitWidth)
            implicitHeight: text.implicitHeight
            anchors.verticalCenter: parent.verticalCenter

            readonly property bool isOverflowing: text.implicitWidth > wrap.width

            clip: true

            Text {
                id: text
                text: Services.MprisController.activeTrack.title
                color: Theme.accent

                wrapMode: Text.NoWrap
                anchors.verticalCenter: parent.verticalCenter

                font {
                    family: Theme.font
                    pixelSize: 13
                    weight: 600
                }

                NumberAnimation on x {
                    id: scrollAnimation
                    from: wrap.width
                    to: -text.implicitWidth
                    duration: 12000
                    loops: Animation.Infinite
                    running: wrap.isOverflowing && text.text !== ""
                }
            }
        }
    }
}
