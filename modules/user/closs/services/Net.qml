pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Networking

Singleton {
    id: root

    readonly property var devices: Networking.devices.values
    readonly property var wifiDevice: devices.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var wiredDevice: devices.find(d => d.type === DeviceType.Wired && d.connected) ?? null

    readonly property var network: wifiDevice ? wifiDevice.networks.values.find(n => n.connected) ?? null : null
    readonly property bool wifiEnabled: Networking.wifiEnabled
    readonly property bool wired: wiredDevice !== null
    readonly property bool connected: wired || network !== null
    readonly property real strength: network?.signalStrength ?? 0

    readonly property string label: wired ? "Ethernet"
        : network ? network.name
        : wifiEnabled ? "Not connected" : "Off"

    readonly property string icon: wired ? "lan"
        : !wifiEnabled ? "wifi_off"
        : !network ? "wifi_find"
        : strength > 0.66 ? "wifi"
        : strength > 0.33 ? "wifi_2_bar"
        : "wifi_1_bar"

    function toggleWifi(): void {
        Networking.wifiEnabled = !Networking.wifiEnabled;
    }
}
