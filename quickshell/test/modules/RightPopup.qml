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
    property int popupWidth: 400

    property int popupHeight: 600

    property real revealHeight: expanded ? popupHeight : 0

    color: "transparent"
    implicitWidth: popupWidth
    implicitHeight: popupHeight
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
            Rectangle {
                width: root.popupWidth
                height: root.popupHeight
                radius: 20
                color: "#1e1e24"

                border.width: 2
                border.color: Theme.accent
            }
        }
    }
}
