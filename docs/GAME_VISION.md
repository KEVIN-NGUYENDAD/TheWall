# THE WALL

## Vision

A one-finger mobile climbing game.

Easy to learn.
Hard to master.

The player climbs an enormous wall and tries to reach the top.

A single mistake can cost significant progress.

---

## Core Gameplay

Hold to charge jump.

Release to jump.

Reach higher platforms.

Avoid falling.

---

## Design Principles

- Mobile first
- Portrait mode
- One finger control
- Fast restart
- Skill based
- No pay to win

---

## MVP

### Player

- Circle character
- Jump charge mechanic

### Camera

- Follow player smoothly

### UI

- Current height
- Best height

### Level

- Platforms
- Obstacles
- Vertical climbing

---

## Inspirations

- Getting Over It
- Geometry Dash
- Only Up

---

## Success Criteria

Players should say:

"One more try."

---

## Current Build Status (MVP v5)

The build now implements:

- **Gameplay**: procedural vertical climb (~360 platforms), checkpoints every 100m, persistent best-height tracking, JSON save/load (`user://savegame.json`), a death screen with respawn-at-checkpoint.
- **Progression**: coins, an achievement system (height/coin/death/checkpoint milestones), 5 unlockable skins purchased with coins, a statistics screen.
- **Polish**: shared UI theme, a segmented/color-shifting charge bar, an infinitely-tiling parallax background (3 layers, primitive shapes only), procedurally generated placeholder SFX (jump/coin/checkpoint/death/click/unlock — no audio files), a main menu and pause menu.
- **Android readiness**: on-screen touch controls (left/right/jump), portrait orientation lock, anchor-based responsive UI, mobile rendering method override. Actual APK export still needs a local Android SDK/export template setup — see `HANDOFF.md`.

All visuals remain primitive shapes (`Polygon2D`, `ColorRect`, `draw_circle`/`draw_arc`) — still no external art or audio assets. See `ROADMAP.md` for what's next and `HANDOFF.md` for the technical map of the project.
