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

    // Built when mapped and torn down when closed, same pattern as CenterPopup.
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
                        Item {
                            Rectangle {
                                anchors.fill: parent
                                color: Theme.mauve
                                radius: 10
                            }
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
                property int index: 0

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

                // Rectangle {
                //     anchors.fill: parent
                //     color: "#80000000"
                // }

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
                            selected: rect.index == 0
                            onClicked: rect.index = 0
                        }

                        TabButton {
                            id: notifTab
                            Layout.fillWidth: true
                            icon: "mdi-notif"
                            text: "Notifications"
                            selected: rect.index == 1
                            onClicked: rect.index = 1
                        }

                        TabButton {
                            id: perfTab
                            Layout.fillWidth: true
                            icon: "mdi-performance"
                            text: "Performance"
                            selected: rect.index == 2
                            onClicked: rect.index = 2
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
                            x: -rect.index * tabHost.width - rect.index * spacing
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
