# Audio Asset List

Priority list of real audio files used by TheWall. These are the exact files
the engine is wired to load right now. Until a file exists at a given path,
that sound/track is silently skipped (no crash, no placeholder tone, just
silence for that one hook).

Do not generate placeholder or procedural audio — SFX below are still
awaiting real files; leave those paths empty until real assets are ready.

## MUSIC — `res://audio/music/` (in place, real tracks)

| File | Used for |
|---|---|
| `velariomusic-happy-vibes-591803.mp3` | Menu |
| `the_mountain-happy-happy-music-496549.mp3` | The Ruins (0–100m) |
| `jorisvermeer-happy-adventure-quest-572050.mp3` | The Sky (100–500m) |
| `the_mountain-fantasy-quest-184140.mp3` | The Void (500m+) |

Filenames are unmodified as sourced — do not rename. The three zone tracks
play simultaneously at runtime and are crossfaded by volume based on zone and
progress. The menu track plays independently on its own player.

## SFX — `res://audio/sfx/`

| File | Used for |
|---|---|
| `jump.ogg` | Charge-jump release |
| `dash.ogg` | Air dash |
| `checkpoint.ogg` | Checkpoint activation |
| `death.ogg` | Falling / dying |
| `memory.ogg` | Memory reveal (100m/300m/700m/1500m) |
| `nearmiss.ogg` | Dying within 5m of a checkpoint |

## Bird & Eagle — `res://audio/` (not `sfx/`)

| File | Used for |
|---|---|
| `bird_chirp.mp3` | Bird encounter (rare white bird pickup, nest discovery, common bird pickup) — **in place**, a real recording |
| `eagle.mp3` | Eagle telegraph (on appearance) and strike (on hit) — not yet supplied |

## Format

- `.ogg` (Vorbis) preferred. `.mp3` and `.wav` are also supported — looping
  is configured automatically for whichever format is provided.
- No import settings need to be touched; just place the file at the path
  above.

## Scope note

A few additional SFX hooks (`coin`, `landing`, `hit`, `area_discovery`,
`click`, `unlock`) already exist in `AudioManager.gd` from earlier passes but
are outside this priority list — see `audio/README.md` for the full manifest.
