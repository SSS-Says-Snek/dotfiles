pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Widgets
import QtQuick

import qs.settings

PopupWindow {
    id: root

    required property Item anchorItem

    property bool expanded: false
    property int wheelRadius: 400

    readonly property alias currentTab: wheelDisplay.currentTab

    property real scrollAccumulator: 0

    function scroll(delta: real): void {
        scrollAccumulator += delta;

        while (scrollAccumulator <= -120) {
            wheelDisplay.step(1);
            scrollAccumulator += 120;
        }

        while (scrollAccumulator >= 120) {
            wheelDisplay.step(-1);
            scrollAccumulator -= 120;
        }
    }

    color: "transparent"
    implicitWidth: wheelRadius * 2
    implicitHeight: wheelRadius
    grabFocus: false

    // The surface can't animate itself, so it is mapped for the whole reveal and unmapped once the wipe has collapsed again.
    onExpandedChanged: {
        if (expanded)
            visible = true;
        else
            scrollAccumulator = 0;
    }
    onVisibleChanged: if (!visible) expanded = false

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

    Item {
        id: reveal

        width: root.width
        height: root.expanded ? root.wheelRadius : 0
        clip: true

        onHeightChanged: if (height === 0 && !root.expanded)
            root.visible = false

        Behavior on height {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutExpo
            }
        }

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

            // Image {
            //     anchors.left: parent.left
            //     anchors.right: parent.right
            //     anchors.bottom: parent.bottom
            //     height: parent.height / 2
            //
            //     source: Quickshell.shellPath("assets/bg.png")
            //     fillMode: Image.PreserveAspectCrop
            //     sourceSize.width: width
            //     asynchronous: true
            // }

            Wheel {
                id: wheelDisplay

                anchors.fill: parent

                background: Image {
                    source: Quickshell.shellPath("assets/wha1.png")
                    fillMode: Image.PreserveAspectCrop
                    sourceSize.width: width
                    asynchronous: true
                }

                Component {
                    Item {
                        Row {
                            anchors.centerIn: parent
                            spacing: 10
                            Rectangle {
                                implicitWidth: 100
                                implicitHeight: 100
                            }

                            CalendarTab {
                            }

                            Rectangle {
                                implicitWidth: 100
                                implicitHeight: 100
                            }
                        }
                    }
                }

                Component {
                    MediaTab {}
                }
            }

            Rectangle {
                height: 3
                width: parent.width
                color: Theme.mauve
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 1
            }

            MouseArea {
                anchors.fill: parent
                onWheel: event => root.scroll(event.angleDelta.y)
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 16
            spacing: 6

            Repeater {
                model: wheelDisplay.count

                Rectangle {
                    required property int index

                    width: 8
                    height: 8
                    radius: width / 2
                    color: index === wheelDisplay.currentTab ? Theme.mauve : Theme.surface2

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }
                    }
                }
            }
        }
    }
}
