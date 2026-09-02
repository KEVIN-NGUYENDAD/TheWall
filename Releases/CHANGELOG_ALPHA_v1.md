# TheWall — Alpha v1.0 Changelog

Stable Alpha milestone, tagged `v1.0-alpha`. This is the baseline the Beta
Progression update branches from.

## Dash
Double-tap left/right while airborne to air-dash (0.18s burst, 0.6s
cooldown), with a stretch-squash visual and a dedicated SFX hook.

## Music
Adaptive, real-asset-only soundtrack — no procedural/synth audio anywhere.
Three zone tracks (Ruins/Sky/Void) crossfade continuously by height and
progress; a separate menu track plays on the main menu and stops cleanly
when a run starts.

## Birds
Common Birds (ambient, decorative flight), the rare glowing White Bird
(grants bonus height on pickup), Shadow Birds (Void-zone atmosphere), and
the Predator Bird (telegraphed dive-bomb hazard with a clear pre-attack
warning). All wing geometry uses self-intersection-safe triangle fans.

## Safe Zone
The first 20m are hazard-free and death-free: no spikes, no hazard
platforms, no death markers, and falling off-screen soft-resets the player
to spawn instead of ending the run. A short spawn-protection window also
applies after every respawn/checkpoint.

## Mobile Controls
Touch-only Left/Right/Jump buttons sized and balanced for one-handed
portrait play, tuned across two rounds of feedback (Jump reduced ~66%,
Left/Right enlarged to match).

## Web Export
Verified, real Web export (`web_release/`) built and smoke-tested from
Godot 4.7.2 headless export tooling — playable in a browser with no
external assets or plugins required. Android debug APK also produced and
verified (`android_release/`).

## Death Markers
Every death location is permanently marked on the wall (red X with a glow),
persisted across sessions, merged with a "×N" count when deaths cluster
close together, and suppressed inside the Safe Zone.

## Memories
One-time atmospheric full-screen text reveals at 100m / 300m / 700m /
1500m — each shown exactly once per save file, tracked independently of
best-height progress.

## Checkpoints
Every 100m, with a glow/flag/camera-shake celebration and a multi-color
confetti burst on activation. Falling after a checkpoint respawns there
instead of at the very start; dying within 5m of a checkpoint is framed as
a distinct "near miss" (unique sound and death-screen copy).

## Area Progression
Three visually and tonally distinct zones — The Ruins (0–100m), The Sky
(100–500m), and The Void (500m+) — with crossfading sky/mountain/hill/cloud
colors, zone-synced adaptive music, and a discovery sound on first entry
into each.

## UI / Visual polish carried into this Alpha
Brighter blue/green/purple palette (reverted from an earlier orange
direction per feedback), crystal/gem-style coins with glow and sparkle,
sun rays, ambient sparkle field, more energetic cloud drift, and a
compact, off-center charge meter (replacing an earlier full-width bar that
blocked the play area).

## Known limitations
- Platform reachability is not solver-verified; an unlucky random gap can
  occasionally produce a harder-than-intended jump.
- No real audio asset files exist yet for sound effects (music tracks are
  real; SFX hooks are wired but silent until files are supplied).
- No live human playtest on physical mobile hardware — verified via
  headless/rendered automated testing only.
