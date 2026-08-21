import QtQuick
import QtQuick.Layouts

import qs.settings
import qs.modules

Rectangle {
    id: root

    property string icon
    property string text
    property bool selected

    signal clicked

    color: hoverHandler.hovered ? Theme.dashboardBg : "transparent"
    radius: 10

    implicitWidth: dashCol.implicitWidth
    implicitHeight: dashCol.implicitHeight

    HoverHandler {
        id: hoverHandler
    }

    TapHandler {
        onTapped: {
            root.clicked()
            clickAnim.start()
        }
    }

    ColorAnimation {
        id: clickAnim
        duration: 600
        easing.type: Easing.OutQuad
        target: root
        property: "color"
        from: Theme.surface0
        to: root.color
    }
    Behavior on color {
        ColorAnimation {
            duration: 200
            easing.type: Easing.OutQuad
        }
    }

    ColumnLayout {
        id: dashCol

        anchors.centerIn: parent
        spacing: 2

        Icon {
            Layout.alignment: Qt.AlignHCenter
            icon: root.icon
            size: 30
            color: root.selected ? Theme.blue : Theme.text
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.text
            color: root.selected ? Theme.blue : Theme.text
            horizontalAlignment: Text.AlignHCenter
            font {
                family: Theme.font
                pixelSize: 14
            }

            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.OutQuad
                }
            }
        }
    }
}
