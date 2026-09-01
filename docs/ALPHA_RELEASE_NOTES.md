# THE WALL — Alpha Release Notes

Build produced: Web (`web_release/`) and Android debug APK
(`android_release/TheWall-Alpha-debug.apk`), both exported and verified from
Godot 4.7.2 in this pass. See `WEB_DEPLOY.md` and `APK_RELEASE.md` for
build-specific detail.

## Implemented features

**Core loop**: hold-to-charge / release-to-jump, left/right movement, air
dash (double-tap left/right mid-air), asymmetric rise/fall gravity, coyote
time, squash-and-stretch, camera follow with bounds.

**Level**: ~360 procedurally spaced platforms across three visually and
mechanically distinct areas —
- **The Ruins** (0–100m): baseline look, beginner-friendly
- **The Sky** (100–500m): brighter palette, more clouds, doubled moving-platform
  frequency
- **The Void** (500m+): dark, muted palette

Platform variety: normal, moving (carries the player), collapsing (collapses
~0.5s after landing), and rare fake platforms (visually identical, no
collision). Spike hazards. Checkpoints every 100m with a glow/flag/
camera-shake celebration on activation.

**Death & progress**: falling below the screen kills the player; death
screen shows height reached, best height, coins, and meters lost since the
last checkpoint. Dying within 5m of any checkpoint triggers distinct "SO
CLOSE!" near-miss framing (screen flash, unique sound, different title).
Death Markers permanently mark every death location on the wall, persisted
across sessions, merged when close together, hidden below 20m.

**Memory System**: one-time atmospheric full-screen reveals at 100m, 300m,
700m, and 1500m — each shown exactly once, ever, per save file.

**The Shape Above**: an animated, unexplained object always visible near the
top of the screen, at every height, with no way to reach or interact with it.

**Progression (unchanged from earlier milestones)**: coins, 5 purchasable
skins, 8 achievements, statistics screen — none of this pass's work touched
these systems.

**Effects**: particle bursts on hard landings and dashes, checkpoint glow
bursts, fade-in death markers.

**Mobile/UI**: enlarged touch controls and buttons across every screen,
brighter/higher-contrast palette, 4x MSAA, antialiased primitive-shape
rendering, a small auto-hiding tutorial hint instead of a persistent
center-screen prompt.

**Save system**: JSON at `user://savegame.json` — best height, coins, skins,
achievements, stats, death heights, and memory-seen flags, all additive to
the original schema.

## Known bugs / open issues

- **Platform reachability is not guaranteed.** Gap height and platform x
  position are randomized independently; an unlucky combination can produce
  a harder-than-intended jump. No solver currently checks this. (Carried
  over from `KNOWN_BUGS.md`.)
- **The Void has no gameplay-specific tuning beyond its color palette.** No
  hazard-frequency or mechanic changes were made for 500m+ specifically,
  since none were requested when the area system was built — it currently
  reuses baseline hazard frequencies from The Ruins/Sky.
- **Web build sharpness on high-DPI displays (iPad/Retina) is not fully
  solved.** MSAA and antialiasing were added at the engine level, but true
  device-pixel-ratio-aware canvas rendering for the Web export would need a
  custom HTML shell, which is out of scope for this pass. Flagged in
  `WEB_DEPLOY.md`.
- **Android package identity is still a placeholder** (`com.example.thewall`,
  resolved automatically from the export preset's default). Fine for Alpha
  sideload testing; must be changed before any public/store release, and
  cannot be changed afterward without shipping as a new app. See
  `APK_RELEASE.md`.
- **This APK has not been installed or run on any real device or emulator**
  from this environment — no device/emulator was available here. The export
  succeeded and was inspected statically (`aapt dump badging`), but the
  actual on-device experience (performance, touch response, screen fit) is
  unverified.
- **No live human playtest of this exact build.** A headless smoke test
  (`Main.tscn` run for ~3 seconds with no input) completed with zero script
  errors, confirming the scene loads and initializes cleanly, but it cannot
  exercise input-driven systems (dash, spike collisions, checkpoint
  triggers, death) the way a real player would. Treat every item under
  "Testing focus areas" below as unverified until someone actually plays it.

## Testing focus areas

Prioritized for this Alpha, roughly in order of "most likely to be broken in
a way static review can't catch":

1. **Air dash feel** — is the double-tap window (0.3s) easy to hit
   intentionally and hard to trigger by accident during normal movement?
2. **Platform variety fairness** — do moving/collapsing/fake platforms ever
   combine with a tight gap to create an unfair or impossible jump,
   especially in The Sky's higher moving-platform density?
3. **Near-miss and death-marker accuracy** — does "within 5m of a
   checkpoint" actually feel like a near miss in practice, and do merged
   death markers ("×N") read clearly at a glance while climbing past them?
4. **Memory reveal pacing** — does pausing the game for ~4 seconds per
   memory feel appropriately weighty, or does it interrupt momentum in a way
   that annoys rather than intrigues?
5. **Area transition smoothness** — does the 2.5s color crossfade between
   zones look intentional, or does it feel like a glitch, especially if the
   player is moving fast (charging into a jump) right as it triggers?
6. **Touch control ergonomics on real hardware** — sizes were increased
   based on stated feedback, but only verified in the editor/via static
   layout math, never on an actual phone or tablet screen.
7. **Full save persistence across a real app lifecycle** — background the
   app / close the browser tab mid-run, relaunch, confirm best height,
   coins, death markers, and seen memories all survive exactly as expected.
