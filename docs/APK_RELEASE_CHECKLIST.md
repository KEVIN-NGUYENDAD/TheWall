# THE WALL — APK Release Checklist

Focused checklist for producing an actual installable Android build from the
current Alpha Milestone. Narrower than `RELEASE_CHECKLIST.md` (which also
covers general non-Android QA) — this file is Android-build-specific.
Narrative walkthrough for first-time setup: `EXPORT_ANDROID.md`.

## Current blocking state (verified against `export_presets.cfg`)

An `Android` preset already exists in the project, but it is **not**
release-ready:

- [ ] `package/unique_name` is still the Godot-generated placeholder
      `com.example.$genname` — must be set to a real, permanent identifier
      (e.g. `com.yourstudio.thewall`) **before any install or store upload**;
      this cannot be changed later without publishing as a new app
- [ ] `package/name` is empty — set to the display name ("THE WALL")
- [ ] `version/name` is empty — set to a real version string (e.g. "0.1.0" for
      this Alpha)
- [ ] `version/code` is `1` — fine for a first build, bump on every
      subsequent release
- [ ] No keystore (debug or release) is configured in the preset

None of the above blocks anything in the Godot editor or desktop testing —
it only blocks producing a real APK/AAB.

## Machine setup (one-time, per developer machine)

- [ ] JDK 17 installed
- [ ] Android SDK installed (Platform-Tools, a Platform, Build-Tools)
- [ ] Godot → Editor Settings → Export → Android → SDK path set and validated
      (no red warning in the editor)
- [ ] Export templates installed matching **exactly** Godot 4.7.2
- [ ] Debug keystore available (Godot can auto-generate one, or point at an
      existing `~/.android/debug.keystore`)
- [ ] Release keystore generated and stored somewhere safe, with its
      passwords recorded somewhere safe — losing it means never being able to
      publish an update to an already-published app

## Fill in the preset

- [ ] Set `package/unique_name`, `package/name`, `version/name` as above
- [ ] Attach debug keystore path for local test builds
- [ ] Attach release keystore + passwords for a real release build (release
      builds only — not needed for internal Alpha testing)
- [ ] Confirm `screen/orientation` is not overridden away from portrait in
      the preset (the project-level `window/handheld/orientation="portrait"`
      setting is correct and should be left as the source of truth)
- [ ] Confirm no unexpected permissions are enabled — this game needs none
      (no network, storage, location, camera); it uses Godot's own `user://`
      sandbox for saves

## Build

- [ ] Export a **debug APK** first (`.apk`, not `.aab`) for sideloading and
      internal testing
- [ ] Install via `adb install path/to/thewall.apk` or by dragging onto a
      running emulator
- [ ] Run the full `TEST_CHECKLIST_ALPHA.md` pass on the actual installed
      build, not just in the editor — touch controls, memory overlays, death
      markers, checkpoint celebration, and platform variety should all be
      re-verified on hardware, since none of them have been tested outside
      the editor before this point

## Device-specific verification

- [ ] Touch controls (Left/Right/Jump, Pause) are correctly sized and
      positioned — not clipped by notches, camera cutouts, or gesture nav bars
- [ ] Orientation stays locked to portrait even if the device is physically
      rotated
- [ ] Full-screen Memory overlay and Death Screen render correctly and are
      dismissable/legible on the actual screen size and pixel density
- [ ] Camera shake (checkpoint celebration) doesn't feel excessive on a
      handheld device held close to the face — tune `CHECKPOINT_SHAKE_STRENGTH`
      in `Main.gd` if it does
- [ ] Save persists across the app being killed from the recent-apps list
      (`SaveManager` saves on `NOTIFICATION_APPLICATION_PAUSED`; backgrounding
      the app should trigger it — verify on real hardware since Android's
      process-kill behavior varies by OEM)
- [ ] Performance: platform variety (moving/collapsing platforms), particle
      bursts, and the animated Shape Above should not cause visible frame
      drops on a mid-range device — this build has not been profiled on
      hardware

## Before any public / store release (beyond internal Alpha testing)

- [ ] Replace `icon.svg` (still the Godot default placeholder) with a real
      app icon
- [ ] Switch export format to `.aab` — Google Play requires this for new app
      submissions, not raw APKs
- [ ] Confirm Target SDK meets Google Play's *current* minimum (this changes
      yearly — check the Play Console requirements page directly rather than
      trusting a fixed number)
- [ ] Store listing assets (screenshots, feature graphic, description) — not
      started, out of scope of this repo

## Known limitation

This Alpha build has been reviewed and built by hand against Godot 4
scene-format and GDScript semantics — there is no Godot binary in the
environment that authored it, so nothing here (including basic APK
installability) has been verified by actually running an export. Treat the
first real Android build of this Alpha as the first real test of all of it,
not just the items marked device-specific above.
