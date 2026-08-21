import QtQuick

import qs.settings

Rectangle {
    id: root

    property string label: ""
    property string iconSource: ""
    property string leading: "" // E.g check mark or radio
    property string trailing: "" // E.g back arrow
    property bool interactive: true

    readonly property int hPad: 10
    readonly property int iconSize: 16

    signal clicked

    implicitWidth: hPad + content.implicitWidth + (trailingLabel.visible ? 8 + trailingLabel.implicitWidth : 0) + hPad
    implicitHeight: 28

    radius: 9999
    color: hover.hovered && root.interactive ? Theme.accent : "transparent"

    Behavior on color {
        ColorAnimation {
            duration: 120
            easing.type: Easing.OutQuad
        }
    }

    Row {
        id: content

        anchors.left: parent.left
        anchors.leftMargin: root.hPad
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        Image {
            anchors.verticalCenter: parent.verticalCenter

            visible: root.iconSource !== ""
            width: root.iconSize
            height: root.iconSize

            source: root.iconSource
            sourceSize.width: Math.round(root.iconSize * Screen.devicePixelRatio)
            sourceSize.height: Math.round(root.iconSize * Screen.devicePixelRatio)
            fillMode: Image.PreserveAspectFit
            asynchronous: true
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter

            visible: root.leading !== ""
            text: root.leading
            color: label.color

            font {
                family: Theme.font
                pixelSize: 12
            }
        }

        Text {
            id: label

            anchors.verticalCenter: parent.verticalCenter

            text: root.label
            color: {
                if (!root.interactive)
                    return Theme.overlay0
                return hover.hovered ? Theme.crust : Theme.text
            }

            font {
                family: Theme.font
                pixelSize: 13
                weight: 600
            }
        }
    }

    Text {
        id: trailingLabel

        anchors.right: parent.right
        anchors.rightMargin: root.hPad
        anchors.verticalCenter: parent.verticalCenter

        visible: root.trailing !== ""
        text: root.trailing
        color: label.color

        font {
            family: Theme.font
            pixelSize: 13
            weight: 600
        }
    }

    HoverHandler {
        id: hover

        enabled: root.interactive
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        enabled: root.interactive

        onTapped: root.clicked()
    }
}
