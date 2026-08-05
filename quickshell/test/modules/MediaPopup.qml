pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Widgets
import QtQuick

import qs.settings
import qs.services

PopupWindow {
    id: root

    required property Item anchorItem

    property bool expanded: false
    property int circleRadius: 200

    readonly property int diameter: circleRadius * 2

    property real revealHeight: expanded ? diameter : 0

    color: "transparent"
    implicitWidth: diameter
    implicitHeight: diameter
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
                width: root.diameter
                height: root.diameter
                radius: root.circleRadius
                color: "#1e1e24"

                border.width: 2
                border.color: Theme.accent

                Image {
                    anchors.fill: parent
                    source: Quickshell.shellPath("assets/wha2.png")
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }

                ClippingRectangle {
                    id: coverFrame

                    anchors.centerIn: parent
                    width: 200
                    height: 200
                    radius: width / 2
                    color: "transparent"

                    Image {
                        id: cover
                        anchors.fill: parent
                        source: MprisController.activeTrack.artUrl
                        fillMode: Image.PreserveAspectCrop
                        sourceSize.width: width
                        asynchronous: true
                    }
                }

                Column {
                    anchors.horizontalCenter: coverFrame.horizontalCenter
                    anchors.bottom: coverFrame.top
                    anchors.bottomMargin: 12
                    spacing: 4

                    Marquee {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 220
                        text: MprisController.activeTrack.title
                        color: Theme.text
                        pixelSize: 14
                        weight: 800
                    }

                    Marquee {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 220
                        text: MprisController.activeTrack.artist
                        color: Theme.subtext
                        pixelSize: 12
                    }
                }
            }
        }
    }
}
