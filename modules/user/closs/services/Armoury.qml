pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// z13ctl daemon client (ROG Flow Z13). The daemon speaks newline-delimited
// JSON on a unix socket, one request per connection:
//   → {"cmd":"get-state"}            ← {"ok":true,"state":{…}}
//   → {"cmd":"profile","set":"quiet"} ← {"ok":true}
Singleton {
    id: root

    readonly property string socketPath: (Quickshell.env("XDG_RUNTIME_DIR") ?? "/tmp") + "/z13ctl/z13ctl.sock"

    property bool available: false
    property string error: ""

    // Live state (mirrors the daemon, refreshed while the view is open)
    // "custom" is virtual: the daemon re-applies saved TDP/fans/undervolt,
    // while sysfs keeps reporting the underlying firmware profile.
    property string sysProfile: ""       // quiet | balanced | performance
    property bool custom: false
    readonly property string profile: custom ? "custom" : sysProfile
    property int batteryLimit: 100
    property bool panelOverdrive: false
    property bool bootSound: false
    property int temperature: 0          // °C
    property int fanRpm: 0
    property int tdp: 0                  // sustained limit (PL1), W
    property int tdpBoost: 0             // short boost (PL2), W
    readonly property int tdpMin: 5
    readonly property int tdpMaxSafe: 75 // PL1 cap without --force
    readonly property int tdpMax: 93     // PL2/PL3 hardware max

    property int fanMode: 2              // 0 full speed, 1 custom, 2 auto
    property var fanPoints: []           // [{ temp, pwm }] × 8

    property bool undervoltAvailable: false
    property bool undervoltActive: false
    property int undervolt: 0            // all-core Curve Optimizer, 0 … -40

    // GPU memory (unified): dedicated carve-out + dynamically shared GTT
    property real vramUsed: 0
    property real vramTotal: 0
    property real gttUsed: 0
    property real gttTotal: 0
    property bool lightOn: true
    property string lightMode: "static"  // static | breathe | cycle | rainbow | strobe
    property string lightColor: "FFFFFF" // RRGGBB
    property string lightSpeed: "normal"
    property int lightLevel: 3           // 1–3 (off is lightOn = false)
    property string lightZone: ""        // "" both · keyboard · lightbar
    property string swatchSet: "vivid"   // vivid (z13ctl's named colours) · palette (the rice)

    // z13ctl's named colours (`z13ctl apply --list-colors`), the set that
    // reads well on the LEDs; the rice palette is offered alongside.
    readonly property var vividColors: [
        { name: "Red", hex: "FF0000" },
        { name: "Coral", hex: "FF7F50" },
        { name: "Orange", hex: "FF8000" },
        { name: "Gold", hex: "FFD700" },
        { name: "Yellow", hex: "FFFF00" },
        { name: "Spring Green", hex: "00FF7F" },
        { name: "Turquoise", hex: "40E0D0" },
        { name: "Teal", hex: "008080" },
        { name: "Cyan", hex: "00FFFF" },
        { name: "Deep Sky Blue", hex: "00BFFF" },
        { name: "Royal Blue", hex: "4169E1" },
        { name: "Blue Violet", hex: "8A2BE2" },
        { name: "Magenta", hex: "FF00FF" },
        { name: "Hot Pink", hex: "FF69B4" },
        { name: "Brown", hex: "A52A2A" },
        { name: "White", hex: "FFFFFF" }
    ]

    // Whether the daemon has anything to re-apply for the Custom profile
    property bool hasCustom: false

    readonly property var profiles: [
        { id: "quiet", label: "Silent", icon: "energy_savings_leaf" },
        { id: "balanced", label: "Balanced", icon: "balance" },
        { id: "performance", label: "Turbo", icon: "bolt" },
        { id: "custom", label: "Custom", icon: "tune" }
    ]
    readonly property string profileLabel: {
        const p = profiles.find(p => p.id === profile);
        return p ? p.label : profile === "custom" ? "Custom" : "—";
    }
    readonly property string profileIcon: {
        const p = profiles.find(p => p.id === profile);
        return p ? p.icon : "tune";
    }

    // ── Requests ─────────────────────────────────────────────────────────
    function send(req: var, cb: var): void {
        const s = requestComponent.createObject(root, { request: req, callback: cb ?? null });
        s.connected = true;
    }

    function refresh(): void {
        send({ cmd: "get-state" }, r => {
            const s = r.state;
            if (!s)
                return;
            batteryLimit = s.battery_limit || batteryLimit;
            panelOverdrive = (s.panel_overdrive ?? 0) === 1;
            bootSound = (s.boot_sound ?? 0) === 1;
            temperature = s.temperature ?? 0;
            fanRpm = s.fan_rpm ?? 0;
            tdp = s.tdp?.pl1_spl ?? 0;
            tdpBoost = s.tdp?.pl2_sppt ?? 0;
            custom = s.profile === "custom";
            fanMode = s.fan_curve?.mode ?? 2;
            fanPoints = s.fan_curve?.points ?? [];
            undervoltAvailable = s.undervolt_available ?? false;
            undervoltActive = s.undervolt?.active ?? false;
            undervolt = s.undervolt?.cpu_co ?? 0;
            hasCustom = !!s.tdp || fanMode === 1 || undervolt !== 0;
            const l = s.lighting;
            if (l) {
                lightOn = l.enabled && (l.brightness ?? 0) > 0;
                lightMode = l.mode || "static";
                lightColor = (l.color || "FFFFFF").toUpperCase();
                lightSpeed = l.speed || "normal";
                if ((l.brightness ?? 0) > 0)
                    lightLevel = l.brightness;
            }
        });
        gpuMem.running = true;
        // Read these from sysfs (get-state reports the daemon's cached copy)
        send({ cmd: "profile-get" }, r => sysProfile = r.value ?? sysProfile);
        send({ cmd: "batterylimit-get" }, r => batteryLimit = parseInt(r.value) || batteryLimit);
    }

    function setProfile(id: string): void {
        if (id === "custom")
            custom = true;
        else {
            custom = false;
            sysProfile = id;
        }
        send({ cmd: "profile", set: id }, () => refresh());
    }

    // Cycles the stock profiles only; Custom is chosen deliberately.
    function cycleProfile(): void {
        const ids = ["quiet", "balanced", "performance"];
        setProfile(ids[(ids.indexOf(profile) + 1) % ids.length]);
    }

    // ── Tuning (each of these switches the daemon to the Custom profile) ─
    function setTdp(sustained: int, boost: int): void {
        sustained = Math.max(tdpMin, Math.min(tdpMaxSafe, sustained));
        boost = Math.max(sustained, Math.min(tdpMax, boost));
        tdp = sustained;
        tdpBoost = boost;
        custom = true;
        hasCustom = true;
        send({ cmd: "tdp", set: String(sustained), pl1: String(sustained), pl2: String(boost), pl3: String(boost) }, () => refresh());
    }

    function resetTdp(): void {
        custom = false;
        send({ cmd: "tdp-reset" }, () => refresh());
    }

    function setFanCurve(points: var): void {
        fanPoints = points;
        fanMode = 1;
        custom = true;
        hasCustom = true;
        send({ cmd: "fancurve", set: points.map(p => p.temp + ":" + p.pwm).join(",") }, () => refresh());
    }

    function resetFanCurve(): void {
        fanMode = 2;
        send({ cmd: "fancurve-reset" }, () => refresh());
    }

    function setUndervolt(offset: int): void {
        offset = Math.max(-40, Math.min(0, offset));
        undervolt = offset;
        if (offset === 0) {
            undervoltActive = false;
            send({ cmd: "undervolt-reset" }, () => refresh());
        } else {
            undervoltActive = true;
            custom = true;
            send({ cmd: "undervolt", set: String(offset) }, () => refresh());
        }
    }

    function setBatteryLimit(pct: int): void {
        batteryLimit = pct;
        send({ cmd: "batterylimit", set: String(pct) });
    }

    function setPanelOverdrive(on: bool): void {
        panelOverdrive = on;
        send({ cmd: "paneloverdrive", set: on ? "1" : "0" });
    }

    function setBootSound(on: bool): void {
        bootSound = on;
        send({ cmd: "bootsound", set: on ? "1" : "0" });
    }

    // Lighting: every change re-applies the full effect to keyboard + lightbar.
    function lightReq(req: var): var {
        if (lightZone !== "")
            req.device = lightZone;
        return req;
    }

    function applyLight(): void {
        send(lightReq({
            cmd: "apply",
            mode: lightMode,
            color: lightColor,
            color2: "000000",
            speed: lightSpeed,
            brightness: lightLevel
        }));
    }

    function setLightColor(hex: string): void {
        lightColor = hex.replace("#", "").toUpperCase();
        if (lightMode === "cycle" || lightMode === "rainbow")
            lightMode = "static";
        lightOn = true;
        applyLight();
    }

    function setLightMode(mode: string): void {
        lightMode = mode;
        lightOn = true;
        applyLight();
    }

    function setLightLevel(level: int): void {
        if (level <= 0) {
            lightOn = false;
            send(lightReq({ cmd: "off" }));
            return;
        }
        lightLevel = level;
        if (lightOn) {
            send(lightReq({ cmd: "brightness", brightness: level }));
        } else {
            lightOn = true;
            applyLight();
        }
    }

    Component {
        id: requestComponent

        Socket {
            id: sock

            property var request
            property var callback
            property bool done: false

            path: root.socketPath

            function finish(): void {
                if (done)
                    return;
                done = true;
                connected = false;
                sock.destroy();
            }

            onConnectedChanged: {
                if (connected) {
                    write(JSON.stringify(request) + "\n");
                    flush();
                }
            }

            onError: e => {
                root.available = false;
                finish();
            }

            parser: SplitParser {
                onRead: data => {
                    root.available = true;
                    try {
                        const r = JSON.parse(data);
                        if (r.ok) {
                            root.error = "";
                            if (sock.callback)
                                sock.callback(r);
                        } else {
                            root.error = r.error ?? "";
                            console.warn("z13ctl:", sock.request.cmd, root.error);
                        }
                    } catch (err) {
                        console.warn("z13ctl: bad reply", data);
                    }
                    sock.finish();
                }
            }

            // Never leak a socket if the daemon stops answering.
            property Timer timeout: Timer {
                running: true
                interval: 3000
                onTriggered: sock.finish()
            }
        }
    }

    // vram_used vram_total gtt_used gtt_total, in bytes, from the amdgpu card
    Process {
        id: gpuMem
        command: ["sh", "-c", "for c in /sys/class/drm/card*/device; do [ -r $c/mem_info_vram_total ] && cat $c/mem_info_vram_used $c/mem_info_vram_total $c/mem_info_gtt_used $c/mem_info_gtt_total && break; done"]
        stdout: StdioCollector {
            onStreamFinished: {
                const v = text.trim().split(/\s+/).map(Number);
                if (v.length === 4) {
                    root.vramUsed = v[0];
                    root.vramTotal = v[1];
                    root.gttUsed = v[2];
                    root.gttTotal = v[3];
                }
            }
        }
    }

    Component.onCompleted: refresh()
}
