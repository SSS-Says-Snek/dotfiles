import QtQuick

import qs.services

Rectangle {
    anchors.fill: parent
    z: 9999
    visible: Dialogs.visible
    color: Dialogs.dimColor

    TapHandler {}
}
