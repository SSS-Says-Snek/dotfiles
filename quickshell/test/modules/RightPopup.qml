pragma ComponentBehavior: Bound

import QtQuick.Layouts
import QtQuick

import Quickshell
import Quickshell.Widgets

import qs.modules.panel
import qs.modules.notif
import qs.settings

PopupWindow {
    id: root

    required property Item anchorItem

    property bool expanded: false
    property int popupWidth: 500

    property int popupHeight: 650

    property real revealHeight: expanded ? popupHeight : 0
    property int index: 0

    color: "transparent"
    implicitWidth: popupWidth
    implicitHeight: popupHeight
    grabFocus: false

    onExpandedChanged: {
        if (expanded)
        visible = true;
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
            const item = root.anchorItem;
            const pos = item.QsWindow.contentItem.mapFromItem(item, (item.width - root.width) / 2, item.height);

            root.anchor.rect.x = pos.x;
            root.anchor.rect.y = pos.y;
        }
    }

    Loader {
        id: content

        width: root.width
        height: root.revealHeight
        clip: true

        active: root.visible
        asynchronous: true
        sourceComponent: circle
    }

    Component {
        id: circle
        Item {
            ClippingRectangle {
                id: rect
                width: root.popupWidth
                height: root.popupHeight
                radius: 20
                color: "#1e1e24"

                border.width: 2
                border.color: Theme.accent

                property list<Component> tabs: [
                    Component {
                        ControlPanel {
                            anchors.fill: parent
                        }
                    },

                    Component {
                        NotifPanel {
                            anchors.fill: parent
                        }
                    },

                    Component {
                        Item {
                            Rectangle {
                                anchors.fill: parent
                                color: Theme.green
                                radius: 10
                            }
                        }
                    }
                ]

                Image {
                    anchors.centerIn: parent
                    source: Quickshell.shellPath("assets/wha2.png")
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true

                    NumberAnimation on rotation {
                        from: 0
                        to: 360
                        duration: 100000
                        loops: Animation.Infinite
                        running: true
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15

                    spacing: 10

                    RowLayout {
                        id: toc

                        Layout.fillWidth: true
                        spacing: 8
                        uniformCellSizes: true

                        TabButton {
                            id: dashTab
                            Layout.fillWidth: true
                            icon: "mdi-dashboard"
                            text: "Control Panel"
                            selected: root.index == 0
                            onClicked: root.index = 0
                        }

                        TabButton {
                            id: notifTab
                            Layout.fillWidth: true
                            icon: "mdi-notif"
                            text: "Notifications"
                            selected: root.index == 1
                            onClicked: root.index = 1
                        }

                        TabButton {
                            id: perfTab
                            Layout.fillWidth: true
                            icon: "mdi-performance"
                            text: "Statistics"
                            selected: root.index == 2
                            onClicked: root.index = 2
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 2
                        color: Theme.surface2
                    }

                    ClippingRectangle {
                        id: tabHost

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"
                        radius: 20

                        Row {
                            id: tabStrip

                            height: parent.height
                            x: -root.index * tabHost.width - root.index * spacing
                            spacing: 30

                            Behavior on x {
                                NumberAnimation {
                                    duration: 200
                                    easing.type: Easing.OutCubic
                                }
                            }

                            Repeater {
                                model: rect.tabs.length

                                Item {
                                    id: slice

                                    required property int index

                                    width: tabHost.width
                                    height: tabHost.height

                                    Loader {
                                        anchors.fill: parent
                                        // Stay loaded so neighbors are visible mid-swipe.
                                        active: true
                                        asynchronous: true
                                        sourceComponent: rect.tabs[slice.index]
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
