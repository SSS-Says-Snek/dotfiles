pragma ComponentBehavior: Bound

import Quickshell.Services.SystemTray
import QtQuick

import qs.settings

Rectangle {
    id: root

    readonly property int iconSize: 16
    readonly property int hPad: 10
    readonly property int spacing: 8

    visible: SystemTray.items.values.length > 0
    implicitWidth: visible ? row.implicitWidth + 2 * hPad : 0
    implicitHeight: Theme.barHeight - 4

    radius: 9999
    color: Theme.surface0

    Row {
        id: row

        anchors.centerIn: parent
        spacing: root.spacing

        Repeater {
            model: SystemTray.items.values.filter(i => !General.hiddenIcons.includes(i.id))

            MouseArea {
                id: trayItem

                required property SystemTrayItem modelData

                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true

                implicitWidth: root.iconSize
                implicitHeight: root.iconSize

                onClicked: event => {
                    if (event.button === Qt.LeftButton) {
                        // console.log(trayItem.modelData.id)
                        if (trayItem.modelData.onlyMenu) {
                            trayItem.openMenu();
                        } else
                            trayItem.modelData.activate();
                    } else if (event.button === Qt.RightButton) {
                        trayItem.openMenu();
                    } else if (event.button === Qt.MiddleButton) {
                        trayItem.modelData.secondaryActivate();
                    }
                }

                onWheel: event => trayItem.modelData.scroll(event.angleDelta.y, false)

                function openMenu(): void {
                    if (!trayItem.modelData.hasMenu)
                        return;

                    menu.toggle();
                }

                TrayMenu {
                    id: menu

                    anchorItem: trayItem
                    menu: trayItem.modelData.menu
                }

                Image {
                    id: icon

                    anchors.centerIn: parent
                    width: root.iconSize
                    height: root.iconSize

                    source: trayItem.modelData.icon
                    sourceSize.width: Math.round(root.iconSize * Screen.devicePixelRatio)
                    sourceSize.height: Math.round(root.iconSize * Screen.devicePixelRatio)
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    smooth: true

                    opacity: trayItem.containsMouse ? 1 : 0.85
                    scale: trayItem.containsMouse ? 1.1 : 1

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 120
                            easing.type: Easing.OutQuad
                        }
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: 120
                            easing.type: Easing.OutQuad
                        }
                    }
                }
            }
        }
    }
}
