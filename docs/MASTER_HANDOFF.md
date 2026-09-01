# THE WALL — Master Handoff

**Start here.** This file is meant to be sufficient on its own for a brand-new
Claude session (or a human) to pick up development immediately, with no other
context. Everything below is a condensed, self-contained synthesis of the rest
of `docs/` — deeper detail on any section lives in the linked file, but you
shouldn't *need* to open them to get moving.

Related docs, if you want to go deeper on something:
- `GAME_VISION.md` — original creative brief
- `PROJECT_SUMMARY.md` — product-level feature history by milestone
- `ARCHITECTURE.md` — full technical deep dive (scene trees, script APIs, data flow)
- `PROJECT_TREE.md` — full literal file tree with annotations
- `RELEASE_CHECKLIST.md` — Android release checklist (checkbox form)
- `KNOWN_BUGS.md` — bug/gap tracker
- `ROADMAP.md` — milestone history + v6+ candidates
- `HANDOFF.md` — the original technical handoff (superset of this file's
  predecessor; kept for its "editor cache incident" writeup)
- `EXPORT_ANDROID.md` — narrative Android export walkthrough

**If any of the above ever contradicts this file, trust the source code first,
then the more specialized doc — this file is a snapshot, and snapshots go
stale.** When you make a change that invalidates something here, update this
file in the same pass.

---

## Current project state

Godot 4.7.2, GDScript only, portrait 2D. MVP v1 through v5 are implemented and
the project has been through a full dependency audit (one real bug found and
fixed — a `load_steps` mismatch in `Checkpoint.tscn` — plus a stale-editor-cache
issue that was mistaken for a source bug; both resolved, see `KNOWN_BUGS.md`).
The project opens, runs, and **saves scenes cleanly** in the Godot editor. A
local git repo now exists (`git log`: one commit, "TheWall MVP v5 checkpoint").
No Android APK/AAB has been built yet — the project is export-ready but the
export preset still has placeholder values (see "Android export status"
below). No external art or audio assets exist anywhere in the project by
design — every visual is a primitive shape (`Polygon2D`, `ColorRect`,
`draw_circle`/`draw_arc`) and every sound is a procedurally generated tone.

## Gameplay summary

The player is a circle climbing an enormous procedurally-generated wall.
**Hold** the left mouse button (desktop) or the on-screen JUMP button (touch)
to charge a jump; **release** to launch — longer hold = higher jump. A/D or
arrow keys (desktop) / on-screen Left-Right buttons (touch) move horizontally,
grounded or airborne. The climb is ~360 platforms tall (~1000m), with a
full-width **checkpoint** every 100m that becomes your respawn point once
touched. Falling below the screen kills you — a death screen shows the height
you reached, your all-time best, and your coin total, then offers Respawn (at
your last checkpoint) or Main Menu. **Coins** scattered above ~45% of
platforms bank to your total the instant you touch one. Banked coins buy
cosmetic **skins**; height/coin/death/checkpoint milestones unlock
**achievements** with a toast notification. A **Statistics** screen shows
lifetime stats and achievement progress.

## Implemented features

- **Core movement**: charge-jump, asymmetric rise/fall gravity, terminal
  velocity, coyote time, squash-and-stretch, left/right air control
- **Camera**: smoothed follow, bounded to the level (`limit_left/right/top/bottom`)
- **Level**: 360 procedurally spaced/positioned platforms, checkpoints every
  100m, coins on ~45% of platforms
- **Death/respawn**: fall-death detection, death screen, checkpoint-based respawn
- **Progression**: coins, 8 achievements, 5 purchasable skins, statistics screen
- **Save/load**: JSON persistence of best height, coins, skins, achievements, stats
- **UI**: main menu, HUD (height/best/coins/charge bar/pause), death screen,
  stats screen, skins screen, shared theme, toast notifications
- **Polish**: 3-layer infinite parallax background, procedurally generated
  placeholder SFX (jump/coin/checkpoint/death/click/unlock)
- **Android readiness**: touch controls, portrait lock, responsive anchored
  UI, mobile rendering method override

