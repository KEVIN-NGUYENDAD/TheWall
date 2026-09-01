# THE WALL — Technical Handoff

Godot 4.7, GDScript only, no external art/audio assets (all visuals are primitive
shapes; all SFX are procedurally generated tones). Read `GAME_VISION.md` for the
creative brief, `ROADMAP.md` for what's next, and `EXPORT_ANDROID.md` for the
Android export checklist.

## How to run

1. Open Godot 4.7, **Import** `project.godot` from the project root.
2. Press F5. The game boots into `scenes/ui/MainMenu.tscn` (set as `run/main_scene`).
3. Desktop controls: hold left mouse button anywhere to charge jump, release to jump;
   A/D or arrow keys to move. On-screen touch buttons (bottom corners) work with a
   mouse too, so touch controls are testable on desktop.

## Folder structure

```
scripts/
  autoload/     SaveManager.gd, AudioManager.gd  (project singletons)
  player/       Player.gd, Visual.gd
  world/        Main.gd, Checkpoint.gd, Coin.gd
  ui/           HUD.gd, MainMenu.gd, DeathScreen.gd, StatsScreen.gd,
                SkinsScreen.gd, TouchControls.gd
scenes/
  player/       Player.tscn
  world/        Main.tscn, Platform.tscn, Checkpoint.tscn, Coin.tscn
  ui/           HUD.tscn, MainMenu.tscn, DeathScreen.tscn, StatsScreen.tscn,
                SkinsScreen.tscn, TouchControls.tscn, theme.tres
docs/           GAME_VISION.md, ROADMAP.md, HANDOFF.md (this file), EXPORT_ANDROID.md
assets/, audio/ kept empty on purpose — no external assets are used anywhere
```

## Scene flow

```
MainMenu.tscn  --Play-->  world/Main.tscn  --pause/menu/death-->  MainMenu.tscn
     |--Skins--> ui/SkinsScreen.tscn --Back--> MainMenu.tscn
     '--Stats--> ui/StatsScreen.tscn --Back--> MainMenu.tscn
```

`world/Main.tscn` hierarchy at runtime:

```
Main (Main.gd)
├── ParallaxBackground (Far / Mid / Near ParallaxLayers, Polygon2D shapes,
│                        motion_mirroring for infinite vertical tiling)
├── Player (Player.tscn — CharacterBody2D + CollisionShape2D + Camera2D + Visual)
├── HUD (CanvasLayer — height/best/coins, charge bar, pause overlay, toast)
├── TouchControls (CanvasLayer — left/right/jump buttons)
├── DeathScreen (CanvasLayer, hidden — shown on fall)
├── Platform × ~360 (spawned in Main._generate_platforms)
├── Checkpoint × ~9 (spawned every 100m in Main._generate_checkpoints)
└── Coin × N (spawned probabilistically above platforms)
```

## Autoload singletons

- **SaveManager** (`scripts/autoload/SaveManager.gd`): owns all persistent state
  (`data: Dictionary`) — best height, total coins, unlocked/selected skin,
  achievements, stats. Reads/writes `user://savegame.json` as JSON. Also owns the
  `SKINS` and `ACHIEVEMENTS` const tables (single source of truth — add a skin or
  achievement here and it shows up in `SkinsScreen`/`StatsScreen` automatically).
  Saves on meaningful events (best-height PR, death, checkpoint, skin purchase,
  achievement unlock) and on app close/background — not every frame.
- **AudioManager** (`scripts/autoload/AudioManager.gd`): generates short sine-wave
  "beep" `AudioStreamWAV` clips at startup (jump/coin/checkpoint/death/click/unlock)
  and plays them via `AudioManager.play("jump")` etc. No audio files anywhere. Swap
  `_cache[...]` entries for real `AudioStreamWAV`/`AudioStreamOggVorbis` resources
  when real SFX/music are ready — call sites don't need to change.

