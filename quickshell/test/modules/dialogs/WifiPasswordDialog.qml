import QtQuick
import QtQuick.Layouts

import qs.services
import qs.settings

DialogCard {
    id: root

    readonly property var net: Dialogs.payload ?? {}
    readonly property string ssid: net.ssid ?? ""
    readonly property string security: net.security ?? ""

    title: ssid !== "" ? `Connect to ${ssid}` : "Connect"

    Text {
        Layout.fillWidth: true
        text: root.security !== "" ? root.security : "Secured network"
        color: Theme.subtext
        font {
            family: Theme.font
            pixelSize: 13
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 42
        radius: 12
        color: Theme.base
        border.width: 1
        border.color: pass.activeFocus ? Theme.accent : Theme.surface1

        TextInput {
            id: pass

            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 52
            verticalAlignment: TextInput.AlignVCenter
            color: Theme.text
            clip: true
            echoMode: reveal.checked ? TextInput.Normal : TextInput.Password
            passwordCharacter: "•"
            font {
                family: Theme.font
                pixelSize: 14
            }

            Keys.onReturnPressed: root.submit()
            Keys.onEnterPressed: root.submit()
            Keys.onEscapePressed: Dialogs.dismiss()

            HoverHandler {
                id: passHover
                cursorShape: Qt.IBeamCursor
            }
        }

        Text {
            id: reveal

            property bool checked: false

            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            text: checked ? "Hide" : "Show"
            color: hover.hovered ? Theme.accent : Theme.subtext
            font {
                family: Theme.font
                pixelSize: 12
                weight: 600
            }

            HoverHandler {
                id: hover
                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                onTapped: reveal.checked = !reveal.checked
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        DialogAction {
            Layout.fillWidth: true
            label: "Cancel"
            onClicked: Dialogs.dismiss()
        }

        DialogAction {
            Layout.fillWidth: true
            label: "Connect"
            accent: true
            enabled: pass.text.length > 0
            onClicked: root.submit()
        }
    }

    function submit(): void {
        if (pass.text.length === 0)
            return
        Dialogs.accept({
            ssid: root.ssid,
            security: root.security,
            password: pass.text
        })
    }

    Component.onCompleted: pass.forceActiveFocus()
}
