import QtQuick
import Quickshell
import QtQuick.VectorImage
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

        layer.enabled: true
        layer.effect: MultiEffect {
            colorization: 1.0
            colorizationColor: root.color
        }
    }
}
