# THE WALL — Roadmap

## Done

### MVP v1
- Circle player, hold-to-charge / release-to-jump
- Camera follow, height counter UI
- Portrait project setup

### MVP v2
- 20 procedurally spaced platforms
- Left/right movement
- Camera bounds, fall-death, respawn
- Improved jump feel (rise/fall gravity, coyote time, squash & stretch)
- Charge bar UI

### MVP v3–v5 (current)
- **Gameplay**: ~360-platform climb, checkpoints every 100m, best-height tracking, JSON save/load, death screen, checkpoint respawn
- **Progression**: coins, achievements, 5 unlockable skins, statistics screen
- **Polish**: shared theme, improved charge bar, parallax background, procedural placeholder SFX, main menu + pause menu
- **Android**: touch controls, portrait lock, responsive anchored UI, mobile renderer override
- **Architecture**: reorganized into `scripts/{autoload,player,world,ui}` and `scenes/{player,world,ui}`

### Post-v5 audit
- Full dependency audit after a scene-save failure (`docs/HANDOFF.md` → "Editor cache incident"): traced to a stale Godot editor cache still pointing at the old pre-reorg `Main.tscn`, plus one real `load_steps` bug in `Checkpoint.tscn`. Both fixed; no source-level bugs found elsewhere.

## Next Up (v6 candidates)

- **Endless generation**: currently a fixed ~360-platform level (~1000m ceiling). Move to chunked/streamed generation so the climb is truly endless, unloading platforms far below the camera.
- **Reachability guarantees**: platform x-position is fully random; add a max-horizontal-delta-per-gap check (based on jump arc + move speed) so no unlucky run produces an unreachable gap.
- **Hazards/obstacles**: vision calls for obstacles, not yet implemented — moving platforms, crumbling platforms, spikes.
- **Real art & audio**: replace primitive-shape visuals and generated-tone SFX with authored art and music once the game loop is validated.
- **Leaderboards**: local top-N run history at minimum; online leaderboard if backend is added.
- **Tutorial / onboarding**: first-run hint for hold-to-charge, shown once via a save-data flag.
- **Accessibility**: colorblind-safe charge bar palette, adjustable control sensitivity, haptics on Android.
- **Android export**: project settings are export-ready (portrait lock, mobile renderer, touch input); actual export still needs a local Android SDK + JDK + keystore configured in the Godot editor, and an `export_presets.cfg` generated from it. Not done here since it depends on the developer's machine — see `EXPORT_ANDROID.md` for the full step-by-step.
- **iOS**: not scoped yet; would need an equivalent export pass plus a look at touch control sizing for notch/safe-area devices.

## Explicitly Out of Scope (for now)

- Pay-to-win monetization (vision explicitly rules this out)
- Multiplayer/social features
- Non-portrait orientation support
