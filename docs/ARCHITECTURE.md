# THE WALL — Architecture

Technical reference for how the project is actually wired together: scene
trees, script responsibilities, autoloads, save data, and UI flow. Pair with
`PROJECT_TREE.md` for the raw file list. Godot 4.7.2, GDScript only.

---

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
docs/           all project documentation (this file included)
assets/, audio/ kept empty on purpose — no external assets anywhere in the project
```

Convention: one script per node type, grouped by domain (`player` / `world` /
`ui` / `autoload`), mirrored 1:1 between `scripts/` and `scenes/`. When adding a
new gameplay object or screen, follow the same split.

---

## Scene flow (navigation graph)

```
MainMenu.tscn  --Play-->        world/Main.tscn
     |                                │
     |--Skins--> ui/SkinsScreen.tscn  │  pause / death / menu-button
     |    --Back--> MainMenu.tscn     └────────────> MainMenu.tscn
     '--Stats--> ui/StatsScreen.tscn
          --Back--> MainMenu.tscn
```

All transitions go through `get_tree().change_scene_to_file(...)` — there is no
custom SceneManager singleton; `SaveManager` is the only autoload, and each
screen's script calls `change_scene_to_file` directly. `project.godot`'s
`run/main_scene` is `res://scenes/ui/MainMenu.tscn`.

---

## Complete scene hierarchy

### `scenes/player/Player.tscn`
```
Player (CharacterBody2D, Player.gd)
├── CollisionShape2D (CircleShape2D, radius 24)
├── Camera2D (position_smoothing_enabled, speed 6.0)
└── Visual (Node2D, Visual.gd)        — draws the circle body + charge-ring via _draw()
```

### `scenes/world/Platform.tscn`
```
Platform (StaticBody2D)               — no script
├── CollisionShape2D (RectangleShape2D 160×24)
└── Polygon2D (rectangle, gray)
```

### `scenes/world/Checkpoint.tscn`
```
Checkpoint (Area2D, Checkpoint.gd)
├── CollisionShape2D (RectangleShape2D 540×24 — spans full screen width)
├── PolePolygon (Polygon2D)
└── FlagPolygon (Polygon2D — turns green when activated)
```

### `scenes/world/Coin.tscn`
```
Coin (Area2D, Coin.gd)                — visual drawn via _draw(), no child Sprite
└── CollisionShape2D (CircleShape2D, radius 12)
```

### `scenes/ui/HUD.tscn`
```
HUD (CanvasLayer, HUD.gd)
├── HeightLabel                       top-left, current height
├── BestLabel                         top-left, below HeightLabel
├── CoinLabel                         top-right
├── PauseButton                       top-right corner
├── ChargeLabel                       "HOLD TO CHARGE", above the bar
├── ChargeBarBG (ColorRect)
│   └── ChargeBarFill (ColorRect)     anchor_right animated 0→1 to show charge %, color-shifts green→yellow→red
├── Toast (Panel, hidden)             top-center, used for checkpoint + achievement notifications
│   └── ToastLabel
├── ToastTimer (Timer, 2s one-shot)
└── PauseOverlay (Control, hidden, PROCESS_MODE_ALWAYS)
    ├── DimBG (ColorRect)
    └── Panel
        └── VBoxContainer: TitleLabel, ResumeButton, MenuButton
```

### `scenes/ui/DeathScreen.tscn`
```
DeathScreen (CanvasLayer, DeathScreen.gd, PROCESS_MODE_ALWAYS, hidden by default)
├── DimBG (ColorRect)
└── Panel
    └── VBoxContainer: TitleLabel, HeightLabel, BestLabel, CoinsLabel, Spacer,
                        RespawnButton, MenuButton
```

### `scenes/ui/MainMenu.tscn`
```
MainMenu (Control, MainMenu.gd)
├── Background (ColorRect)
└── CenterContainer
    └── VBoxContainer: TitleLabel, SubtitleLabel, Spacer,
                        PlayButton, SkinsButton, StatsButton, QuitButton
```

