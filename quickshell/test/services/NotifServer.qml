pragma Singleton

import Quickshell.Services.Notifications

NotificationServer {
    id: root
    actionsSupported: true
    bodySupported: true
    imageSupported: true

    onNotification: notification => {
        notification.tracked = true;
    }
}
