pragma ComponentBehavior: Bound

import QtQuick

import qs.services
import qs.settings

Item {
    id: root

    GridView {
        id: grid

        anchors.fill: parent
        clip: true
        model: Audio.allSources

        cellWidth: width / 2
        cellHeight: {
            const rows = Math.max(1, Math.ceil(count / 2));
            return Math.max(cellWidth, height / rows);
        }

        delegate: AudioSinkSource {
            id: wrap

            width: grid.cellWidth
            height: grid.cellHeight
            fallbackIcon: "mdi-microphone"
            selected: Audio.source && modelData && Audio.source.id === modelData.id
            onClicked: Audio.setSource(modelData)
        }
    }

    Text {
        anchors.centerIn: parent
        visible: grid.count === 0
        text: "No audio inputs"
        color: Theme.subtext
        font {
            family: Theme.font
            pixelSize: 14
        }
    }
}