### `scenes/ui/StatsScreen.tscn`
```
StatsScreen (Control, StatsScreen.gd)
├── Background (ColorRect)
├── TitleLabel
├── BackButton
└── ScrollContainer
    └── VBoxContainer                 populated at runtime: stat rows + achievement rows
```

### `scenes/ui/SkinsScreen.tscn`
```
SkinsScreen (Control, SkinsScreen.gd)
├── Background (ColorRect)
├── TitleLabel
├── CoinsLabel
├── BackButton
└── ScrollContainer
    └── GridContainer (3 columns)     populated at runtime: one card per skin
```

### `scenes/ui/TouchControls.tscn`
```
TouchControls (CanvasLayer, TouchControls.gd)
├── LeftButton    (bottom-left)
├── RightButton   (bottom-left, beside Left)
└── JumpButton    (bottom-right, larger)
```

### `scenes/world/Main.tscn` — root gameplay scene, **runtime** tree

The `.tscn` file itself only declares the parallax background and four
instanced children (Player, HUD, TouchControls, DeathScreen). Everything else
below is spawned procedurally by `Main.gd` at `_ready()`:

```
Main (Node2D, Main.gd)
├── ParallaxBackground
│   ├── Far   (ParallaxLayer, motion_scale 0.2, motion_mirroring (0,960)) — 3× Polygon2D mountains
│   ├── Mid   (ParallaxLayer, motion_scale 0.5, motion_mirroring (0,960)) — 2× Polygon2D hills
│   └── Near  (ParallaxLayer, motion_scale 0.8, motion_mirroring (0,960)) — 2× Polygon2D clouds
├── Player                              (Player.tscn instance)
├── HUD                                 (HUD.tscn instance)
├── TouchControls                       (TouchControls.tscn instance)
├── DeathScreen                         (DeathScreen.tscn instance, hidden)
├── Platform × 360                      spawned in Main._generate_platforms()
├── Checkpoint × ~9                     spawned every 100m in Main._generate_checkpoints()
└── Coin × N (~45% of platforms)        spawned in Main._generate_platforms()
```

---

## Complete script hierarchy & responsibilities

### `scripts/autoload/SaveManager.gd` (autoload singleton)
Owns ALL persistent state in one `data: Dictionary`, and the two static data
tables `SKINS` and `ACHIEVEMENTS` (single source of truth — add an entry and
`SkinsScreen`/`StatsScreen` pick it up automatically, no other code changes).

- `load_game()` / `save_game()` — JSON at `user://savegame.json`, with
  `_merge_defaults()` so old save files gain new fields without crashing.
- Event methods gameplay code calls: `start_run()`, `record_jump()`,
  `record_death()`, `record_checkpoint(count)`, `update_best_height(height)`,
  `add_coins(amount)`, `unlock_skin(id)`, `select_skin(id)`,
  `unlock_achievement(id)`.
- `get_selected_skin_color() -> Color` — read by `Player.gd` every frame.
- Signals: `data_changed`, `achievement_unlocked(id)`, `coins_changed(total)`.
- `process_mode = PROCESS_MODE_ALWAYS` and saves on
  `NOTIFICATION_WM_CLOSE_REQUEST` / `NOTIFICATION_APPLICATION_PAUSED` (desktop
  close / Android backgrounding).
- **Does not** save every frame — only on meaningful state changes (see
  "Save/load system" below).

### `scripts/autoload/AudioManager.gd` (autoload singleton)
Generates short sine-wave tone `AudioStreamWAV` clips at `_ready()` (no audio
files anywhere) and caches them by name: `jump`, `coin`, `checkpoint`, `death`,
`click`, `unlock`. Call sites use `AudioManager.play("name")`. `_make_tone()`
and `_make_chime()` (multi-note) are the two generators;
`process_mode = PROCESS_MODE_ALWAYS` so UI-click sounds work while paused.

### `scripts/player/Player.gd`
`CharacterBody2D`. Owns movement, the hold-to-charge / release-to-jump
mechanic, gravity, and squash/stretch feel:
- `_apply_gravity()` — asymmetric rise/fall gravity + terminal velocity.
- `_handle_movement()` — `Input.get_axis("move_left","move_right")`, different
  accel grounded vs airborne.
