import QtQuick
import QtQuick.Layouts

import Quickshell

import qs.modules

import qs.services
import qs.settings

Item {
    id: root

    required property var modelData
    required property int index
    property string fallbackIcon: ""

    required property bool selected
    readonly property string themeIcon: {
        const name = Audio.nodeIconName(modelData)
        if (!name)
            return ""
        return Quickshell.iconPath(name, true)
    }
    readonly property string label: modelData.nickname || modelData.description || modelData.name || "Input"

    signal clicked()

    Rectangle {
        id: card

        anchors.fill: parent
        anchors.margins: 8
        radius: 24
        color: root.selected ? Qt.alpha(Theme.blue, 0.8) : (hover.hovered ? Theme.dashboardBg : "#80000000")

        Behavior on color {
            ColorAnimation {
                duration: 160
                easing.type: Easing.OutQuad
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Image {
                    id: themeImage

                    anchors.centerIn: parent
                    width: Math.min(parent.width, parent.height, 96)
                    height: width
                    visible: root.themeIcon !== "" && status === Image.Ready
                    source: root.themeIcon
                    sourceSize.width: Math.round(width * Screen.devicePixelRatio)
                    sourceSize.height: Math.round(height * Screen.devicePixelRatio)
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    smooth: true
                }

                Icon {
                    anchors.centerIn: parent
                    visible: !themeImage.visible
                    icon: root.fallbackIcon
                    size: Math.min(parent.width, parent.height, 72)
                    color: root.selected ? Theme.base : Theme.text
                }
            }

            Text {
                Layout.fillWidth: true
                text: root.label
                color: root.selected ? Theme.base : Theme.text
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                maximumLineCount: 2
                wrapMode: Text.WordWrap
                font {
                    family: Theme.font
                    pixelSize: 14
                    weight: 700
                }
            }
        }

        HoverHandler {
            id: hover
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped: root.clicked()
        }
    }
}
