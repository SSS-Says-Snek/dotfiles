pragma Singleton

import Quickshell
import Quickshell.Services.Notifications

import QtQml.Models

Scope {
    id: root

    readonly property var trackedNotifications: notifServer.trackedNotifications
    readonly property alias history: history

    NotificationServer {
        id: notifServer

        actionsSupported: true
        bodySupported: true
        imageSupported: true

        onNotification: notification => {
            history.insert(0, {
                summary: notification.summary || "",
                body: notification.body || "",
                appName: notification.appName || "",
                image: notification.image || "",
                appIcon: notification.appIcon || "",
                time: Qt.formatDateTime(new Date(), "HH:mm"),
                urgency: notification.urgency
            });
            notification.tracked = true;
        }
    }

    ListModel {
        id: history
    }
}
