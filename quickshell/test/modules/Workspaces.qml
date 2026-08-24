import Quickshell
import Quickshell.Hyprland
import QtQuick

import qs.settings

Item {
    id: root

    property string targetMonitor: ""

    implicitWidth: workspaceRow.width
    implicitHeight: workspaceRow.height

    readonly property int dotSize: 28
    readonly property int dotSizeExpanded: 40

    Row {
        id: workspaceRow
        anchors.centerIn: parent
        spacing: 10

        Repeater {
            model: Hyprland.workspaces

            Rectangle {
                id: workspaceIndiv
                visible: modelData.id >= 1 && modelData.monitor?.name === root.targetMonitor

                width: {
                    if (!visible)
                        return 0
                    else if (modelData.focused || modelData.active)
                        return root.dotSizeExpanded
                    return root.dotSize
                }
                height: root.dotSize
                radius: 9999
                color: {
                    if (modelData.focused)
                        return Theme.surface1
                    if (modelData.urgent)
                        return Theme.red
                    if (workspaceIndivArea.hovered)
                        return Theme.surface2
                    return Theme.surface0
                }

                Text {
                    text: modelData.id
                    anchors.centerIn: parent
                    color: Theme.text

                    font {
                        family: Theme.font
                        weight: 600
                        pixelSize: 13
                    }
                }

                Behavior on width {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutQuad
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 200
                        easing.type: Easing.OutQuad
                    }
                }

                TapHandler {
                    onTapped: modelData.activate()
                }

                HoverHandler {
                    id: workspaceIndivArea
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }
    }
}