- `_handle_charge_and_jump()` — coyote-time-gated charge accumulation,
  `_release_jump()` on release (calls `AudioManager.play("jump")` and
  `SaveManager.record_jump()`).
- `reset_charge()` — called by `Main.gd` on respawn.
- `get_charge_ratio() -> float` — read by `Main.gd` every frame for the HUD bar.
- `_update_visual()` — pushes color/scale/charge state into the `Visual` child
  each frame; color = `SaveManager.get_selected_skin_color()` unless charging
  (charging always shows the fixed `CHARGE_COLOR` regardless of equipped skin).

### `scripts/player/Visual.gd`
Pure presentation `Node2D`. Public fields (`radius`, `body_color`,
`charge_ratio`, `is_charging`) are set by `Player.gd`; `_draw()` renders the
circle + charge arc. Kept as a separate node so scale-based squash/stretch
never touches the physics `CollisionShape2D`.

### `scripts/world/Main.gd`
The gameplay orchestrator. Everything about a run lives here:
- `_generate_platforms()` — places 360 platforms with random vertical gap
  (`MIN_GAP`–`MAX_GAP`) and random x, spawns coins probabilistically, returns
  the topmost platform's y (used for camera limits).
- `_generate_checkpoints(top_y)` — walks every 100m threshold up to the total
  climbable height and spawns a full-width `Checkpoint` at each.
- `_setup_camera(top_y)` — sets `Camera2D.limit_left/right/top/bottom`.
- `_process()` — computes current height, pushes it + charge + coins to the
  HUD every frame, calls `SaveManager.update_best_height()`, and triggers
  `_die()` if the player falls past `kill_y`.
- `_die()` / `_on_respawn_requested()` / `_on_menu_requested()` — the
  death/respawn/pause-to-menu flow (see "Death, respawn, and pause flow" below).

### `scripts/world/Checkpoint.gd`
`Area2D`. `body_entered` → if the body is in the `"player"` group and this
checkpoint isn't already active, turns the flag green and emits
`activated(self)`. `Main.gd` listens and updates the respawn point.

### `scripts/world/Coin.gd`
`Area2D`. Spins via `rotation += 3.0 * delta` in `_process()`, draws itself
with `_draw()`. On `body_entered` from the `"player"` group: emits `collected`
and `queue_free()`s itself. `Main.gd` listens and banks the coin immediately
(`SaveManager.add_coins(1)`).

### `scripts/ui/*.gd`
Each screen script only talks to `SaveManager`/`AudioManager` and
`get_tree().change_scene_to_file(...)` — no direct references between UI
screens. `StatsScreen.gd` and `SkinsScreen.gd` build their rows/cards
programmatically from `SaveManager.ACHIEVEMENTS` / `SaveManager.SKINS` rather
than hand-authored nodes, so new skins/achievements need zero scene edits.
`TouchControls.gd` simulates `Input.action_press/release` for
`move_left`/`move_right`/`charge_jump` — this is why touch buttons work with no
changes to `Player.gd`, which only ever polls the `Input` singleton.

---

## Autoloads and managers

