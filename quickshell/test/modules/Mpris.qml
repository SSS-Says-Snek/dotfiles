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

            NumberAnimation on rotation {
                from: 0
                to: 360
                duration: 5000
                loops: Animation.Infinite
                running: true
                paused: !Services.MprisController.isPlaying
            }
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
