# Audio Asset Manifest

See `docs/AUDIO_ASSET_LIST.md` for the current priority delivery list. This
file is the full manifest, including a few lower-priority hooks (`coin`,
`landing`, `hit`, `area_discovery`, `click`, `unlock`) that already exist in
code but aren't part of that priority list yet.

This project no longer generates audio procedurally. `AudioManager` and
`MusicManager` load real audio files from the paths below; until a file
exists at a given path, that sound or track is silently skipped (no crash,
no placeholder tone — just silence for that one hook until it's filled in).

Drop files in with these exact names and Godot will pick them up automatically
— no code changes needed.

## Music (`audio/music/`) — real tracks in use

| File | Used for |
|---|---|
| `velariomusic-happy-vibes-591803.mp3` | Menu |
| `the_mountain-happy-happy-music-496549.mp3` | The Ruins (0–100m) |
| `jorisvermeer-happy-adventure-quest-572050.mp3` | The Sky (100–500m) |
| `the_mountain-fantasy-quest-184140.mp3` | The Void (500m+) |

These are the exact, unmodified filenames as sourced — do not rename them;
`MusicManager`'s path constants reference them directly.

The three zone tracks play simultaneously at all times during gameplay
(silently, via volume, unless active) so they can crossfade smoothly. The
menu track plays on its own dedicated player, independent of the zone
crossfade, starting on `MainMenu` and stopping automatically when gameplay
starts. `MusicManager` handles looping automatically for `.ogg`/`.mp3`/`.wav`.

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
| `bird.ogg` | Collecting the rare white bird, and discovering a bird nest (both events share this file) |
| `hit.ogg` | Predator bird knockback |
| `area_discovery.ogg` | Crossing into a new zone |
| `click.ogg` | UI button press |
| `unlock.ogg` | Achievement unlock (dormant system, kept for completeness) |

## Format notes

- `.ogg` (Vorbis) is the recommended format — good compression, native Godot
  looping support. `.mp3` and `.wav` also work and are already handled by
  both managers.
- No import-time configuration is required — `MusicManager` sets the loop
  flag on load for whichever format is provided.
- File size isn't a major constraint for mobile/web here, but keep music
  tracks reasonably compressed (this is a small casual game, not a AAA
  soundtrack) — a lower bitrate OGG is fine and keeps the Web/APK builds lean.
