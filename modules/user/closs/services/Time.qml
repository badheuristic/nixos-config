pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property date now: clock.date
    readonly property string hhmm: Qt.formatDateTime(clock.date, "HH:mm")
    readonly property string longDate: Qt.formatDateTime(clock.date, "dddd, MMMM d")

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
