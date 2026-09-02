# Audio Asset Manifest

See `docs/AUDIO_ASSET_LIST.md` for the current priority delivery list. This
file is the full manifest, including a few lower-priority hooks (`coin`,
`landing`, `area_discovery`, `click`, `unlock`) that already exist in code but
aren't part of that priority list yet.

This project no longer generates audio procedurally. `AudioManager` and
`MusicManager` load real audio files from the paths below; until a file
exists at a given path, that sound or track is silently skipped (no crash,
no placeholder tone — just silence for that one hook until it's filled in).

Drop files in with these exact names and Godot will pick them up automatically
— no code changes needed.

## Music (`audio/music/`) — real tracks in use

One track plays per **season** (not per zone) — only 3 real files exist, so
adjacent seasons share a track for a clear 3-act arc across the climb:

| File | Used for |
|---|---|
| `velariomusic-happy-vibes-591803.mp3` | Menu |
| `the_mountain-happy-happy-music-496549.mp3` | Spring + Summer (0–300m) |
| `jorisvermeer-happy-adventure-quest-572050.mp3` | Autumn (300–600m) |
| `the_mountain-fantasy-quest-184140.mp3` | Winter + Storm (600m+) |

These are the exact, unmodified filenames as sourced — do not rename them;
`MusicManager`'s path constants reference them directly.

Only one season track plays at a time, on a ping-ponged pair of players, and
the track only changes when the season actually changes (never mid-season,
never on background zone-color transitions) — a 4-second crossfade plays
between different tracks; moving between two seasons that share the same
track continues seamlessly with no restart. The menu track plays on its own
dedicated player, independent of season crossfading, starting on `MainMenu`
and stopping automatically when gameplay starts. `MusicManager` handles
looping automatically for `.ogg`/`.mp3`/`.wav`.

Music volume has been cut twice now on player feedback that it still
dominated other gameplay feedback (checkpoints, coins, eagle warnings) —
`SEASON_VOLUME_DB`/`MENU_VOLUME_DB` went -3dB → -11dB → -20.5dB → -30dB
(each cut roughly another 1/3 of the previous linear loudness). SFX
volumes in `AudioManager` are deliberately untouched by any of these cuts.

## SFX (`audio/sfx/`) — one-shot

| File | Used for |
|---|---|
| `jump.ogg` | Charge-jump release |
| `dash.ogg` | Air dash |
| `coin.ogg` | Collectible pickup |
| `checkpoint.ogg` | Checkpoint activation |
| `death.ogg` | Falling / dying |
| `landing.ogg` | Hard landing |
| `memory.ogg` | Memory reveal (100m/300m/700m/1500m) |
| `nearmiss.ogg` | Dying within 5m of a checkpoint |
| `area_discovery.ogg` | Crossing into a new zone |
| `click.ogg` | UI button press |
| `unlock.ogg` | Achievement unlock (dormant system, kept for completeness) |

## Bird & Eagle (`audio/`, not `audio/sfx/`) — real files in use

| File | Used for |
|---|---|
| `bird_chirp.mp3` | Collecting the rare white bird, discovering a bird nest, and collecting a common bird (all three share this file). **This file is real** — sourced from a real recording, not synthesized. Deliberately quieter than the "hype"-boosted SFX above (`BIRD_CHIRP_VOLUME_DB` in `AudioManager.gd`) and has a 0.35s cooldown per key so back-to-back bird pickups (e.g. a nest spawning two at once) can't overlap into a spammy flutter. |
| `eagle.mp3` | Eagle telegraph (plays the moment it appears) and eagle strike (plays again on hit) — not yet supplied; silently no-ops with a startup debug warning until it exists at this exact path. |

These two live directly under `audio/`, not `audio/sfx/` — that's deliberate,
matching the paths `AudioManager.gd`'s `SFX_PATHS` dictionary references.

## Format notes

- `.ogg` (Vorbis) is the recommended format — good compression, native Godot
  looping support. `.mp3` and `.wav` also work and are already handled by
  both managers.
- No import-time configuration is required — `MusicManager` sets the loop
  flag on load for whichever format is provided.
- File size isn't a major constraint for mobile/web here, but keep music
  tracks reasonably compressed (this is a small casual game, not a AAA
  soundtrack) — a lower bitrate OGG is fine and keeps the Web/APK builds lean.
