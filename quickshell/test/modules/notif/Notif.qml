pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications

import qs.modules
import qs.settings

Item {
    id: root

    required property int index
    required property string summary
    required property string body
    required property string appName
    required property string image
    required property string appIcon
    required property string time
    required property var urgency

    property bool autoClose: true

    readonly property int padding: 12
    readonly property int iconSize: 68
    readonly property int gap: 12
    readonly property int animMs: 500
    readonly property real openHeight: card.height + gap

    property bool closing: false
    property bool explicitClose: false
    property bool externalClose: false // like external NotifPanel requests close all through this binding

    signal dismiss
    signal explicitDismiss

    function resolveIcon(image: string, appIcon: string): string {
        if (image)
            return image
        if (!appIcon)
            return ""
        if (appIcon.startsWith("/") || appIcon.indexOf("://") >= 0)
            return appIcon
        return Quickshell.iconPath(appIcon, true)
    }

    width: ListView.view ? ListView.view.width : 0
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
            return
        closing = true
        dismissTimer.restart()
    }

    Timer {
        id: dismissTimer

        interval: root.animMs
        onTriggered: {
            if (root.explicitClose)
                root.explicitDismiss()
            else
                root.dismiss()
        }
    }

    Rectangle {
        id: card

        width: parent.width
        height: rowLayout.implicitHeight + 2 * root.padding

        radius: 10
        color: "#181824"
        border.width: 2
        border.color: root.urgency == NotificationUrgency.Critical ? Theme.red : Theme.mauve
        clip: true

        Component.onCompleted: {
            if (!root.autoClose)
                return

            opacity = 0
            appear.start()
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
                id: iconImage

                Layout.preferredWidth: visible ? root.iconSize : 0
                Layout.preferredHeight: root.iconSize
                Layout.alignment: Qt.AlignVCenter

                fillMode: Image.PreserveAspectFit
                visible: status === Image.Ready
                source: root.resolveIcon(root.image, root.appIcon)
                asynchronous: true

                onStatusChanged: {
                    if (status !== Image.Error)
                        return
                    const fallback = root.resolveIcon("", root.appIcon)
                    if (fallback && source.toString() !== fallback)
                        source = fallback
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 4

                Text {
                    Layout.fillWidth: true
                    text: root.summary
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
                    text: root.body
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

        Timer {
            running: root.urgency !== NotificationUrgency.Critical && root.autoClose
            interval: 10000
            onTriggered: root.requestDismiss()
        }

        TapHandler {
            onTapped: {
                root.explicitClose = true
                root.requestDismiss()
            }
        }

        HoverHandler {
            id: hoverHandler
        }
    }

    onExternalCloseChanged: {
        if (root.externalClose) {
            root.explicitClose = true
            root.requestDismiss()
        }
    }
}