Declared in `project.godot`:
```
[autoload]
SaveManager="*res://scripts/autoload/SaveManager.gd"
AudioManager="*res://scripts/autoload/AudioManager.gd"
```
Both are `process_mode = PROCESS_MODE_ALWAYS`. No other autoloads exist — there
is no SceneManager, no GameState, no EventBus. Scene transitions are direct
`change_scene_to_file` calls; run-scoped state (current checkpoint, current
run's checkpoint count) lives as plain variables on `Main.gd`, not in an
autoload, because it's meaningless outside of `world/Main.tscn`.

---

## Save/load system

**File**: `user://savegame.json` (JSON, via `JSON.stringify`/`JSON.parse_string`).

**Schema** (`SaveManager._default_data()`):
```jsonc
{
  "best_height": 0,
  "total_coins": 0,
  "unlocked_skins": ["default"],
  "selected_skin": "default",
  "achievements": {},                 // populated as { "<id>": true } on unlock
  "stats": {
    "total_jumps": 0,
    "total_deaths": 0,
    "total_runs": 0,
    "total_coins_collected": 0,
    "total_checkpoints": 0,
    "best_checkpoints_in_run": 0
  }
}
```
`_merge_defaults()` back-fills any keys missing from an older save file
(top-level and inside `stats`), so schema additions are non-breaking as long as
you only ever *add* keys, never rename/remove them without a migration.

**When it saves** (not every frame — deliberately throttled):
- `start_run()` — scene enter of `world/Main.tscn`
- `update_best_height()` — only when best actually increases
- `record_death()`, `record_checkpoint()`
- `unlock_skin()`, `select_skin()`, `unlock_achievement()`
- App close / Android background (`_notification()`)
- Manually before any `change_scene_to_file("...MainMenu.tscn")` call from
  HUD's pause menu, DeathScreen's menu button, and MainMenu's quit button

**Data tables** (`SKINS`, `ACHIEVEMENTS`) are compile-time constants in
`SaveManager.gd`, not saved to disk — only *unlock state* is persisted.

Current skins: `default` (free), `sunset` (50), `forest` (100), `royal` (200),
`gold` (400). Current achievements: `first_jump`, `height_100`, `height_500`,
`height_1000`, `coins_50`, `coins_200`, `deaths_10`, `checkpoints_5`.

---

## UI systems

- **Shared theme**: `scenes/ui/theme.tres`, applied globally via
  `project.godot` → `[gui] theme/custom`. Defines `Button` states
  (normal/hover/pressed/disabled/focus, all rounded `StyleBoxFlat`) and a
  `Panel` style used as the translucent rounded background behind every
  overlay (DeathScreen, pause overlay, and implicitly any future modal).
- **Responsive layout**: every screen uses anchor-based `Control` layout
  (fractional anchors + pixel offsets from the anchored edge), not fixed
  absolute positions — this is what's meant to make the UI hold up across
  different device aspect ratios under `window/stretch/aspect="expand"`.
- **HUD charge bar**: `ChargeBarFill.anchor_right` is driven directly from
  `player.get_charge_ratio()` each frame (0→1), with color thresholds at 0.4
  and 0.8 (green → yellow → red). This is an anchor animation, not a
  `ProgressBar` control — deliberate, so it scales with the bar's actual pixel
  width at any resolution without extra math.
- **Toasts**: one shared `Toast` node in `HUD.tscn` used for both checkpoint
  and achievement-unlock notifications (`HUD.show_toast(text)`), auto-hidden by
  a one-shot `Timer`. Last call wins if two toasts would overlap — acceptable
  for this game's pacing, not designed for queuing.
- **Death, respawn, and pause flow**:
  - Falling past `kill_y` → `Main._die()` → `get_tree().paused = true` +
    `DeathScreen.show_death(...)`.
  - DeathScreen's Respawn button → `Main._on_respawn_requested()` → unpauses,
    moves the player to `current_checkpoint_position`, resets velocity/charge.
  - DeathScreen and the HUD's `PauseOverlay` are both `PROCESS_MODE_ALWAYS` so
    their buttons stay clickable while `get_tree().paused` is true; everything
    else (including `Main.gd`'s own `_process`) correctly freezes.
  - HUD's pause button → same pause pattern, with Resume/Main Menu instead of
    Respawn/Main Menu.

---

## Android readiness (see `EXPORT_ANDROID.md` for the full walkthrough)

Project-settings side is done: portrait lock
(`window/handheld/orientation="portrait"`), mobile renderer override
(`renderer/rendering_method.mobile="mobile"`), touch input (plain `Button`
nodes in `TouchControls.tscn`, no special touch API needed), and anchor-based
responsive UI throughout. An `export_presets.cfg` with one `Android` preset now
exists in the repo, but it's still using Godot's generated placeholder values
(`package/unique_name="com.example.$genname"`, empty `package/name`/
`version/name`, no keystore configured) — see `RELEASE_CHECKLIST.md` before
trying to build from it.
