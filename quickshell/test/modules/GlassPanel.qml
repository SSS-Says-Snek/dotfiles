import QtQuick
import Quickshell.Widgets

import qs.settings

WrapperRectangle {
    id: root

    // no glass yet
    property real tint: 0.15

    margin: 14
    radius: 14

    color: Theme.dashboardBg

    // gradient: Gradient {
    //     GradientStop {
    //         position: 0
    //         color: Qt.rgba(1, 1, 1, root.tint * 1.5)
    //     }
    //
    //     GradientStop {
    //         position: 1
    //         color: Qt.rgba(1, 1, 1, root.tint * 0.5)
    //     }
    // }
}
