import QtQuick
import qs.modules
import qs.settings

Text {
    text: Time.time
    color: Theme.mauve

    font {
        family: Theme.font
        pixelSize: 13
        weight: 600
    }
}
