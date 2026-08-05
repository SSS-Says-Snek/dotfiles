pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris
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

    function formatTime(seconds) {
        let hrs = Math.floor(seconds / 3600)
        let mins = Math.floor(seconds / 60)

        let paddedMinutes = String(mins).padStart(2, '0')
        let paddedSeconds = String(Math.floor(seconds % 60)).padStart(2, '0') 
        let str = ""
        if (hrs > 0) {
            str += `${hrs}:${paddedMinutes}:${paddedSeconds}`
        }
        str += `${mins}:${paddedSeconds}`
        return str
    }

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

                ProgressRing {
                    anchors.centerIn: parent
                    baseColor: Theme.surface0
                    accentColor: Theme.text
                    thickness: 8
                    ringRadius: 174 // oh yeah line it up with that
                    progress: {
                        const player = MprisController.activePlayer;
                        if (!player || player.length <= 0)
                            return 0;
                        return player.position / player.length;
                    }
                    transparentBg: true
                    interactive: true

                    startAngle: 165
                    sweep: -150

                    onMoved: value => {
                        const player = MprisController.activePlayer;
                        if (!player?.canSeek || player.length <= 0)
                            return;
                        player.position = value * player.length;
                    }
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

                        NumberAnimation on rotation {
                            from: 0
                            to: 360
                            duration: 30000
                            loops: Animation.Infinite
                            running: true
                            paused: !MprisController.isPlaying
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: "#80000000"
                        opacity: mouseArea.containsMouse ? 1 : 0

                        Icon {
                            anchors.centerIn: parent
                            icon: MprisController.isPlaying ? "mdi-pause" : "mdi-play"
                            size: 50
                            color: Theme.text
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor

                            onClicked: MprisController.togglePlaying()
                        }

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.OutQuad
                            }
                        }
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
                        pixelSize: 16
                        weight: 800
                    }

                    Marquee {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 220
                        text: MprisController.activeTrack.artist
                        color: Theme.subtext
                        pixelSize: 14
                    }
                }

                Row {
                    anchors.horizontalCenter: coverFrame.horizontalCenter
                    anchors.top: coverFrame.bottom
                    anchors.topMargin: 12
                    spacing: 4

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: formatTime(MprisController.activePlayer.position) + " / " + formatTime(MprisController.activePlayer.length)
                        color: Theme.text
                        font {
                            family: Theme.font
                        }
                    }
                }

                Icon {
                    id: previous

                    anchors.verticalCenter: coverFrame.verticalCenter
                    anchors.right: coverFrame.left
                    anchors.rightMargin: 18

                    icon: "mdi-previous"
                    size: 38
                    color: Theme.text
                    interactive: true
                    enabled: MprisController.canGoPrevious
                    onClicked: MprisController.previous()
                }

                Icon {
                    id: next

                    anchors.verticalCenter: coverFrame.verticalCenter
                    anchors.left: coverFrame.right
                    anchors.leftMargin: 18

                    icon: "mdi-next"
                    size: 38
                    color: Theme.text
                    interactive: true
                    enabled: MprisController.canGoNext
                    onClicked: MprisController.next()
                }

                Timer {
                    // only emit the signal when the position is actually changing.
                    running: MprisController.activePlayer.playbackState == MprisPlaybackState.Playing
                    // Make sure the position updates at least once per second.
                    interval: 500
                    repeat: true
                    onTriggered: {
                        MprisController.activePlayer.positionChanged()
                    }
                }
            }
        }
    }
}
