import QtQuick
import QtQuick.Layouts

import qs.settings

Rectangle {
    id: root

    default property alias content: body.data
    property string title: ""

    implicitWidth: 400
    implicitHeight: col.implicitHeight + 40
    width: implicitWidth

    radius: 20
    color: "#1e1e24"
    border.width: 2
    border.color: Theme.accent

    ColumnLayout {
        id: col

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 20
        spacing: 14

        Text {
            Layout.fillWidth: true
            visible: root.title !== ""
            text: root.title
            color: Theme.text
            wrapMode: Text.WordWrap
            font {
                family: Theme.font
                pixelSize: 18
                weight: 800
            }
        }

        ColumnLayout {
            id: body

            Layout.fillWidth: true
            spacing: 12
        }
    }
}