Full history by milestone: `PROJECT_SUMMARY.md`. What's explicitly *not* built
yet (endless generation, hazards, real art/audio, leaderboards, etc.):
`ROADMAP.md` and `PROJECT_SUMMARY.md`'s "not implemented yet" section.

## Folder structure

```
scripts/
  autoload/     SaveManager.gd, AudioManager.gd   — project singletons
  player/       Player.gd, Visual.gd
  world/        Main.gd, Checkpoint.gd, Coin.gd
  ui/           HUD.gd, MainMenu.gd, DeathScreen.gd, StatsScreen.gd,
                SkinsScreen.gd, TouchControls.gd
scenes/
  player/       Player.tscn
  world/        Main.tscn, Platform.tscn, Checkpoint.tscn, Coin.tscn
  ui/           HUD.tscn, MainMenu.tscn, DeathScreen.tscn, StatsScreen.tscn,
                SkinsScreen.tscn, TouchControls.tscn, theme.tres
docs/           all documentation, including this file
assets/, audio/ kept empty on purpose — no external assets anywhere
```
Convention: one script per node, grouped by domain, mirrored 1:1 between
`scripts/` and `scenes/`. Follow this split for anything new.

## Complete scene hierarchy

**`scenes/world/Main.tscn`** (root gameplay scene) — the `.tscn` only declares
the parallax background + 4 instanced children; everything else is spawned at
runtime by `Main.gd`:
```
Main (Node2D, Main.gd)
├── ParallaxBackground
│   ├── Far   (motion_scale 0.2, mirrors every 960px) — 3× Polygon2D mountains
│   ├── Mid   (motion_scale 0.5, mirrors every 960px) — 2× Polygon2D hills
│   └── Near  (motion_scale 0.8, mirrors every 960px) — 2× Polygon2D clouds
├── Player (Player.tscn instance)
├── HUD (HUD.tscn instance)
├── TouchControls (TouchControls.tscn instance)
├── DeathScreen (DeathScreen.tscn instance, hidden)
├── Platform × 360           — spawned by Main._generate_platforms()
├── Checkpoint × ~9          — spawned every 100m by Main._generate_checkpoints()
└── Coin × N (~45% of platforms) — spawned by Main._generate_platforms()
```

**`scenes/player/Player.tscn`**
```
Player (CharacterBody2D, Player.gd)
├── CollisionShape2D (CircleShape2D, r=24)
├── Camera2D (smoothed, speed 6.0)
└── Visual (Node2D, Visual.gd) — draws body + charge ring
```

**`scenes/world/Platform.tscn`**: `StaticBody2D` + `CollisionShape2D`
(160×24 rect) + `Polygon2D` (visual rect). No script.

**`scenes/world/Checkpoint.tscn`**: `Area2D` (Checkpoint.gd) +
`CollisionShape2D` (540×24, full screen width) + `PolePolygon` + `FlagPolygon`
(turns green on activation).

**`scenes/world/Coin.tscn`**: `Area2D` (Coin.gd, draws itself via `_draw()`) +
`CollisionShape2D` (circle, r=12).

**`scenes/ui/HUD.tscn`** (CanvasLayer, HUD.gd):
`HeightLabel`, `BestLabel`, `CoinLabel`, `PauseButton`, `ChargeLabel`,
`ChargeBarBG` → `ChargeBarFill`, `Toast` (hidden) → `ToastLabel`, `ToastTimer`,
`PauseOverlay` (hidden, `PROCESS_MODE_ALWAYS`) → `DimBG` + `Panel` →
`VBoxContainer`(`TitleLabel`, `ResumeButton`, `MenuButton`).

**`scenes/ui/DeathScreen.tscn`** (CanvasLayer, `PROCESS_MODE_ALWAYS`, hidden):
`DimBG` + `Panel` → `VBoxContainer`(`TitleLabel`, `HeightLabel`, `BestLabel`,
`CoinsLabel`, `Spacer`, `RespawnButton`, `MenuButton`).

**`scenes/ui/MainMenu.tscn`** (Control): `Background` + `CenterContainer` →
`VBoxContainer`(`TitleLabel`, `SubtitleLabel`, `Spacer`, `PlayButton`,
`SkinsButton`, `StatsButton`, `QuitButton`).

