pragma Singleton

import Quickshell
import Quickshell.Services.Notifications
import QtQuick

Scope {
    id: root

    readonly property var trackedNotifications: notifServer.trackedNotifications
    readonly property alias history: historyModel

    property var locks: ({})

    ListModel {
        id: historyModel
    }

    Component {
        id: lockComponent

        RetainableLock {
            locked: true
        }
    }

    function release(id): void {
        const lock = root.locks[id];
        if (!lock)
            return;

        delete root.locks[id];
        lock.destroy();
    }

    function forget(index: int): void {
        if (index < 0 || index >= history.count)
            return;

        root.release(history.get(index).notifId);
        history.remove(index);
    }

    function clear(): void {
        for (let i = history.count - 1; i >= 0; i--)
            root.forget(i)
    }

    NotificationServer {
        id: notifServer

        actionsSupported: true
        bodySupported: true
        imageSupported: true

        onNotification: notification => {
            notification.tracked = true;

            root.locks[notification.id] = lockComponent.createObject(root, {
                object: notification
            });

            history.insert(0, {
                notifId: notification.id,
                summary: notification.summary || "",
                body: notification.body || "",
                appName: notification.appName || "",
                image: notification.image || "",
                appIcon: notification.appIcon || "",
                time: Qt.formatDateTime(new Date(), "HH:mm"),
                urgency: notification.urgency
            });
        }
    }
}
