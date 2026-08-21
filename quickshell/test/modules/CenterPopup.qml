pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

import qs.settings
import qs.modules.dashboard
import qs.modules.dialogs

PopupWindow {
    id: root

    required property Item anchorItem

    property bool expanded: false
    property int wheelRadius: 500

    property int currentIndex: 0
    readonly property int tabCount: tabs.length
    readonly property int currentTab: tabCount > 0 ? ((currentIndex % tabCount) + tabCount) % tabCount : 0 // truemod

    property real revealHeight: expanded ? wheelRadius : 0

    function scroll(delta: real): void {
        if (delta > 0) {
            currentIndex += 1
        }

        if (delta < 0) {
            currentIndex -= 1
        }
    }

    color: "transparent"
    implicitWidth: wheelRadius * 2
    implicitHeight: wheelRadius
    grabFocus: false

    onExpandedChanged: {
        if (expanded)
            visible = true
    }
    onVisibleChanged: if (!visible)
        expanded = false
    onRevealHeightChanged: if (revealHeight === 0 && !root.expanded)
        root.visible = false

    Behavior on revealHeight {
        NumberAnimation {
            duration: 400
            easing.type: Easing.OutExpo
        }
    }

    anchor {
        window: root.anchorItem.QsWindow.window
        adjustment: PopupAdjustment.None

        onAnchoring: {
            const item = root.anchorItem
            const pos = item.QsWindow.contentItem.mapFromItem(item, (item.width - root.width) / 2, item.height)

            root.anchor.rect.x = pos.x
            root.anchor.rect.y = pos.y
        }
    }

    property list<Component> tabs: [
        Component {
            Item {
                GridLayout {
                    id: layout

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 20
                    columns: 4
                    rowSpacing: 20
                    columnSpacing: 30

                    RowLayout {
                        Layout.columnSpan: 4
                        Layout.fillWidth: true

                        // Calendar
                        WrapperRectangle {
                            Layout.columnSpan: 2
                            implicitWidth: 400

                            margin: 14
                            radius: 14
                            color: Theme.dashboardBg

                            CalendarTab {
                                id: cal
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        } // spacers

                        UsageBars {
                            Layout.preferredWidth: 150
                            Layout.preferredHeight: 220
                            Layout.alignment: Qt.AlignCenter
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        AnalogClock {
                            Layout.preferredWidth: 220
                            Layout.preferredHeight: 220
                            Layout.alignment: Qt.AlignCenter
                        }
                    }

                    WeatherRing {
                        Layout.preferredWidth: 200
                        Layout.preferredHeight: 200
                        Layout.alignment: Qt.AlignCenter
                    }

                    GenInfo {
                        Layout.columnSpan: 2
                        Layout.preferredWidth: 360
                        Layout.preferredHeight: 200
                    }
                    VolumeRing {
                        Layout.preferredWidth: 200
                        Layout.preferredHeight: 200
                        Layout.alignment: Qt.AlignCenter
                    }
                }
            }
        },
        Component {
            MediaTab {}
        }
    ]

    Loader {
        id: content

        width: root.width
        height: root.revealHeight
        clip: true

        active: root.visible
        asynchronous: true
        sourceComponent: dashboard
    }

    Component {
        id: dashboard

        Item {
            // Clips to semi size
            ClippingRectangle {
                id: clipRect
                y: -root.wheelRadius
                width: root.wheelRadius * 2
                height: root.wheelRadius * 2
                radius: root.wheelRadius
                color: "#1e1e24"

                border.width: 2
                border.color: Theme.mauve

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    onWheel: event => root.scroll(event.angleDelta.y)
                }

                Wheel {
                    id: wheelDisplay

                    anchors.fill: parent

                    currentIndex: root.currentIndex
                    tabs: root.tabs

                    background: Image {
                        source: Quickshell.shellPath("assets/wha1.png")
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                    }
                }

                Rectangle {
                    height: 3
                    width: parent.width
                    color: Theme.mauve
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: 1
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 16
                spacing: 6

                Repeater {
                    model: root.tabCount

                    Rectangle {
                        required property int index

                        width: 8
                        height: 8
                        radius: width / 2
                        color: index === root.currentTab ? Theme.mauve : Theme.surface2

                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }
                        }
                    }
                }
            }

            DialogDimmer {}
        }
    }
}
