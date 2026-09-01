# THE WALL — Release Checklist

Two checklists: general pre-ship QA (any platform) and the Android-specific
build/publish steps. Neither has been run against a live build yet — nothing
below is checked off. See `EXPORT_ANDROID.md` for the detailed narrative
version of the Android steps; this file is the condensed, checkable version
plus the non-Android QA pass.

## General pre-ship QA (do this before any release, any platform)

- [ ] Full playthrough: Main Menu → Play → climb → intentionally fall → Death
      Screen → Respawn → reach a checkpoint → fall again → Death Screen →
      Main Menu
- [ ] Skins screen: unlock a skin with coins, equip it, confirm the player's
      color actually changes in-run (and reverts to the charge color while
      charging, regardless of equipped skin)
- [ ] Statistics screen: confirm every stat increments correctly across a play
      session (jumps, deaths, checkpoints, runs, coins) and achievements flip
      from locked to unlocked with a toast at the right threshold
- [ ] Pause menu (HUD pause button): pause mid-air, confirm physics fully
      freezes, Resume continues exactly where it left off, Main Menu saves and
      exits cleanly
- [ ] Save persistence: play a session, force-quit the game (not a clean
      menu-quit), relaunch, confirm best height / coins / skins / achievements
      all survived
- [ ] Confirm `user://savegame.json` is being written (check the file exists
      and updates after key events — checkpoint, death, best-height PR, skin
      purchase)
- [ ] No console errors/warnings during a full playthrough (check the Godot
      editor's Output/Debugger panel)
- [ ] Quit button behavior: present and working on desktop; hidden on mobile
      (`OS.has_feature("mobile")` check in `MainMenu.gd`)

## Android release checklist

### Machine setup (one-time)
- [ ] JDK 17 installed
- [ ] Android SDK installed (Platform-Tools, a Platform, Build-Tools)
- [ ] Godot Editor Settings → Export → Android → SDK path configured and
      validated (no red warning)
- [ ] Export templates installed matching **exactly** Godot 4.7.2
- [ ] Debug keystore available (auto-creatable or existing
      `~/.android/debug.keystore`)
- [ ] Release keystore generated and stored somewhere safe (password included
      — losing this means you can never update a published app)

### Export preset configuration — `export_presets.cfg`
Current state: **one `Android` preset exists but is not release-ready.**
Confirmed still-placeholder values as of this checklist:
- [ ] `package/unique_name` — currently `com.example.$genname`; set to a real
      reverse-domain identifier (e.g. `com.yourstudio.thewall`) **before any
      Play Store upload** — this cannot be changed after publishing
- [ ] `package/name` — currently empty; set to the display name ("THE WALL")
- [ ] `version/name` — currently empty; set (e.g. "1.0.0")
- [ ] `version/code` — currently `1`; bump on every release
- [ ] `screen/orientation` — not explicitly set in the preset (relies on the
      project-level `window/handheld/orientation="portrait"` setting, which is
      correct); double check the preset hasn't been changed to override this
- [ ] Debug keystore path configured in the preset
- [ ] Release keystore path + passwords configured in the preset (release
      builds only)
- [ ] Export format: `.apk` for sideloading/testing is fine; **Google Play
      requires `.aab`** for new app submissions — confirm the right format is
      selected before a store upload

### Icon & branding
- [ ] Replace `icon.svg` (still the Godot default placeholder) with a real app
      icon before any public release
- [ ] Consider an Android adaptive icon (separate foreground/background
      layers) for a native launcher look — a single flat SVG works but won't
      look native
- [ ] `config/name="TheWall"` in `project.godot` — confirm this is the final
      display name, or update it

### Build & device test
- [ ] Export a debug APK, install via `adb install`, confirm it launches and
      the full QA pass above holds on a real device (not just the editor)
- [ ] Touch controls (left/right/jump) responsive and correctly positioned —
      not clipped by device notches, cutouts, or gesture nav bars
- [ ] HUD legible at the device's actual resolution/aspect ratio (this is what
      the anchor-based responsive UI is supposed to guarantee — verify it
      holds on hardware, not just in the editor)
- [ ] Orientation stays locked to portrait even if the device is physically
      rotated
- [ ] Save persists across the app being killed from the recent-apps list
      (`SaveManager` saves on `NOTIFICATION_APPLICATION_PAUSED` — backgrounding
      the app should be enough to trigger it; verify on a real device since
      Android's process-kill behavior varies by OEM)

### Store submission (if publishing to Google Play)
- [ ] Switch export format to `.aab` if not already
- [ ] Confirm Target SDK meets Google Play's *current* minimum (this changes
      yearly — check the Play Console requirements page, don't rely on a
      number written here)
- [ ] Permissions: this game requests none (no network/storage/location/
      camera) — confirm the preset hasn't picked up anything unexpected
- [ ] Store listing assets (screenshots, feature graphic, description) — not
      started; out of scope of this repo

## Known blocker for this checklist

The Android preset's package identity, version, and keystore are all still
placeholders (see above) — a build attempted right now would produce an APK
signed/named as `com.example.<something>`, not a real, publishable app. This
is the single blocking item between "project is Android-ready" (true today)
and "an actual Android build exists" (not yet true). See `KNOWN_BUGS.md` →
"Current blockers" for the same item tracked alongside other open issues.
