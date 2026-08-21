import QtQuick
import QtQuick.Layouts

import qs.settings

Item {
    id: root

    readonly property int columns: 7
    readonly property int cellSpacing: 5
    readonly property int minCellWidth: 26

    implicitWidth: columns * minCellWidth + (columns - 1) * cellSpacing
    implicitHeight: content.implicitHeight

    readonly property real cellWidth: Math.max(minCellWidth, (width - (columns - 1) * cellSpacing) / columns)

    function getNumDaysInMonth(year, month) {
        return new Date(year, month, 0).getDate()
    }

    function makeGrid() {
        let res = []
        let year = new Date().getFullYear()
        let month = new Date().getMonth()
        let day = new Date().getDate()
        let dayOfWeek = ((new Date(year, month, 0).getDay() - 1) % 7 + 7) % 7;
        // truemod

        let prevMonthOffset = dayOfWeek
        let prevMonthDays = getNumDaysInMonth(2026, month - 1)
        for (let i = prevMonthOffset; i >= 0; i--) {
            res.push({
                day: prevMonthDays - i + 1,
                isToday: false,
                isCurrMonth: false
            })
        }

        for (let i = 0; i < getNumDaysInMonth(2026, month); i++) {
            res.push({
                day: i + 1,
                isToday: i + 1 == day,
                isCurrMonth: true
            })
        }

        let resLen = res.length
        for (let i = 0; i < 42 - resLen; i++) {
            res.push({
                day: i + 1,
                isToday: false,
                isCurrMonth: false
            })
        }
        return res
    }

    property var gridData: makeGrid()

    ColumnLayout {
        id: content

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            spacing: root.cellSpacing

            Repeater {
                model: ["Mon", "Tues", "Wed", "Thurs", "Fri", "Sat", "Sun"]
                Text {
                    Layout.preferredWidth: root.cellWidth
                    text: modelData
                    color: Theme.subtext
                    horizontalAlignment: Text.AlignHCenter

                    font {
                        family: Theme.font
                        weight: 500
                        pixelSize: 16
                    }
                }
            }
        }

        GridLayout {
            columns: root.columns
            columnSpacing: root.cellSpacing
            rowSpacing: root.cellSpacing / 2
            Layout.preferredWidth: root.cellWidth
            Layout.fillWidth: true

            Repeater {
                model: root.gridData

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: txt.implicitHeight
                    radius: width / 2

                    color: modelData.isToday ? Theme.blue : hover.hovered ? Theme.surface0 : "transparent"

                    Text {
                        id: txt
                        anchors.horizontalCenter: parent.horizontalCenter

                        font {
                            family: Theme.font
                            weight: 500
                            pixelSize: 18
                        }
                        text: modelData.day
                        color: modelData.isToday ? Theme.base : modelData.isCurrMonth ? Theme.text : Theme.surface2
                    }

                    HoverHandler {
                        id: hover
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 400
                            easing.type: Easing.OutQuad
                        }
                    }
                }
            }
        }
    }
}
