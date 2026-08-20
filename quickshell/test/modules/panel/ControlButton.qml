import QtQuick
import QtQuick.Layouts

import qs.settings
import qs.modules

Rectangle {
    id: root

    property string icon
    property string title: ""
    property string text
    property bool active
    property bool hasSubmenu: false
    property Component submenu

    readonly property int hPad: 10
    readonly property int vPad: 12

    signal clicked()
    signal innerClicked()

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

        anchors.fill: parent
        anchors.leftMargin: root.hPad
        anchors.rightMargin: root.hPad
        anchors.topMargin: root.vPad
        anchors.bottomMargin: root.vPad
        spacing: 18

        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            width: 50
            height: 50
            radius: 999
            color: {
                if (root.active) {
                    if (innerHover.hovered) {
                        return Theme.surface1
                    }
                    return Theme.surface0
                }

                if (innerHover.hovered) {
                    return Theme.surface0
                }
                return Theme.base
            }

            Icon {
                anchors.centerIn: parent
                icon: root.icon
                size: 25
                color: {
                    if (root.active) {
                        if (innerHover.hovered) {
                            return Qt.lighter(Theme.blue, 1.1)
                        }
                        return Theme.blue
                    }

                    if (innerHover.hovered) {
                        return Theme.overlay1
                    }
                    return Theme.overlay0
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.OutQuad
                }
            }

            HoverHandler {
                id: innerHover
            }

            TapHandler {
                id: innerTap
                gesturePolicy: TapHandler.ReleaseWithinBounds
                onTapped: {
                    root.innerClicked()
                    root.active = !root.active
                }
            }
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            spacing: 4

            Text {
                Layout.fillWidth: true
                text: root.title || root.text
                color: root.active ? Theme.base : Theme.text
                elide: Text.ElideRight

                font {
                    family: Theme.font
                    weight: 800
                }
            }
            Text {
                Layout.fillWidth: true
                visible: root.title !== ""
                text: root.text
                color: root.active ? Theme.base : Theme.subtext
                elide: Text.ElideRight
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

        Icon {
            Layout.alignment: Qt.AlignVCenter
            visible: root.hasSubmenu
            icon: "mdi-nav-next"
            size: 20
            color: root.active ? Theme.base : Theme.overlay0
        }
    }
}
