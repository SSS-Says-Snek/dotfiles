// haha replaces qt5ct's stupid ahh theming this looks way better
pragma ComponentBehavior: Bound

import Quickshell
import QtQuick

import qs.settings

PopupWindow {
    id: root

    required property Item anchorItem
    property QsMenuHandle menu: null

    // Submenus drill down in place; each element is { handle, title }.
    property var navigation: []

    property bool holdOpeners: false

    // Entries of the level currently on screen, from the deepest live opener.
    readonly property var entries: {
        const count = openers.count;
        const opener = count > 0 ? openers.objectAt(count - 1) : null;
        return opener ? opener.children : null;
    }

    readonly property int panelPadding: 6
    readonly property int gap: 6

    readonly property real contentWidth: content.item ? content.item.implicitWidth : 1
    readonly property real contentHeight: content.item ? content.item.implicitHeight : 1

    property bool sizeTransitionsEnabled: false
    property real panelWidth: 1
    property real panelHeight: 1

    color: "transparent"
    grabFocus: true

    implicitWidth: Math.max(1, Math.round(panelWidth))
    implicitHeight: Math.max(1, Math.round(panelHeight))

    onContentWidthChanged: if (visible)
        panelWidth = contentWidth
    onContentHeightChanged: if (visible)
        panelHeight = contentHeight

    onNavigationChanged: if (visible)
        sizeTransitionsEnabled = true

    onVisibleChanged: {
        if (visible) {
            sizeTransitionsEnabled = false;
            panelWidth = contentWidth;
            panelHeight = contentHeight;
            holdOpeners = false;
            releaseTimer.stop();
        } else {
            sizeTransitionsEnabled = false;
            panelWidth = 1;
            panelHeight = 1;

            if (!holdOpeners)
                navigation = [];
        }
    }

    Timer {
        id: releaseTimer

        interval: 400
        onTriggered: {
            root.holdOpeners = false;
            root.navigation = [];
        }
    }

    Behavior on panelWidth {
        enabled: root.sizeTransitionsEnabled
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutQuad
        }
    }

    Behavior on panelHeight {
        enabled: root.sizeTransitionsEnabled
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutQuad
        }
    }

    anchor {
        window: root.anchorItem.QsWindow.window
        adjustment: PopupAdjustment.Slide

        onAnchoring: {
            const item = root.anchorItem;
            const pos = item.QsWindow.contentItem.mapFromItem(item, (item.width - root.width) / 2, item.height + root.gap);

            root.anchor.rect.x = pos.x;
            root.anchor.rect.y = pos.y;
        }
    }

    function toggle(): void {
        visible = !visible;
    }

    // One opener per level of the path. Apps that build submenus lazily only fill a
    // level while its parent is still open, so every ancestor has to stay open with
    // it. The model is a count rather than the array itself so that drilling in adds
    // one opener instead of recreating (and thereby closing) the whole chain.
    Instantiator {
        id: openers

        model: (root.visible || root.holdOpeners) ? root.navigation.length + 1 : 0

        delegate: QsMenuOpener {
            required property int index

            menu: index === 0 ? root.menu : root.navigation[index - 1].handle
        }
    }

    Loader {
        id: content

        active: root.visible
        sourceComponent: panel
    }

    Component {
        id: panel

        Rectangle {
            implicitWidth: list.implicitWidth + 2 * root.panelPadding
            implicitHeight: list.implicitHeight + 2 * root.panelPadding

            width: root.implicitWidth
            height: root.implicitHeight
            clip: true

            radius: 16
            color: "#1e1e24"
            border.width: 1
            border.color: Theme.surface1

            TrayMenuList {
                id: list

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: root.panelPadding

                entries: root.entries
                backTitle: root.navigation.length > 0 ? root.navigation[root.navigation.length - 1].title : ""

                onActivated: {
                    root.holdOpeners = true;
                    root.visible = false;
                    releaseTimer.restart();
                }
                onSubmenuRequested: (handle, title) => root.navigation = [...root.navigation, {
                        handle,
                        title
                    }]
                onBackRequested: root.navigation = root.navigation.slice(0, -1)
            }
        }
    }
}
