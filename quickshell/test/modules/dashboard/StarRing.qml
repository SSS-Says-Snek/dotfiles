import QtQuick
import QtQuick.Layouts

import qs.modules
import qs.settings

ProgressRing {
    id: root
    transparentBg: true
    baseColor: Theme.surface0
    accentColor: Theme.mauve
    thickness: 24
    ringRadius: 460
    progress: 0.5

    startAngle: 160
    sweep: -140

    function calculateXRot(angle: int, itemWidth: int, itemHeight: int): int {
        return root.width / 2 + (root.ringRadius - 20 - itemHeight / 2) * Math.cos(angle * Math.PI / 180) - itemWidth / 2
    }

    function calculateYRot(angle: int, itemHeight: int): int {
        return root.height / 2 + (root.ringRadius - 20 - itemHeight / 2) * Math.sin(angle * Math.PI / 180) - itemHeight / 2
    }

    Item {
        width: sunrise0.implicitWidth
        height: sunrise0.implicitHeight

        rotation: 160 - 90
        x: root.calculateXRot(160, width, height)
        y: root.calculateYRot(160, height)

        ColumnLayout {
            id: sunrise0
            Icon {
                Layout.alignment: Qt.AlignHCenter
                color: Theme.yellow
                size: 60
                icon: "mdi-notif"
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                color: Theme.yellow
                text: "6:07 AM"
                font {
                    family: Theme.font
                }
            }
        }
    }
}
