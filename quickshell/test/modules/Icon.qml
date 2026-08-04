import QtQuick
import Quickshell
import QtQuick.Effects

Item {
    id: root

    property int size: 24
    property string icon: ""
    property string color: ""

    implicitWidth: size
    implicitHeight: size

    Image {
        id: image
        anchors.fill: parent

        source: Quickshell.shellPath("assets/" + root.icon + ".svg")
        asynchronous: true

        visible: false
    }

    MultiEffect {
        anchors.fill: parent

        source: image
        colorization: 1.0
        colorizationColor: root.color
    }
}
