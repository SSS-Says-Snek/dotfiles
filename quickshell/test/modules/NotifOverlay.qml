pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications

import qs.services
import qs.settings

PanelWindow {
    id: root

    readonly property int padding: 12
    readonly property int iconSize: 68
    readonly property int gap: 12
    readonly property int animMs: 500

    implicitWidth: 420
    implicitHeight: Math.max(1, list.contentHeight)
    color: "transparent"

    exclusionMode: ExclusionMode.Ignore

    ListView {
        id: list

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: contentHeight

        model: NotifServer.trackedNotifications
        verticalLayoutDirection: ListView.BottomToTop
        interactive: false
        clip: false

        delegate: Item {
            id: notif

            required property var modelData

            readonly property real openHeight: card.height + root.gap

            property bool closing: false

            width: list.width
            height: closing ? 0 : openHeight
            opacity: closing ? 0 : 1
            clip: true

            Behavior on height {
                NumberAnimation {
                    duration: root.animMs
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: root.animMs
                    easing.type: Easing.OutCubic
                }
            }

            function requestDismiss(): void {
                if (closing)
                    return;
                closing = true;
                dismissTimer.restart();
            }

            Timer {
                id: dismissTimer

                interval: root.animMs
                onTriggered: notif.modelData.dismiss()
            }

            Rectangle {
                id: card

                width: parent.width
                height: rowLayout.implicitHeight + 2 * root.padding

                radius: 10
                color: "#181824"
                border.width: 2
                border.color: notif.modelData.urgency == NotificationUrgency.Critical ? Theme.red : Theme.mauve
                clip: true

                Component.onCompleted: {
                    opacity = 0;
                    appear.start();
                }

                NumberAnimation {
                    id: appear

                    target: card
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: root.animMs
                    easing.type: Easing.OutCubic
                }

                RowLayout {
                    id: rowLayout

                    x: root.padding
                    y: root.padding
                    width: parent.width - 2 * root.padding
                    spacing: 12

                    Image {
                        Layout.preferredWidth: root.iconSize
                        Layout.preferredHeight: root.iconSize
                        Layout.alignment: Qt.AlignVCenter

                        fillMode: Image.PreserveAspectFit
                        visible: source.toString() !== ""
                        source: notif.modelData.image || notif.modelData.appIcon || ""
                        asynchronous: true
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 4

                        Text {
                            Layout.fillWidth: true
                            text: notif.modelData.summary
                            color: Theme.text
                            elide: Text.ElideRight
                            font {
                                family: Theme.font
                                pixelSize: 16
                                weight: 800
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: notif.modelData.body
                            color: Theme.subtext
                            wrapMode: Text.WordWrap
                            font {
                                family: Theme.font
                                pixelSize: 14
                            }
                        }
                    }
                }

                Rectangle {
                    id: closeButton

                    width: 20
                    height: 20
                    anchors.right: card.right
                    anchors.top: card.top
                    anchors.margins: 10
                    radius: 999
                    color: buttonHover.hovered ? Theme.peach : Theme.red
                    opacity: hoverHandler.hovered || buttonHover.hovered ? 1 : 0

                    Icon {
                        anchors.fill: parent
                        size: 20
                        icon: "mdi-close"
                        color: Theme.base
                    }

                    Behavior on opacity {
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

                    HoverHandler {
                        id: buttonHover
                        cursorShape: Qt.PointingHandCursor
                    }
                }

                Timer { // auto dismiss
                    running: notif.modelData.urgency !== NotificationUrgency.Critical
                    interval: 10000
                    onTriggered: notif.requestDismiss()
                }

                TapHandler {
                    onTapped: notif.requestDismiss()
                }

                HoverHandler {
                    id: hoverHandler
                }
            }
        }
    }
}
