# THE WALL — Known Bugs, Gaps & Current Blockers

Nothing here has been verified by actually running the Godot editor from this
environment — there is no Godot binary available in the tool sandbox that built
most of this project. Everything below was found either by static audit
(reading every scene/script file and cross-checking references) or reported
directly by the developer running the real editor. Treat "fixed" items as
fixed-in-source but not editor-verified unless noted otherwise.

## Fixed

- **[FIXED, editor-verified] "Couldn't save scene. Likely dependencies
  (instances or inheritance) couldn't be satisfied."** — Not a source bug.
  Godot's `.godot/editor/editor_layout.cfg` had `current_scene` /
  `open_scenes` pointing at the old flat-layout `res://scenes/Main.tscn`,
  deleted during the v3–v5 folder reorg (along with its former children
  `scenes/Player.tscn`, `scenes/HUD.tscn`, `scenes/Platform.tscn`). The editor
  kept reopening that dead scene tab, whose cached in-memory tree pointed at
  files that no longer existed. Fixed by repointing `editor_layout.cfg` at
  `res://scenes/world/Main.tscn` and clearing the stale UID/filesystem/edit-state
  caches. Full writeup: `HANDOFF.md` → "Editor cache incident".
- **[FIXED] `Checkpoint.tscn` `load_steps` mismatch** — declared
  `load_steps=2` with 1 `ext_resource` + 1 `sub_resource` actually present
  (should be 3). Found during the same audit; corrected. Low severity on its
  own (Godot is generally tolerant of this specific count being off), fixed
  for correctness regardless.

## Current blockers

- **Android export preset is a placeholder, not a real build config.**
  `export_presets.cfg` has one `Android` preset, but:
  - `package/unique_name` is still Godot's generated placeholder
    (`com.example.$genname`)
  - `package/name` and `version/name` are empty
  - No keystore path is configured (debug or release)
  None of this blocks development or desktop testing — it blocks producing an
  actual installable APK/AAB. See `RELEASE_CHECKLIST.md` for what needs to be
  filled in, and `EXPORT_ANDROID.md` for the full walkthrough.
- **No Godot binary in the environment these docs/code were authored in.**
  Every `.tscn`/`.gd` change since the project started has been reviewed by
  hand against Godot 4 scene-format and GDScript semantics, not by opening the
  editor. Static audits have caught real issues before (see "Fixed" above),
  but they cannot catch everything a live editor session would (e.g. runtime
  exceptions, physics behavior that only shows up in motion, visual layout
  issues on an actual screen). **First thing a session with real Godot access
  should do: open the project and play a full loop** (menu → play → fall →
  respawn → checkpoint → death → menu → skins → stats → quit).

## Known gaps (not bugs — documented design/scope limitations)

- **Platform reachability isn't guaranteed.** Each platform's gap (vertical)
  and x-position (horizontal) are randomized independently. A gap that's
  technically within max-jump-height could combine with an awkward horizontal
  offset to make a specific run harder than intended. No solver currently
  checks the *combination* is always clearable. Not a crash risk — worst case
  is an unfairly hard jump on an unlucky seed. See `ROADMAP.md` → "Reachability
  guarantees."
- **Level is finite, not endless.** ~360 platforms generated all at once at
  scene load (~1000m ceiling). The vision describes "an enormous wall," which
  this satisfies at small-to-medium scale, but the generation approach
  (upfront, not streamed/chunked) won't scale to a truly endless climb without
  rework. See `ROADMAP.md` → "Endless generation."
- **No hazards/obstacles.** `GAME_VISION.md`'s MVP section lists "Obstacles"
  under Level; none exist yet (only platforms, checkpoints, and coins).
- **Achievement/toast system has no queue.** `HUD.show_toast()` always
  replaces whatever toast is currently showing and resets its timer. If a
  checkpoint and an achievement unlock happen in the same couple of seconds,
  one toast's message will be cut off by the other. Low-impact, not worth
  fixing unless it becomes noticeable in practice.
- **Stray untracked files in the working tree**: `TheWall.bundle` (a git
  bundle, `refs/heads/master` only) sits untracked at the project root. It
  isn't part of the game and isn't referenced by any project file — almost
  certainly a byproduct of a review/backup tool. Not touched by any doc-only
  pass; flagging so nobody mistakes it for a real project asset.
- **`node_2d.tscn` at the project root is an orphan.** Leftover from the very
  first project scaffold, before this build's work started. Confirmed
  unreferenced anywhere (`project.godot`, every scene, every script). Safe to
  delete; left in place because no one has explicitly asked for it to go.

## How to report a new bug here

Add it under a new `## Current blockers` or `## Known gaps` bullet with: what's
observed, where (file/scene), and whether it's been reproduced in a live
editor or only found by static read-through. Move it to `## Fixed` (with a
one-line summary of the fix) once resolved — don't delete the history, it's
useful context for why something looks the way it does.
