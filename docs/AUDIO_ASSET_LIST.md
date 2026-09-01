# Audio Asset List

Priority list of real audio files to source/produce for TheWall. These are
the exact files the engine is wired to load right now — drop a file at the
given path and it plays automatically, with **no code changes required**.
Until a file exists at a given path, that sound/track is silently skipped
(no crash, no placeholder tone, just silence for that one hook).

Do not generate placeholder or procedural audio for these — leave the paths
empty until real assets are ready.

## MUSIC — `res://audio/music/`

| File | Zone | Notes |
|---|---|---|
| `ruins_theme.ogg` | The Ruins (0–100m) | Loops. Bright, cheerful, adventurous. |
| `sky_theme.ogg` | The Sky (100–500m) | Loops. Uplifting, energetic, sun-drenched. |
| `void_theme.ogg` | The Void (500m+) | Loops. Mysterious, epic — not horror. |

All three play simultaneously at runtime and are crossfaded by volume based
on zone and progress, so each track should loop seamlessly and sit at a
similar perceived loudness to the others.

## SFX — `res://audio/sfx/`

| File | Used for |
|---|---|
| `jump.ogg` | Charge-jump release |
| `dash.ogg` | Air dash |
| `checkpoint.ogg` | Checkpoint activation |
| `death.ogg` | Falling / dying |
| `memory.ogg` | Memory reveal (100m/300m/700m/1500m) |
| `bird.ogg` | Bird encounter (rare white bird pickup and nest discovery) |
| `nearmiss.ogg` | Dying within 5m of a checkpoint |

## Format

- `.ogg` (Vorbis) preferred. `.mp3` and `.wav` are also supported — looping
  is configured automatically for whichever format is provided.
- No import settings need to be touched; just place the file at the path
  above.

## Scope note

A few additional SFX hooks (`coin`, `landing`, `hit`, `area_discovery`,
`click`, `unlock`) already exist in `AudioManager.gd` from earlier passes but
are outside this priority list — see `audio/README.md` for the full manifest.
