pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    // Raw date for widgets that need the components rather than a formatted string.
    readonly property date date: clock.date

    readonly property string time: {
        Qt.formatDateTime(clock.date, "dddd, MMMM dd, yyyy, hh:mm:ss AP")
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}
