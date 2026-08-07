pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts

import qs.settings

// note from the big C:
// Rows for one dbusmenu level. Submenus are not nested inline because Quickshell
// refuses to instantiate a QML type inside itself, so this reports them upward and
// the popup drills down. Entries are passed in rather than opened here, since the
// popup has to keep every ancestor level open for lazily built submenus to fill.
ColumnLayout {
    id: root

    required property var entries
    property string backTitle: "" // back row

    signal activated()
    signal submenuRequested(QsMenuHandle handle, string title)
    signal backRequested()

    spacing: 2

    TrayMenuRow {
        Layout.fillWidth: true

        visible: root.backTitle !== ""
        label: root.backTitle
        trailing: "‹"

        onClicked: root.backRequested()
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.leftMargin: 10
        Layout.rightMargin: 10

        visible: root.backTitle !== ""
        implicitHeight: 1
        color: Theme.surface1
    }

    Repeater {
        model: root.entries

        ColumnLayout {
            id: entry

            required property QsMenuEntry modelData

            Layout.fillWidth: true
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                Layout.topMargin: 2
                Layout.bottomMargin: 2

                visible: entry.modelData.isSeparator
                implicitHeight: visible ? 1 : 0
                color: Theme.surface1
            }

            TrayMenuRow {
                Layout.fillWidth: true

                visible: !entry.modelData.isSeparator
                interactive: entry.modelData.enabled

                label: entry.modelData.text
                iconSource: entry.modelData.icon
                leading: {
                    if (entry.modelData.buttonType === QsMenuButtonType.None)
                        return "";
                    return entry.modelData.checkState === Qt.Checked ? "●" : "○";
                }
                trailing: entry.modelData.hasChildren ? "›" : ""

                onClicked: {
                    if (entry.modelData.hasChildren) {
                        root.submenuRequested(entry.modelData, entry.modelData.text);
                        return;
                    }

                    entry.modelData.triggered();
                    root.activated();
                }
            }
        }
    }
}
