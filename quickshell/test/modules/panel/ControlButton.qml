import QtQuick
import QtQuick.Layouts

import qs.settings
import qs.modules

Rectangle {
    id: root

    property string icon
    property string text
    property bool active
    property bool hasSubmenu: false

    readonly property int hPad: 10
    readonly property int vPad: 12

    signal clicked()

    color: {
        if (root.active) {
            if (hoverHandler.hovered) {
                return Qt.lighter(Theme.blue, 0.95)
            }
            return Qt.alpha(Theme.blue, 0.8)
        } else {
            if (hoverHandler.hovered) {
                return Theme.dashboardBg
            }
            return "#80000000"
        }
    }
    radius: 40

    implicitWidth: dashCol.implicitWidth + 2 * hPad
    implicitHeight: dashCol.implicitHeight + 2 * vPad

    HoverHandler {
        id: hoverHandler
        cursorShape: Qt.PointingHandCursor
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
        from: root.active ? Theme.text : Theme.surface0
        to: root.color
    }
    Behavior on color {
        ColorAnimation {
            duration: 200
            easing.type: Easing.OutQuad
        }
    }

    RowLayout {
        id: dashCol

        anchors.centerIn: parent
        spacing: 18

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: 50
            height: 50
            radius: 999
            color: root.active ? Theme.surface0 : Theme.base

            Icon {
                anchors.centerIn: parent
                icon: root.icon
                size: 25
                color: root.active ? Theme.blue : Theme.overlay0
            }
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 4

            Text {
                Layout.alignment: Qt.AlignVCenter
                text: "Wi-Fi"
                color: root.active ? Theme.base : Theme.text

                font {
                    family: Theme.font
                    weight: 800
                }
            }
            Text {
                Layout.alignment: Qt.AlignVCenter
                text: root.text
                color: root.active ? Theme.base : Theme.subtext
                horizontalAlignment: Text.AlignHCenter
                font {
                    family: Theme.font
                    pixelSize: 13
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 200
                        easing.type: Easing.OutQuad
                    }
                }
            }
        }

        // Rectangle {
        //     Layout.alignment: Qt.AlignHCenter
        //     width: 30
        //     height: 30
        //     color: "transparent"
        //     visible: root.hasSubmenu
        //
        //     Icon {
        //         anchors.fill: parent
        //         size: 20
        //         icon: "mdi-nav-next"
        //         color: Theme.overlay0
        //     }
        // }
    }
}