**`scenes/ui/StatsScreen.tscn`** / **`scenes/ui/SkinsScreen.tscn`** (Control):
title + back button + `ScrollContainer` whose inner container (`VBoxContainer`
/ `GridContainer`) is **populated at runtime** from `SaveManager.ACHIEVEMENTS`
/ `SaveManager.SKINS` — no hand-authored rows/cards in the `.tscn`.

**`scenes/ui/TouchControls.tscn`** (CanvasLayer): `LeftButton`, `RightButton`
(bottom-left), `JumpButton` (bottom-right, larger).

Full annotated version: `ARCHITECTURE.md`.

## Complete script hierarchy

- **`scripts/autoload/SaveManager.gd`** (autoload) — owns all persistent state
  + the `SKINS`/`ACHIEVEMENTS` data tables. See "Save/load systems" below.
- **`scripts/autoload/AudioManager.gd`** (autoload) — generates and caches
  placeholder tone SFX; `AudioManager.play("name")`.
- **`scripts/player/Player.gd`** — `CharacterBody2D`: gravity, movement,
  charge-jump, squash/stretch. Reads `SaveManager.get_selected_skin_color()`
  for its idle color; calls `AudioManager.play("jump")` and
  `SaveManager.record_jump()` on release.
- **`scripts/player/Visual.gd`** — pure-presentation `Node2D`, draws the
  circle + charge ring; scale-independent of the physics collision shape.
- **`scripts/world/Main.gd`** — the orchestrator: generates platforms/
  checkpoints/coins, sets camera bounds, runs the per-frame HUD update loop,
  and owns the death → pause → death-screen → respawn flow.
- **`scripts/world/Checkpoint.gd`** — `Area2D`; `body_entered` (player group)
  → activates once, emits `activated(self)`.
- **`scripts/world/Coin.gd`** — `Area2D`; spins, draws itself, `body_entered`
  (player group) → emits `collected`, frees itself.
- **`scripts/ui/*.gd`** — one script per screen; each only talks to
  `SaveManager`/`AudioManager` and `get_tree().change_scene_to_file(...)`, no
  direct UI-to-UI references. `TouchControls.gd` simulates
  `Input.action_press/release` for the same actions Player.gd already polls —
  this is why touch works with zero changes to Player.gd.

Full method-by-method breakdown: `ARCHITECTURE.md`.

## Autoloads and managers

