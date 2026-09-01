# THE WALL — Android Export Guide

This is the step-by-step for producing an installable Android build. None of this
can be done from inside the repo alone — it depends on tooling and credentials
that live on your machine, so nobody has run these steps yet. Everything on the
*project settings* side that Android export needs is already in place (see
"Already done" below); what's left is machine-side setup and the actual export.

## Already done (project side — no action needed)

- **Portrait lock**: `project.godot` → `[display] window/handheld/orientation="portrait"`.
- **Mobile-safe rendering**: `[rendering] renderer/rendering_method.mobile="mobile"`
  (overrides the desktop Forward+ renderer only on Android/iOS; desktop is untouched).
- **Touch input**: `scenes/ui/TouchControls.tscn` — plain `Button` nodes, which
  Godot's Control system already treats as touch-capable; no extra wiring needed.
- **Responsive layout**: HUD and menu screens use anchor-based layout (not fixed
  pixel offsets), so they adapt to whatever aspect ratio a given device reports.
- **App icon**: `config/icon="res://icon.svg"` is already set — see the icon note
  below for whether it's good enough to ship.

## 1. Install prerequisites (one-time, per machine)

1. **JDK 17** — required by Godot 4.x's Android build (Gradle). Install a JDK 17
   distribution (Temurin/Adoptium is a common choice) and note its path.
2. **Android SDK** — either via Android Studio (simplest: it bundles the SDK
   manager) or the standalone `cmdline-tools`. You need at minimum:
   - Android SDK Platform-Tools
   - An Android SDK Platform matching your target API level
   - Android SDK Build-Tools
3. **A keystore** for signing:
   - Debug builds: Godot can auto-generate a debug keystore the first time you
     export, or you can point it at your existing `~/.android/debug.keystore`.
   - Release builds: generate your own with `keytool`, e.g.:
     ```
     keytool -genkey -v -keystore thewall-release.keystore -alias thewall \
       -keyalg RSA -keysize 2048 -validity 10000
     ```
     Store this file and its passwords somewhere safe — losing it means you can
     never publish an update to an already-published app.

## 2. Point Godot at the SDK

In the Godot editor: **Editor → Editor Settings → Export → Android**, set:
- `Android SDK Path` → your SDK root (the folder containing `platform-tools/`,
  `build-tools/`, etc.)

Godot will validate the path and show a warning if something required is missing
(usually `platform-tools` or `build-tools`).

## 3. Install export templates

**Editor → Manage Export Templates** → download the templates for **exactly**
Godot 4.7.2 (this project's version — mismatched template versions are one of
the most common export failures). If offline, templates can be downloaded
separately from godotengine.org and installed via "Install from File".

## 4. Create the Android export preset

**Project → Export → Add... → Android**. Key settings to set:

- **Package name**: reverse-domain unique identifier, e.g. `com.yourstudio.thewall`.
  This cannot be changed after publishing to Google Play.
- **Version**: `version/code` (integer, increment every release) and
  `version/name` (the human-readable string, e.g. "1.0.0").
- **Screen → Orientation**: leave as **Portrait** (or "Sensor Portrait" if you
  want upside-down support) — this should already match the project setting, but
  the export preset has its own orientation field, so double-check it isn't
  defaulted to "Landscape" or "Default".
- **Signing**: point debug/release keystore fields at the keystore(s) from step 1.
- **Min/Target SDK**: the project doesn't use any Android-version-specific
  features, so Godot's defaults are fine; just make sure Target SDK meets Google
  Play's current minimum requirement at the time you publish (this changes yearly
  — check the Play Console requirements page rather than trusting a fixed number
  here).
- **Permissions**: this game needs none (no network, storage, location, camera,
  etc. — save data uses Godot's own `user://` sandbox). Leave the permissions
  list empty/default; don't enable anything Godot didn't ask for.

## 5. Export and test

- **File → Export Project** (or the preset's "Export Project" button) → produces
  an `.apk` (or `.aab` if you select that format — Google Play now requires AAB
  for new app submissions).
- Install on a device or emulator: `adb install path/to/thewall.apk`, or drag the
  APK onto a running emulator window.
- **Playtest checklist** (same as the desktop one, but specifically watching for
  touch/mobile issues):
  - Menu → Play → touch controls (left/right/jump) respond correctly
  - Charge bar, height counter, coin counter all legible at the device's actual
    resolution/aspect ratio (this is what the anchor-based UI is meant to
    guarantee — verify it actually holds on a real device, not just in the editor)
  - Orientation stays locked to portrait even if the device is physically rotated
  - Death screen / pause menu buttons are reachable and not obscured by on-screen
    nav bars or notches
  - Save persists across an app kill (Android can and will kill backgrounded
    apps — `SaveManager` saves on `NOTIFICATION_APPLICATION_PAUSED`, so backing
    out to the home screen should be enough to trigger a save; verify by killing
    the app from the recent-apps list and relaunching)

## Known gaps to revisit before a real release

- **Icon**: `icon.svg` is the placeholder generated when the project was created
  — it was never redesigned as part of this build. Android also wants an
  **adaptive icon** (separate foreground/background layers) for modern launchers;
  a single flat SVG will still work but won't look native. Worth a real icon pass
  before publishing.
- **AAB vs APK**: Google Play requires the Android App Bundle (`.aab`) format for
  new apps, not raw APKs. Make sure whichever preset you use for a Play Store
  submission is set to export that format.
- **Gradle build**: Godot's default export uses a prebuilt Android template. If a
  future feature needs an Android plugin (e.g. real ads, IAP, achievements via
  Play Games), you'll need to switch the preset to "Use Gradle Build" and install
  Android Studio's command-line build tools — not needed for the current feature
  set, but flagging it since it changes the toolchain requirements.
- **Safe-area / notch handling**: touch control positions are anchored to screen
  corners with a fixed pixel margin; on devices with camera cutouts or gesture
  nav bars, verify the buttons aren't clipped. Not tested against real hardware.

See `HANDOFF.md` for the rest of the project's architecture, and `ROADMAP.md` for
where Android support fits into overall priorities.
