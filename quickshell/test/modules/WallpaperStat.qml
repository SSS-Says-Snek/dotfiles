import QtQuick
import qs.modules
import qs.settings

BarWidgetWrapper {
    cursorShape: Qt.PointingHandCursor

    Icon {
        icon: "mdi-wallpaper"
        size: 18
        color: Theme.text

        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }
    }
}
