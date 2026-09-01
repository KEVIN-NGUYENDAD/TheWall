# THE WALL — Alpha Test Checklist

Covers everything shipped through the Alpha Milestone pass (builds on the
Phase 1/Phase 2 work already in the project). Run through this after opening
in Godot 4.7.2, before considering the Alpha build stable.

## Core loop (regression — must still work exactly as before)

- [ ] Hold to charge, release to jump — feel unchanged
- [ ] A/D or arrow keys move left/right, grounded and airborne
- [ ] Double-tap left or right while airborne triggers Air Dash (0.6s cooldown)
- [ ] Height counter and best-height both update correctly while climbing
- [ ] Falling below the screen kills the player

## Memory System

- [ ] Climb past 100m — full-screen dark overlay fades in with "Someone climbed before you." then fades out; gameplay is paused during the reveal
- [ ] Climb past 300m, 700m, 1500m — each shows its own distinct message, once
- [ ] Return to Main Menu and start a **new** run, climb past a threshold already seen — confirm it does **not** replay
- [ ] Confirm the memory pause doesn't strand the player mid-air awkwardly (camera/physics resume cleanly after the overlay closes)

## Shape Above

- [ ] Visible near the top of the screen from the very first moment of a run
- [ ] Stays visible and in the same screen position regardless of how high you climb
- [ ] Pulses, slowly rotates, and is clearly more noticeable than a static background element
- [ ] Cannot be touched, collided with, or reached by any means

## Death Markers

- [ ] Die anywhere — a marker fades in at that spot showing the height (e.g. "342m")
- [ ] Marker has a visible glow and is readable from a distance as you climb past it later
- [ ] Die again elsewhere — a second, independent marker appears
- [ ] Quit to menu, start a new run — all previous markers are still present (persistence)

## Checkpoint Celebration

- [ ] Touching a checkpoint: flag flashes green, a glow burst expands and fades, a short camera shake plays, and the checkpoint sound plays
- [ ] Re-touching an already-active checkpoint does not re-trigger the celebration
- [ ] Camera shake is brief and doesn't impair visibility or control

## Platform Variety

- [ ] **Moving platforms** (blue-tinted): drift back and forth; standing on one carries the player along with it
- [ ] **Collapsing platforms** (brown/orange): flash orange on landing, then collapse and disappear roughly half a second later
- [ ] **Fake platforms** (visually identical to normal gray platforms): player falls straight through with no collision
- [ ] None of the three variants appear in the first few platforms right after spawn
- [ ] Normal platforms are still the majority — variety doesn't overwhelm the base game

## Near-Miss Reinforcement (regression + check still intact)

- [ ] Dying within 5m of any checkpoint: gold screen flash, "SO CLOSE!" title, distinct sound
- [ ] Dying elsewhere: normal red "You Fell!" title, no flash

## Effects

- [ ] Landing hard from a fall spawns a small dust-colored particle burst at the landing spot
- [ ] Dashing spawns a distinct cyan/white particle burst at the dash's start point
- [ ] Effects clean themselves up (no lingering nodes after they finish — check Remote scene tree during play if possible)

## Mobile / UI

- [ ] Touch buttons (Left/Right/Jump), Pause button, and all menu buttons are comfortably large and easy to hit
- [ ] Death Screen and Pause Overlay buttons are large enough for a thumb
- [ ] Toast messages (checkpoint text and memory text) fit and wrap correctly without clipping
- [ ] No UI element overlaps another at 540x960 and at a wider/taller aspect ratio (test via the editor's different resolution presets if possible)

## Save system (regression)

- [ ] `user://savegame.json` still contains `best_height`, `total_coins`, `unlocked_skins`, `selected_skin`, `achievements`, `stats`, `death_heights`, and `memories_seen`
- [ ] Existing coins/skins/achievements/stats screens still open and function exactly as before — nothing in this pass should have touched them
- [ ] Loading an older save file (missing `memories_seen`/`death_heights`) doesn't crash — confirm `_merge_defaults()` backfills it

## Full playthrough

- [ ] One uninterrupted run: Main Menu → Play → climb past at least one memory threshold → hit a checkpoint → encounter at least one of each platform variant → die once near a checkpoint (near miss) → die once far from one (normal) → confirm both death marker types persist → return to Main Menu
