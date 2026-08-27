import QtQuick

import qs.modules
import qs.modules.tray

import qs.services

Rectangle {
    id: root
    property string targetMonitor: ""

    readonly property int rowSpacing: 10
    property int desiredIndex: 0

    color: "#1e1e24"
    implicitWidth: rightBar.implicitWidth + 2 * rowSpacing

    anchors.rightMargin: root.rowSpacing
    radius: 9999

    Row {
        id: rightBar
        anchors.fill: parent
        spacing: root.rowSpacing
        anchors.leftMargin: root.rowSpacing

        WallpaperStat {
            anchors.verticalCenter: parent.verticalCenter
            onClicked: {
                Wallpaper.cycleWallpaper()
            }
            onRightClicked: {
                Wallpaper.selectWallpaper()
            }
        }

        NotifStat {
            anchors.verticalCenter: parent.verticalCenter
            onClicked: {
                if (!rightPopup.expanded) {
                    root.desiredIndex = 1
                    rightPopupTimer.restart()
                }
                rightPopup.expanded = !rightPopup.expanded
            }
        }

        DiskStat {
            anchors.verticalCenter: parent.verticalCenter
        }

        AudioStat {
            anchors.verticalCenter: parent.verticalCenter
        }

        TempStat {
            anchors.verticalCenter: parent.verticalCenter
        }

        CpuStat {
            anchors.verticalCenter: parent.verticalCenter
        }

        MemStat {
            anchors.verticalCenter: parent.verticalCenter
            onClicked: rightPopup.expanded = !rightPopup.expanded
        }

        HoverHandler {
            id: rightArea
        }

        SysTray {
            id: sysTray

            anchors.verticalCenter: parent.verticalCenter
        }
    }

    RightPopup {
        id: rightPopup
        anchorItem: rightBar
    }

    Timer {
        id: rightPopupTimer
        interval: 400
        onTriggered: rightPopup.index = root.desiredIndex
    }
}