```
[autoload]   (in project.godot)
SaveManager="*res://scripts/autoload/SaveManager.gd"
AudioManager="*res://scripts/autoload/AudioManager.gd"
```
Both `process_mode = PROCESS_MODE_ALWAYS` (keep working while the tree is
paused — needed for save-on-quit and UI click sounds during the death/pause
overlays). **No other autoloads exist** — no SceneManager, no GameState, no
EventBus. Run-scoped state (current checkpoint, this run's checkpoint count)
deliberately lives as plain variables on `Main.gd`, not in an autoload,
because it's meaningless outside `world/Main.tscn`.

## Save/load systems

File: `user://savegame.json` (JSON). Schema:
```jsonc
{
  "best_height": 0, "total_coins": 0,
  "unlocked_skins": ["default"], "selected_skin": "default",
  "achievements": {},   // { "<id>": true } once unlocked
  "stats": { "total_jumps": 0, "total_deaths": 0, "total_runs": 0,
             "total_coins_collected": 0, "total_checkpoints": 0,
             "best_checkpoints_in_run": 0 }
}
```
`SaveManager._merge_defaults()` back-fills missing keys from older saves —
**only ever add keys to this schema, never rename/remove without a migration.**
Saves are event-triggered, not per-frame: run start, best-height PR, death,
checkpoint, skin purchase/equip, achievement unlock, app close/background, and
every "return to Main Menu" action. `SKINS` (5: default/sunset/forest/royal/
gold) and `ACHIEVEMENTS` (8: first_jump, height_100/500/1000, coins_50/200,
deaths_10, checkpoints_5) are compile-time constants in `SaveManager.gd`, not
saved to disk — only unlock state persists.

## UI systems

Shared `Theme` resource (`scenes/ui/theme.tres`) applied project-wide via
`[gui] theme/custom`; defines rounded `StyleBoxFlat` Button states and a
translucent rounded Panel style used behind every overlay. All screens use
anchor-based (not fixed-pixel) `Control` layout for responsiveness across
aspect ratios. The HUD charge bar animates `ChargeBarFill.anchor_right`
directly from `0..1` (not a `ProgressBar`), color-shifting green→yellow→red at
0.4/0.8 thresholds. One shared `Toast` node handles both checkpoint and
achievement notifications (last one wins if they'd overlap — acceptable,
not queued). Death screen and the HUD pause overlay are both
`PROCESS_MODE_ALWAYS` so their buttons work while `get_tree().paused` is true.

## Android export status

**Project settings: ready.** Portrait lock
(`window/handheld/orientation="portrait"`), mobile renderer override
(`renderer/rendering_method.mobile="mobile"`), touch controls, responsive UI —
all done, all in source.

**Actual export: not done, and currently blocked by placeholder config.** An
`export_presets.cfg` exists with one `Android` preset, but:
- `package/unique_name` is still Godot's placeholder `com.example.$genname`
- `package/name` / `version/name` are empty
- No keystore is configured

No APK/AAB has been built. Full checklist: `RELEASE_CHECKLIST.md`. Full
narrative walkthrough (SDK/JDK/keystore setup from scratch):
`EXPORT_ANDROID.md`.

## Current blockers

1. **Android export preset needs real values** (package name, version,
   keystore) before any build can be produced — see above and
   `RELEASE_CHECKLIST.md`.
2. **No live Godot editor access in the environment that built most of this
   project.** Everything has been reviewed by hand against Godot 4 semantics,
   not editor-verified, except where the developer has explicitly run it and
   reported back (as happened with the scene-save bug). Treat anything not
   explicitly marked "editor-verified" in `KNOWN_BUGS.md` as reviewed-but-untested.

## Known bugs

- **Fixed**: the "Couldn't save scene" error (stale editor cache pointing at a
  deleted pre-reorg `Main.tscn`, not a source bug) and a `load_steps`
  mismatch in `Checkpoint.tscn`. Full detail: `KNOWN_BUGS.md`, `HANDOFF.md`.
- **Open gaps** (design/scope, not bugs): platform reachability isn't
  guaranteed; level is finite (~1000m) not endless; no hazards/obstacles yet;
  toast notifications aren't queued. Full list with severity: `KNOWN_BUGS.md`.
- **Housekeeping**: an untracked `TheWall.bundle` git-bundle file sits at the
  project root (not part of the game); the orphaned `node_2d.tscn` at the
  project root is unreferenced and safe to delete. Neither has been touched by
  any documentation-only pass.

## Remaining roadmap

From `ROADMAP.md`, in rough priority order:
1. Reachability guarantees for platform generation
2. Hazards/obstacles (moving/crumbling platforms, spikes)
3. Endless/streamed level generation
4. Real art & audio (replacing primitive shapes / generated tones)
5. Leaderboards
6. Tutorial/onboarding
7. Accessibility (colorblind-safe charge bar, adjustable sensitivity, haptics)
8. Actually complete an Android export (see blockers above)
9. iOS export (not scoped yet)

Explicitly out of scope: pay-to-win monetization, multiplayer, non-portrait
orientation.

## Top priorities after reset

If you're a fresh session with no other context, in order:

1. **Verify the project still opens/runs/saves cleanly** in Godot 4.7.2 — the
   fastest sanity check that nothing has drifted since this doc pass.
2. **Do a full playthrough** per the QA checklist in `RELEASE_CHECKLIST.md`
   ("General pre-ship QA") — this project has never been verified by an actual
   editor session end-to-end from within an agent's tool loop.
3. **Fill in the Android export preset** (`RELEASE_CHECKLIST.md`) if Android
   is the near-term goal — it's the single concrete blocker between "ready"
   and "shipped."
4. **Pick one item from "Remaining roadmap"** based on what the
   developer actually wants next — don't assume; ask if it's not obvious from
   the conversation. Reachability guarantees and hazards/obstacles are the two
   most requested-by-implication (vision explicitly calls for obstacles;
   reachability is a known fairness gap).
5. **Keep this file current.** Any change that adds a system, fixes a bug, or
   completes a roadmap item should update the relevant section here (and in
   whichever specialized doc owns that detail) in the same pass — don't let
   `MASTER_HANDOFF.md` silently go stale.

## Recommended future Claude prompts

Concrete prompts a developer could hand to the next session, grouped by the
roadmap above:

- *"Read docs/MASTER_HANDOFF.md, then add a reachability check to platform
  generation in Main.gd so no gap's combined vertical+horizontal distance ever
  exceeds what a max-charge jump plus full-speed air movement can cover."*
- *"Read docs/MASTER_HANDOFF.md, then add one hazard type — a platform that
  crumbles (disappears) 0.5s after the player lands on it — as a new scene
  under scenes/world/, following the existing Platform/Checkpoint/Coin pattern."*
- *"Read docs/MASTER_HANDOFF.md and docs/RELEASE_CHECKLIST.md, then walk me
  through filling in the Android export preset's package name, version, and
  keystore — I have [package name] and [keystore path] ready."*
- *"Read docs/MASTER_HANDOFF.md, then convert Main.gd's level generation from
  upfront (all 360 platforms at once) to chunked/streamed generation so the
  climb can be effectively endless — unload platforms far below the camera,
  generate more as the player approaches the current top."*
- *"Read docs/MASTER_HANDOFF.md, then add a simple first-run tutorial hint
  ('hold to charge, release to jump') shown once via a new SaveManager flag,
  dismissed on the player's first successful jump."*
- *"Read docs/KNOWN_BUGS.md and do a fresh dependency audit like the one
  described in HANDOFF.md's 'Editor cache incident' — confirm no new stale
  references have crept in since the last pass."*

## Full project tree

```
TheWall/
├── project.godot, export_presets.cfg, icon.svg(+.import)
├── node_2d.tscn                    orphan, unreferenced, safe to delete
├── TheWall.bundle                  untracked git-bundle artifact, not game data
├── assets/, assets/scripts/, audio/    empty on purpose, no external assets
├── docs/
│   ├── MASTER_HANDOFF.md           ← this file
│   ├── PROJECT_SUMMARY.md, ARCHITECTURE.md, PROJECT_TREE.md,
│   │   RELEASE_CHECKLIST.md, KNOWN_BUGS.md
│   └── GAME_VISION.md, ROADMAP.md, HANDOFF.md, EXPORT_ANDROID.md
├── scenes/
│   ├── player/Player.tscn
│   ├── world/Main.tscn, Platform.tscn, Checkpoint.tscn, Coin.tscn
│   └── ui/HUD.tscn, MainMenu.tscn, DeathScreen.tscn, StatsScreen.tscn,
│         SkinsScreen.tscn, TouchControls.tscn, theme.tres
└── scripts/
    ├── autoload/SaveManager.gd, AudioManager.gd
    ├── player/Player.gd, Visual.gd
    ├── world/Main.gd, Checkpoint.gd, Coin.gd
    └── ui/HUD.gd, MainMenu.gd, DeathScreen.gd, StatsScreen.gd,
          SkinsScreen.gd, TouchControls.gd
```
Every `.gd` file has a matching `.gd.uid` sidecar (Godot 4.7 auto-generated,
omitted above for readability). Fully annotated version: `PROJECT_TREE.md`.

## Android release checklist (condensed)

Full checkboxes: `RELEASE_CHECKLIST.md`. Summary of what's outstanding:
1. Machine setup: JDK 17, Android SDK, export templates for 4.7.2, keystores
2. Fill in `export_presets.cfg`'s `Android` preset: real package name,
   version, keystore paths (currently all placeholder/empty)
3. Replace `icon.svg` (default placeholder) before public release
4. Export and test a debug APK on real hardware — touch controls, HUD
   legibility, orientation lock, save-persistence-across-kill
5. For Play Store: export as `.aab`, meet current Target SDK minimum, confirm
   no unexpected permissions
