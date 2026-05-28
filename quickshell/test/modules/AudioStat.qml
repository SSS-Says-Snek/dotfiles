import QtQuick
import qs.modules
import qs.settings

import "../services" as Services

BarWidgetWrapper {
    Row {
        id: row
        spacing: 5
        anchors.verticalCenter: parent.verticalCenter

        property string overallColor: Services.Audio.sinkMuted ? Theme.text : Theme.peach

        Icon {
            icon: "mdi-speakerphone"
            size: 20
            color: row.overallColor

            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.OutQuad
                }
            }
        }

        Icon {
            icon: Services.Audio.micMuted ? "mdi-microphone-off" : "mdi-microphone"
            size: 20
            color: row.overallColor

            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.OutQuad
                }
            }
        }

        Text {
            text: `${Math.round(Services.Audio.value * 100)}%`
            color: row.overallColor

            anchors.verticalCenter: parent.verticalCenter

            font {
                family: Theme.font
                pixelSize: 13
                weight: 600
            }

            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.OutQuad
                }
            }
        }
    }

    onWheel: (event) => {
        if (event.angleDelta.y > 0) {
            Services.Audio.incVolume()
        } else {
            Services.Audio.decVolume()
        }
    }
}
