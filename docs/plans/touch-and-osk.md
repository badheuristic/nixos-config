# Plan: on-screen keyboard and touch-first use

Status: planned, not started. Written 2026-11-14.

Goal: the Flow Z13 should be pleasant as a tablet. When the keyboard is
detached or folded back, a themed on-screen keyboard appears when text is
needed. The island, windows and workspaces can be driven with fingers and
the pen, and nothing needs a right click or a hotkey.

## What we have today

| Piece | State |
|---|---|
| Touchscreen | `ELAN9008:00 04F3:43C7` (Hyprland: `elan9008:00-04f3:43c7`), plus its stylus as a tablet device |
| Tablet-mode signal | `Asus WMI hotkeys` reports `SW_TABLET_MODE`. Hyprland lists it under `switches`, so it can be bound with `bindl = , switch:on:Asus WMI hotkeys, …` |
| Keyboard dock | Detachable USB keyboard `0b05:1a30`; it disappears from `hyprctl devices` when removed |
| OSK | `wvkbd-deskintl` is installed (home.nix) but never started or themed |
| Key remapping | kmonad runs a virtual keyboard (`kmonad-kbd`), so OSK keys must not be fed back through it |
| Island input | Quickshell `MouseArea`s receive synthesized touch; nothing is sized for fingers |
| Text-input protocols | Hyprland supports `zwp_input_method_v2` and `text-input-v3`; GTK4, Qt6 and Chromium/Electron (with `--enable-wayland-ime`) send focus events |

## Phase 1: OSK that appears on its own

1. **Pick the keyboard.**
   - `wvkbd` is light and themeable from flags, but it doesn't speak input-method. It can only be shown and hidden by signals (`SIGUSR1` hide, `SIGUSR2` show, `SIGRTMIN` toggle).
   - `squeekboard` implements input-method-v2, so it shows itself when a text field gets focus. It is heavier, GNOME-styled, and themed with a GTK stylesheet.
   - Recommendation: start with wvkbd driven by tablet mode (step 2). Revisit squeekboard if per-field popping matters.
2. **Tablet mode → OSK.**
   - Start wvkbd hidden at login (`exec-once = wvkbd-deskintl --hidden …`).
   - Add `bindl` binds on the switch's `on` and `off` events. They send `SIGUSR2` and `SIGUSR1` and also tell the island (`qs ipc call island tablet true|false`).
   - Treat keyboard unplug the same way: a udev rule on `0b05:1a30` remove/add that pokes the same script.
3. **Theme it from theme.nix.** wvkbd takes `--bg --fg --fg-sp --press --press-sp --text --text-sp` as `rrggbbaa`, plus `--fn "SF Compact Display 16"`, `-R` (rounding) and `-L` (landscape height). Generate the flags in a small `modules/user/osk.nix` so it follows the palette like everything else.
4. **Island toggle.**
   - Add a "Keyboard" tile to the control centre that toggles the OSK. That makes eight tiles, so the Island tile can go back to half width.
   - Add a small keyboard pill on the resting island while in tablet mode.
5. **Layout.** wvkbd takes an exclusive zone, so windows shrink above it. Check that the island's launcher and polkit views stay visible, and lift them if not.

## Phase 2: touch the island

1. Add `Closs.tablet` (bool) in `services/Closs.qml`, set by the IPC call from phase 1.
2. When tablet is true, scale touch targets:
   - `Style.rowHeight` 48 → 56
   - Tile height up
   - Slider thumbs 20 → 28
   - Fan-curve handles 22 → 36 hit area
   Do this by making those `Style` values depend on `Closs.tablet`, not by forking views.
3. Replace right-click-only actions with long-press, since there's no secondary click on touch.
   - `Tile.onSecondaryClicked` should also fire on `onPressAndHold`.
   - This covers Wi-Fi/Bluetooth settings, Phone and the Armoury profile cycle.
   - Fan-curve and slider drags already work with touch through `MouseArea`; confirm `preventStealing` doesn't block scroll in the tuning page.
4. **Swipe on the resting notch.**
   - Down opens the control centre; a tap opens the dashboard.
   - Use a `DragHandler`/`TapHandler` on the rest view, which also works with the mouse.
5. **Launcher in tablet mode.** Show an app grid (large icons) instead of the search list when the query is empty, since there's no keyboard to type with.

## Phase 3: touch the compositor

1. **Workspace and window gestures.**
   - Try Hyprland's built-in gestures first: `gesture = 3, horizontal, workspace` on the touchscreen, and edge swipes if 0.56 supports them for touch.
   - If not enough, use the `hyprgrass` plugin. It needs building against our patched Hyprland, so pin it in the flake.
   - Targets: swipe from the bottom edge to show the launcher grid, from the top to open the control centre, three fingers to switch workspaces, and long-press to move a window.
2. **Touch output mapping.** Set `input:touchdevice:output` and `input:tablet:output` to the internal panel so touch stays correct when an external monitor is connected.
3. **Pen.** Map the stylus to the internal panel, check pressure in xournalpp, and consider a pen button bind (e.g. barrel button → screenshot region with `grim -g "$(slurp)"`).
4. **Rotation (optional).** If the accelerometer is exposed (`iio-sensor-proxy`, `monitor-sensor`), add a small service that runs `hyprctl keyword monitor …,transform,N` and rotates touch to match. Only worth it if portrait use is wanted.

## Phase 4: polish

- Window close and maximize by touch: a long-press on a window could open a small island menu (close / fullscreen / float). This replaces the title bar the rice doesn't have.
- Lock screen: make sure the password field opens the OSK. hyprlock and closs-lock run before the session OSK, so the lock view may need its own on-screen number/letter pad.
- Polkit and keyring prompts: the polkit view is in the island, so check that the OSK shows above it. The gcr keyring prompt is a normal GTK4 window and should get the OSK through text-input.

## Things to verify first

- `hyprctl devices` switch name while folded vs detached. Folding back may emit the switch while detaching only removes the keyboard; we need both paths.
- Whether kmonad grabs the detachable keyboard, and what happens to it on reattach (it may need restarting by udev).
- wvkbd + layer-shell keyboard focus: the island takes exclusive keyboard focus when open, so OSK input must still reach it. wvkbd uses the virtual-keyboard protocol, which goes to the focused surface. Test with the launcher.

## Files this will touch

- `modules/user/osk.nix` (new): wvkbd flags from the palette, exec-once, tablet-mode script
- `modules/user/hyprland.nix`: switch binds, touch device/output config, gestures
- `hosts/flow/configuration.nix`: udev rule for keyboard attach/detach (and `iio-sensor-proxy` if rotating)
- `modules/user/closs/`: `Closs.tablet`, Style scaling, long-press, rest-view gestures, launcher grid, Keyboard tile
