
import QtQuick
import QtQuick.Layouts

import qs.modules
import qs.settings

RowLayout {
    id: root

    required property string icon
    required property color color
    required property string text
    property int size: 16

    spacing: 6

    Icon {
        Layout.alignment: Qt.AlignVCenter
        color: root.color
        icon: root.icon
        size: root.size
    }

    Text {
        Layout.alignment: Qt.AlignVCenter
        color: root.color
        text: root.text
        font {
            family: Theme.font
            pixelSize: 14
        }
    }
}
