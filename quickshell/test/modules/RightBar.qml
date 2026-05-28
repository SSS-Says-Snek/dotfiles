import QtQuick

Rectangle {
    id: root
    property string targetMonitor: ""

    readonly property int rowSpacing: 10

    color: "#1e1e24"
    implicitWidth: rightBar.implicitWidth + 2 * rowSpacing

    anchors.rightMargin: root.rowSpacing
    radius: 9999

    Row {
        id: rightBar
        anchors.fill: parent
        spacing: root.rowSpacing
        anchors.leftMargin: root.rowSpacing

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
        }

        HoverHandler {
            id: rightArea
        }
    }
}
