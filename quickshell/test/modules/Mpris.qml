import QtQuick
import qs.modules
import qs.settings

import "../services" as Services

BarWidgetWrapper {
    id: root
    readonly property int maxTitleLength: 25

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

        Text {
            id: text
            text: title.length < maxTitleLength + 3 ? title : title.substring(0, maxTitleLength) + "..." // + 3 for ellipsis
            color: Theme.accent

            readonly property string title: Services.MprisController.activeTrack.title

            wrapMode: Text.NoWrap
            anchors.verticalCenter: parent.verticalCenter

            font {
                family: Theme.font
                pixelSize: 13
                weight: 600
            }
        }
    }
}
