pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower

Singleton {
    id: root

    readonly property var device: UPower.displayDevice
    readonly property bool present: (device?.isLaptopBattery ?? false) && (device?.isPresent ?? false)
    readonly property real level: (device?.percentage ?? 0)
    readonly property bool charging: device?.state === UPowerDeviceState.Charging
    readonly property bool plugged: !UPower.onBattery
    readonly property bool low: present && !plugged && level <= 0.15

    readonly property string label: !present ? ""
        : charging ? "Charging"
        : plugged ? "Plugged in"
        : timeLeft

    readonly property string timeLeft: {
        const s = device?.timeToEmpty ?? 0;
        if (s <= 0)
            return "On battery";
        const h = Math.floor(s / 3600), m = Math.round((s % 3600) / 60);
        return h > 0 ? `${h}h ${m}m left` : `${m}m left`;
    }

    // Power profiles (power-profiles-daemon)
    readonly property int profile: PowerProfiles.profile
    readonly property string profileLabel: profile === PowerProfile.Performance ? "Performance"
        : profile === PowerProfile.PowerSaver ? "Power Saver"
        : "Balanced"
    readonly property string profileIcon: profile === PowerProfile.Performance ? "speed"
        : profile === PowerProfile.PowerSaver ? "energy_savings_leaf"
        : "balance"

    function cycleProfile(): void {
        const order = [PowerProfile.PowerSaver, PowerProfile.Balanced];
        if (PowerProfiles.hasPerformanceProfile)
            order.push(PowerProfile.Performance);
        const i = order.indexOf(PowerProfiles.profile);
        PowerProfiles.profile = order[(i + 1) % order.length];
    }
}
