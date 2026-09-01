# THE WALL — Project Summary

## What this is

A one-finger mobile climbing game built in Godot 4.7 (GDScript only, portrait
orientation, no external art or audio assets — every visual is a primitive
shape and every sound is a procedurally generated tone). The player climbs an
enormous wall; a single fall costs progress back to the last checkpoint. Full
creative brief: `GAME_VISION.md`.

## Gameplay summary

- **Core loop**: hold the left mouse button (desktop) or the on-screen JUMP
  button (touch) to charge a jump; release to launch. Longer hold = higher
  jump. A/D or arrow keys (desktop) or on-screen Left/Right buttons (touch)
  move horizontally, in the air or on the ground.
- **The climb**: ~360 procedurally placed platforms stretch up from a fixed
  starting platform, each gap randomized in height (and platform x-position
  randomized across the screen width) so no two runs are identical.
- **Checkpoints**: a full-width checkpoint line appears every 100 meters
  climbed. Passing one (walking/jumping through it) banks it as your new
  respawn point.
- **Falling**: fall below the screen's bottom edge and you die — a death
  screen shows how high you got this attempt, your all-time best, and your
  coin total, then lets you respawn at your last checkpoint or return to the
  main menu.
- **Coins**: scattered above ~45% of platforms, banked to your total the
  instant you touch one (no risk of losing collected coins on a later fall).
- **Progression**: spend banked coins to unlock cosmetic skins; unlock
  achievements by hitting height/coin/death/checkpoint milestones.

## Current state (as of this doc pass)

MVP v1 through v5 are implemented and the project has passed a full dependency
audit (see `KNOWN_BUGS.md` for the one real bug found and fixed, and the
editor-cache incident writeup in `HANDOFF.md`). The project opens, runs, and
saves cleanly in Godot 4.7.2. A git repository now exists locally (one commit:
"TheWall MVP v5 checkpoint"). Android export has *not* been produced yet — the
project is export-ready but no APK/AAB has actually been built (see
`RELEASE_CHECKLIST.md`).

## Implemented features, by milestone

### MVP v1 — Core loop
- Circle player (`CharacterBody2D` + primitive-shape visual), hold-to-charge /
  release-to-jump
- Camera follows the player (smoothed `Camera2D`)
- Height counter UI
- Portrait project setup (viewport size, stretch mode)

### MVP v2 — Movement & feel
- Procedurally spaced platforms (20, later expanded to 360 — see v3-v5)
- Left/right movement, grounded and airborne
- Camera bounds (`limit_left/right/top/bottom`)
- Fall-death and respawn
- Improved jump feel: asymmetric rise/fall gravity, terminal velocity, coyote
  time, squash-and-stretch on jump/landing
- In-world charge ring + HUD charge bar

### MVP v3–v5 — Progression, polish, Android readiness
**Gameplay**
- Expanded to ~360 platforms (~1000m climbable height)
- Checkpoints every 100m, with a dedicated respawn point (not just "back to
  start")
- Best-height tracking, persisted
- JSON save/load (`user://savegame.json`)
- Death screen (height reached / best / coins, Respawn / Main Menu)
- Checkpoint-based respawn system (replacing v2's silent instant respawn)

**Progression**
- Coins (pickup, bank-on-touch)
- Achievement system: 8 achievements across height/coins/deaths/checkpoints,
  with a toast notification on unlock
- 5 unlockable skins, purchased with coins, equipped from a dedicated screen
- Statistics screen (lifetime stats + achievement list)

**Polish**
- Shared UI theme (`theme.tres`) used by every screen
- Color-shifting, anchor-driven charge bar
- 3-layer infinitely-tiling parallax background (primitive `Polygon2D` shapes,
  `ParallaxLayer.motion_mirroring`)
- Procedurally generated placeholder SFX (jump/coin/checkpoint/death/click/
  unlock — sine-wave tones, zero audio files)
- Main menu and in-run pause menu

**Android**
- On-screen touch controls (left/right/jump — also mouse-clickable for desktop
  testing)
- Portrait orientation lock
- Fully anchor-based responsive UI
- Mobile-specific rendering method override

**Architecture**
- Reorganized from a flat layout into `scripts/{autoload,player,world,ui}` and
  `scenes/{player,world,ui}`

### Post-v5 — Audit pass
- Full project dependency audit after a "couldn't save scene" error; traced to
  a stale Godot editor cache (not a source bug) plus one real `load_steps`
  mismatch in `Checkpoint.tscn`. Both resolved — see `KNOWN_BUGS.md` and
  `HANDOFF.md`.
- Six cross-referencing docs added (this one included) so a fresh session can
  onboard without re-deriving project state from source.

## What's explicitly NOT implemented yet

- Endless/streamed level generation (current climb is a fixed ~360-platform,
  ~1000m ceiling, generated all at once)
- Guaranteed platform reachability (gaps are randomized independently in
  height and x; no solver checks the combination is always jumpable)
- Hazards/obstacles (moving or crumbling platforms, spikes — vision calls for
  "obstacles," not yet built)
- Real (non-generated) art or audio
- Leaderboards, tutorial/onboarding, accessibility options
- An actual built/tested Android APK or AAB
- iOS export

Full detail on all of the above: `ROADMAP.md`.
