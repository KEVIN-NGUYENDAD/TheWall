# THE WALL — Alpha APK Release

A real debug APK was built for this Alpha and verified. This file documents
that specific build. For the general pre-flight checklist (SDK/JDK setup,
what to fill in before a *public* release), see `APK_RELEASE_CHECKLIST.md`.

## Build details

- **File**: `android_release/TheWall-Alpha-debug.apk` (28.5 MB, plus its
  `.apk.idsig` signature file alongside it)
- **Build command**:
  `godot --headless --export-release "Web" ...` was used for Web;
  `godot --headless --export-debug "Android" android_release/TheWall-Alpha-debug.apk`
  for this APK, run against the `Android` preset in `export_presets.cfg`.
- **Package**: `com.example.thewall` (resolved automatically from the
  preset's `com.example.$genname` placeholder — this is a real, working
  package id for Alpha testing, but is **not** appropriate for a Play Store
  submission; a public release needs a real owned domain-based id, e.g.
  `com.yourstudio.thewall`, set before that build, since package id cannot
  be changed after a store listing goes live)
- **Version**: versionCode 1, versionName 1.0.0 (Godot's default fallback —
  the preset's `version/name` field is still blank; safe for internal Alpha
  testing, should be set explicitly before any tagged release)
- **Signing**: signed with Godot's auto-managed debug keystore
  (`%APPDATA%\Godot\keystores\debug.keystore`) — **installable for testing,
  not suitable for a Play Store upload**, which requires a release keystore
  (see `APK_RELEASE_CHECKLIST.md`)
- **SDK versions**: minSdk 24, targetSdk 36, compiled against Android SDK
  Platform 37 / Build-Tools 36.0.0
- **Architecture**: `arm64-v8a` only (the preset has `armeabi-v7a`, `x86`,
  and `x86_64` disabled) — this covers effectively all real Android phones
  and tablets from the last several years, but will not install on an
  emulator image or device running a 32-bit-only or x86 image
- **Build type**: prebuilt APK (not Gradle) —
  `gradle_build/use_gradle_build=false` in the preset, so this build did not
  need network access or a Gradle toolchain beyond the Android SDK itself

## Install instructions

**Via adb** (requires the Android SDK's `platform-tools` on your PATH, or
run it directly from the SDK):
```
adb install android_release/TheWall-Alpha-debug.apk
```

**Without adb**: copy the APK to the device (email, cloud drive, USB) and
open it from a file manager. Android will prompt to allow installs from
that source if it's the first time installing an app from outside the Play
Store on that device.

## What was verified about this build

- The export completed with no errors from a clean headless Godot 4.7.2 run
  after one required project-setting fix (see below)
- `aapt dump badging` on the produced APK confirms the package name,
  version, SDK levels, and app label all match expectations above
- A one-time project setting was required and has been added:
  `rendering/textures/vram_compression/import_etc2_astc=true` — Android
  export refuses to proceed without ETC2/ASTC compression enabled; this is
  now permanently set in `project.godot`, so future exports won't hit this

## What was NOT verified

This APK has **not** been installed on a physical device or emulator from
this environment — no device or emulator was available to actually run it
against. Everything above is confirmed via the export process succeeding and
static inspection of the resulting file (`aapt dump badging`), not by
launching the app. The first real install on hardware is the first real test
of this specific APK — see `TEST_CHECKLIST_ALPHA.md` for what to run through
once it's on a device.