Both are `process_mode = PROCESS_MODE_ALWAYS` so saving and UI-click sounds keep
working while `get_tree().paused` is true (death screen, pause menu).

## Key tuning constants

- `scripts/player/Player.gd`: `MOVE_SPEED`, `RISE_GRAVITY`/`FALL_GRAVITY`,
  `MIN_JUMP_SPEED`/`MAX_JUMP_SPEED`, `MAX_CHARGE_TIME`, `COYOTE_TIME`.
- `scripts/world/Main.gd`: `PLATFORM_COUNT` (currently 360, ~1000m ceiling),
  `MIN_GAP`/`MAX_GAP` (vertical spacing, must stay under max jump height),
  `CHECKPOINT_INTERVAL_M`, `COIN_CHANCE`.
- `scenes/ui/theme.tres`: shared Button/Panel styling for every screen.

## Known limitations / honest gaps

- **Platform reachability isn't guaranteed.** x-position is fully random per
  platform; an unlucky run could place a gap that's technically jumpable in height
  but awkward horizontally. Not a crash risk, just a fairness/tuning gap — see
  Roadmap.
- **Level is finite, not endless** (~360 platforms, ~1000m). Vision implies an
  "enormous wall"; current implementation generates the whole thing upfront rather
  than streaming it, which is fine at this size but won't scale to a truly endless
  climb without chunked generation.
- **Android export was not completed here.** Project settings are export-ready
  (portrait lock, mobile renderer override, touch controls, responsive anchors),
  but actually producing an APK/AAB is machine-specific (local Android SDK/JDK,
  keystore, export templates) and wasn't done automatically — see
  `EXPORT_ANDROID.md` for the full checklist.
- **No environment/tests.** There's no Godot binary in this environment, so none
  of the above was verified by actually running the editor — it was built and
  reviewed by hand against Godot 4 GDScript/scene-format semantics. Recommend a
  full playthrough (menu → play → fall → respawn → checkpoint → death → menu →
  skins → stats → quit) as the first thing after opening the project.

## Editor cache incident (fixed)

After the v3–v5 folder reorg, the old flat-layout `scenes/Main.tscn` (and its
former children `scenes/Player.tscn`, `scenes/HUD.tscn`, `scenes/Platform.tscn`)
were deleted from disk via direct file operations rather than the Godot editor's
own move/delete tools. Godot's `.godot/editor/editor_layout.cfg` still had that
dead path recorded as the open/current scene, so it kept reopening a scene tab
whose in-memory dependency tree pointed at files that no longer existed —
producing "Couldn't save scene. Likely dependencies (instances or inheritance)
couldn't be satisfied." on every save attempt. Fixed by repointing
`editor_layout.cfg` at the real `res://scenes/world/Main.tscn`, clearing the
stale per-scene edit-state cache and the UID/filesystem caches, and correcting an
unrelated `load_steps` mismatch found in `Checkpoint.tscn` during the audit.

**Lesson for future changes**: when renaming, moving, or deleting `.tscn`/`.gd`/
`.tres` files, prefer doing it from inside the Godot editor's FileSystem dock (it
updates its own caches and fixes up references automatically) over raw
filesystem operations. If files must be moved outside the editor, a full
editor restart afterward is the minimum safe step, and clearing `.godot/` is a
safe last resort if stale-reference errors show up (it's disposable, regenerable
cache — never version-controlled).

## If you're picking this up cold

1. Open the project, hit F5, play through once end-to-end (see checklist above).
2. Check `docs/ROADMAP.md` for prioritized next steps.
3. Any new skin/achievement: add one entry to the `SKINS`/`ACHIEVEMENTS` dict in
   `SaveManager.gd` — the Skins/Stats screens pick them up with no other changes.
4. Any new SFX: add a `_cache["name"] = _make_tone(...)` line in `AudioManager.gd`,
   call `AudioManager.play("name")` wherever needed.
