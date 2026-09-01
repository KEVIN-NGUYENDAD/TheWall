# THE WALL — Game Design V5: The Seven Zones

**Status: design document only. Nothing in this file has been implemented.**
No code, scene, or project-setting changes accompany this pass — see
"Implementation considerations" at the end for what a future coding pass would
need to touch, and `MASTER_HANDOFF.md` for the project's current actual state.

This document defines a seven-zone progression system that replaces the
current single, tonally-flat 0–1000m climb with a structured journey — each
zone has its own visual identity, hazard, mechanical twist, fragment of story,
and reason for its checkpoints to matter. It is meant to satisfy
`GAME_VISION.md`'s MVP "Level" pillar ("Platforms, Obstacles, Vertical
climbing") for the first time — the current build has platforms and vertical
climbing but no obstacles yet.

---

## Design philosophy

Every zone is built to serve five feelings, in this priority order:

1. **Risk** — every zone must have a moment where the "safe" choice and the
   "greedy" choice are visibly different, and the greedy choice is tempting.
2. **Progress loss** — falling must always cost something proportional to how
   deep into a zone you are. Early zones forgive; late zones do not.
3. **Near misses** — every hazard is *telegraphed* just long enough that a
   skilled player survives it by a hair, not by luck. A hazard that kills
   without warning is a bug, not difficulty.
4. **Discovery** — something in every zone rewards curiosity or a slight
   detour (a story fragment, a sightline, a secret coin cluster) that isn't
   required to progress but recontextualizes what came before.
5. **Skill mastery** — each zone teaches exactly one new skill, then the next
   zone's baseline difficulty assumes you have it. Zone 7 teaches nothing new
   and instead tests everything at once.

Zone spans escalate non-linearly (100 / 200 / 400 / 800 / 1500 / 4000 / ∞
meters) — early zones are short so the player reaches new content quickly and
builds trust in the system; late zones are long hauls where a single mistake
is genuinely expensive, which is the entire emotional point of "a single
mistake can cost significant progress" from `GAME_VISION.md`.

---

## Zone table (quick reference)

| # | Zone | Range | Span | One-line identity |
|---|------|-------|------|---|
| 1 | The Ruins | 0–100m | 100m | Safe tutorial — a dead civilization's failed climb |
| 2 | The Test | 100–300m | 200m | A deliberate proving ground; the game's real difficulty begins |
| 3 | The Wind | 300–700m | 400m | Exposed cliff face; wind becomes a tool and a threat |
| 4 | The Dead Climbers | 700–1500m | 800m | A graveyard; standing still is punished |
| 5 | The Scarlet Zone | 1500–3000m | 1500m | Something unnatural; gravity itself misbehaves |
| 6 | The Void | 3000–7000m | 4000m | The wall stops being a wall; rhythm and memory over sight |
| 7 | The Summit | 7000m+ | ∞ | Everything at once, forever — the "one more try" made literal |

---

## Zone 1 — The Ruins (0–100m)

**Visuals**: warm dawn palette (soft amber/tan sky, the current parallax
mountains re-tinted rather than replaced). Platforms are broken stone slabs
with visible cracks and moss, occasional carved symbols. This is the gentlest
palette in the game — establishing a baseline the later zones will visibly
depart from.

**Platform hazards**: none lethal. The one novelty is a **loose-stone
platform** — visually distinct (a hairline crack, a slight wobble on landing)
that is entirely cosmetic here. It exists purely to teach the player to *read*
a platform's appearance before Zone 2 makes that reading matter.

**Gameplay mechanics**: pure onboarding. A **diegetic charge-meter mural** —
a carved sundial-like marking on the first platform showing "hold / release"
as in-world signage rather than a UI tutorial popup, so the tutorial never
breaks the fiction.

**Story fragments** (found on carved tablets, optional detours just off the
main line): fragments of a creation myth — an ancient people who built at the
base of the Wall and tried to climb it "to see what watches from above."
Ends with a fragment naming "The Test" above, planting the first seed of
dread.

**Meaningful checkpoints**: the zone has exactly one — the **Gate of Ruins**
at 100m, a carved archway. Crossing it is framed (visually and in the next
zone's tone shift) as leaving safety behind. This is the only checkpoint in
the game that doubles as a point-of-no-return moment for a first-time player.

**Design intent**: near-zero risk, establishes trust, plants Discovery hooks
for the whole game.

---

## Zone 2 — The Test (100–300m)

**Visuals**: cold blue-grey stone, sharper and more geometric platform shapes
than the Ruins' rubble, faint glowing rune lines along platform edges.

**Platform hazards**: **crumbling platforms** — the game's first real hazard.
A platform visibly cracks on landing and collapses ~0.6s later (telegraph:
crack animation + a rising pitch tone). The player must land and immediately
re-jump, not linger. This is a soft introduction — most platforms in the zone
are still stable; crumbling ones are clearly marked before landing.

**Gameplay mechanics**: **trial gates** — narrow platform pairs spaced so
that only a charge within a specific band (not min, not max — a middle
range) lands cleanly; over- or under-charging clips the gate's edge. This is
the first place raw charge-power skill (not just "hold longer = better") is
tested.

**Story fragments**: rune-carved plaques stating The Test was built "to
weed the unworthy from the willing" — ambiguous about who built it or why,
deliberately raising more questions than it answers.

**Meaningful checkpoints**: checkpoints here are **trial markers** — they
only visually activate (flag rises, rune brightens) after the player clears
the specific crumbling-platform or trial-gate sequence directly before them.
Touching the checkpoint zone is still what the code checks (no change to the
underlying "every 100m" system — see Implementation Considerations), but the
checkpoint's fictional framing is "you earned this," not "you walked past
this."

**Design intent**: first real Risk and Progress loss; crumbling-platform
timing is the zone's core Near-miss generator; trial gates are the first
Skill-mastery test beyond raw jump timing.

---

## Zone 3 — The Wind (300–700m)

**Visuals**: pale open sky, fast-moving cloud streaks in the parallax layers
(reusing the existing `ParallaxLayer` system at higher `motion_scale` for the
near layer), thinner and more weathered platforms with visible wind-erosion
notches.

**Platform hazards**: **narrow ledges** (reduced platform width vs. the
standard 160px) combined with **wind gusts** — a periodic horizontal force
applied to the player mid-air, telegraphed one beat ahead by a visual gust
line sweeping in from off-screen.

**Gameplay mechanics**: gusts are dual-purpose by design — a **headwind**
gust shortens an in-progress jump (a threat that punishes committing to a
jump without checking wind direction first), while a **tailwind** gust
extends one (a tool that lets a skilled player clear gaps that look
unreachable, rewarding a beat of patience before jumping). This is the first
zone where reading the environment before acting is more valuable than raw
execution.

**Story fragments**: torn banners and journal pages snagged on rock outcrops,
describing a group of climbers who lost members to the wind — the tone shifts
from myth (Zone 1–2) to first-hand account for the first time.

**Meaningful checkpoints**: **wind-sheltered alcoves** — visually carved-in
nooks on the lee side of the rock face, the only calm spots in the zone. The
contrast between constant push everywhere else and stillness at a checkpoint
is the zone's emotional beat.

**Design intent**: escalates Risk and Progress loss (400m span, real cost to
a mistimed gust read); the "wait for the tailwind" play is the zone's
signature Discovery — most players will initially fight the wind before
realizing they can use it.

---

## Zone 4 — The Dead Climbers (700–1500m)

**Visuals**: desaturated, fog-layered palette (grey-blue near-monochrome).
Humanoid silhouettes — built from the same primitive-polygon language as
everything else in the game, not detailed sprites — are embedded in the rock
or slumped on distant ledges, visible only in the parallax background (never
on a platform the player can reach, to avoid implying interactivity that
isn't there).

**Platform hazards**: **ghost platforms** — visually flickering, translucent
platforms that look identical to real ones from a distance. They hold weight
for a beat and then vanish entirely (no crumble warning, just a shimmer that
increases in the last 0.3s before disappearing) — punishing hesitation more
than misjudged timing. Mixed among real platforms so the player must
distinguish them, not just react to all platforms as universally unsafe.

**Gameplay mechanics**: **the drain** — standing still (not charging, not
moving) on any platform in this zone for more than ~1.5s triggers a visible
cold effect and a charge-meter penalty on the next jump attempt. This
converts "camping on a safe platform to think" into an active cost for the
first time in the game, forcing constant forward momentum.

**Story fragments**: the zone's fragments are named, personal, and found
**on the ghost platforms themselves** — reading one means voluntarily
standing on a hazard for a few extra seconds. This is a deliberate pairing of
Discovery with Risk: the game never blocks progress on reading these, but it
always costs something to try.

**Meaningful checkpoints**: small **shrines** — cairns built by climbers who
"stopped here and turned back, but did not fall." Distinctly warmer-lit than
the surrounding fog, functioning as the only visual relief in the zone.

**Design intent**: the largest Progress-loss stakes yet (800m span); ghost
platforms are the sharpest Near-miss mechanic in the game so far (punishing
hesitation, not just misjudgment); the drain mechanic reframes "safety" as
something that must be actively maintained, not a passive fact of standing on
solid ground.

---

## Zone 5 — The Scarlet Zone (1500–3000m)

**Visuals**: the tonal turn from "hard climb" to "something is wrong here."
Deep red/orange rock with glowing magma-like veins running through platforms,
heat-shimmer distortion in the parallax layers, drifting ash particles.

**Platform hazards**: **erupting platforms** — a rumble-and-glow buildup
(roughly 1s telegraph) before a platform bursts, dealing no direct damage but
launching the player upward/outward unpredictably if they're still on it —
turning a hazard into an involuntary, risky bonus jump if timed well, or a
disorienting loss of control if timed badly. **Unstable gravity pockets** —
localized zones (sign-posted by a visible red haze bubble) where gravity is
measurably lighter or heavier than normal, requiring the player to
re-calibrate charge/timing on the fly.

**Gameplay mechanics**: this zone is the game's first deliberate **skill
synthesis** test — it recombines wind-reading (Zone 3) and crumble-timing
(Zone 2) rhythm inside gravity pockets, rather than introducing a fully new
skill in isolation. Eruption timing rewards players who've learned to read
telegraphs rather than react to hazards after the fact.

**Story fragments**: tone shifts again — fragments here are charred and
written in present tense, as if still being written by someone still present
in the zone. This is the first strong hint that the Wall's fiction is not
purely historical.

**Meaningful checkpoints**: rare, and visually the most dramatic in the game
— a **cooled patch of stone** amid otherwise-glowing rock, only appearing
after the player survives an eruption sequence right before it. Reaching one
is designed to feel like a genuine accomplishment, not a routine waypoint.

**Design intent**: this is the zone most likely to produce the "one more try"
loop from `GAME_VISION.md`'s stated success criteria — highest Risk and
Progress loss of the first five zones (1500m span), and the clearest
Skill-mastery payoff for players who've internalized every mechanic so far.

---

## Zone 6 — The Void (3000–7000m)

**Visuals**: the biggest visual departure in the game. Near-black background,
sparse cold starlight points, a single pale-violet accent color replacing the
warm/red palettes of every prior zone. Platforms are no longer ledges on a
wall — they're disconnected floating fragments (angular polygon shards),
implying the player has climbed past anything physical.

**Platform hazards**: **phase platforms** — solid on a strict, learnable
rhythm (e.g., visible for 1.2s, invisible/intangible for 0.8s), demanding the
player time a jump to a platform's visible window rather than its position
alone. **Gravity wells** — point-source pulls that drag the player's
trajectory off a straight line, requiring active correction mid-air.

**Gameplay mechanics**: **blind sections** — stretches with drastically
reduced platform visibility (only a brief silhouette flash reveals a
platform's position, then darkness), forcing memorization and read-and-react
skill over pure reflex. Because this is the largest zone (4000m) it is the
one place in the design where **sub-bands** are expected: early Void (3000–
4500m) introduces phase platforms and gravity wells separately; later Void
(4500–7000m) combines both with blind sections. This is called out explicitly
so implementation doesn't treat all 4000m as one difficulty plateau.

**Story fragments**: fragments stop being writable by any climber — messages
that reference events that haven't happened yet, or address the player
directly by their in-run actions. This is the zone's Discovery payoff: the
mystery seeded in Zone 1 (Ruins) about "what watches from above" starts
resolving into something closer to a loop than a place.

**Meaningful checkpoints**: **anchors** — the only fixed points in a zone
built from things that don't stay still, framed as literally holding a piece
of reality together. The most mechanically and fictionally meaningful
checkpoints in the game.

**Design intent**: extreme Risk and Progress loss by sheer span (4000m is
four times the previous largest zone); phase-platform rhythm and blind-section
memorization are the purest Skill-mastery tests yet; Discovery peaks here as
the story's central mystery comes into focus.

---

## Zone 7 — The Summit (7000m+)

**Visuals**: deliberate tonal payoff — bright, clean, almost-blinding white/
gold light breaking through after the Void's darkness. Sparse, serene
platform design in contrast to every hazard-dense zone before it.

**Platform hazards**: none *new*. The Summit's hazard is pacing itself —
gaps trend consistently toward the outer edge of max-jump range, so the
challenge is sustained precision, not a gimmick. This is a deliberate
subversion: the calmest-looking zone in the game is also the hardest
*raw execution* test.

**Gameplay mechanics**: no new mechanic. Instead, short callback sequences
recombine every previous zone's hazard in brief, clearly-telegraphed bursts —
a crumbling platform here, a wind gust there, a phase platform a little
further up — a "greatest hits" gauntlet that only makes sense to a player who
mastered each zone in order. Past 7000m the zone (and the wall) does not end;
platform/checkpoint generation continues indefinitely on the same rules,
matching the existing roadmap's "endless generation" item (see below) —
every new checkpoint here is, by definition, a new personal best.

**Story fragments**: the story concludes (or loops) here. The strongest
candidate ending beat: the climber silhouettes seen throughout Zone 4 (The
Dead Climbers) are revealed to be the same climber, on a previous attempt —
making every past run's death diegetic, and "one more try" a literal in-world
truth rather than just a design mantra. This also retroactively justifies why
falling doesn't end the game permanently: it's not a game-over, it's the
climber trying again, exactly as they always have.

**Meaningful checkpoints**: every checkpoint past 7000m is inherently
meaningful — there is no fixed top, so each one is a new record by
definition. No unique visual treatment needed beyond continuing the Summit's
bright palette; the meaning comes from the fiction, not new art.

**Design intent**: the purest expression of Skill mastery in the game (no
gimmicks, just "can you climb"), while Risk and Progress loss remain
maximal (a fall from deep in an endless zone is the most expensive fall
possible by definition).

---

## Cross-zone systems

### Checkpoint tiers
Two tiers, both riding on the existing "checkpoint every 100m" system (no
change to that cadence is proposed):
- **Zone Gate** — the first checkpoint inside each zone (or the zone-transition
  boundary itself). Gets unique visual treatment and, where noted above, a
  short earned-not-just-touched framing. One per zone (7 total, the seventh
  being the first checkpoint past 7000m and every subsequent one identically).
- **Waystation** — every other checkpoint. Inherits the current zone's visual
  theme (recolored pole/flag, matching the zone's palette) but needs no
  bespoke content. This is what keeps 7 zones' worth of "meaningful
  checkpoints" from requiring dozens of hand-authored moments.

### Story fragment system
A collectible, non-blocking lore system: fragments are found at fixed
positions per zone (some safe, some — Zone 4 — deliberately placed on
hazards). Reading one is optional and never required to progress. Proposed
data shape (design-level, not final): each fragment has a zone id, a short
text, and a position; collection state persists per-fragment-id, similar to
how achievements persist today. A "Journal" or "Fragments" entry could be
added to the Statistics screen to let players revisit what they've found —
this is a natural extension of the existing `StatsScreen.gd` pattern of
building rows at runtime from a data table, the same way achievements do
today.

### Difficulty curve validation
Every hazard above must remain *survivable by a hair* per the Risk/Near-miss
philosophy, which means each one needs to be checked against the player's
actual physics constants once implementation begins (current values, for
reference): `MIN_JUMP_SPEED=350` / `MAX_JUMP_SPEED=1100`, `RISE_GRAVITY=1400`
(→ max jump height ≈ 432px ≈ 8.6m, min ≈ 44px ≈ 0.9m), `MOVE_SPEED=220`,
`COYOTE_TIME=0.12s`. Any hazard timing window (crumble delay, phase rhythm,
gust duration) should be designed and tuned relative to these, not to an
arbitrary "feels right" number — a phase platform's visible window, for
example, must be long enough that a max-charge jump reliably lands inside it,
or the hazard becomes unfair rather than tense.

---

## Implementation considerations (non-binding — for a future coding pass)

Nothing below is being built in this pass. Flagged here so the next
implementation session (or `MASTER_HANDOFF.md`'s "recommended future Claude
prompts") has a running start.

- **This design requires endless/streamed generation before Zone 6–7 are
  buildable as designed.** The current `Main.gd` generates a fixed
  `PLATFORM_COUNT = 360` upfront (~1000m). Reaching 7000m at the same average
  platform spacing needs well over 2,000 platforms generated eagerly, which
  won't scale — this design is the concrete forcing function for the
  roadmap's existing "endless/streamed generation" item, not a new ask.
- **A "Zone" data model is needed.** Something like an ordered array of
  `{ name, min_height, max_height, palette, hazard_types, mechanic_flags }`
  that `Main.gd`'s generation loop (and a future hazard-spawning pass) can
  query by current height, replacing today's single flat set of generation
  constants (`MIN_GAP`/`MAX_GAP`/`COIN_CHANCE` are currently global, not
  zone-scoped).
- **Each hazard type is a new scene**, following the existing
  `Platform.tscn`/`Checkpoint.tscn`/`Coin.tscn` pattern (a root physics node +
  primitive-shape visual + a small script) — no architectural change needed
  there, just more scenes under `scenes/world/`.
- **New mechanics with physics implications** (wind gusts, gravity pockets/
  wells, the Void's phase timing) will need new logic in `Player.gd` or a new
  per-zone "environment modifier" component — these are the riskiest items to
  scope precisely and should probably be prototyped one at a time, zone by
  zone, rather than all at once.
- **Story fragments** need a small new save-schema addition (a
  `discovered_fragments` array or dict, alongside the existing `achievements`
  dict in `SaveManager`'s schema) — additive only, consistent with the
  existing "only ever add keys" save-compatibility rule in
  `MASTER_HANDOFF.md`.
- **Recommended build order**: implement one zone fully (visuals + hazard +
  mechanic + fragments + checkpoint theming) before starting the next, in
  zone order — each zone is designed to be a self-contained increment, and
  Zone 2's crumbling platform is by far the smallest, safest first
  implementation target.

## Open questions / design risks

- Do wind gusts and gravity pockets need new physics primitives, or can they
  be expressed as timed `velocity` modifications inside the existing
  `Player.gd` gravity/movement functions? (Leaning toward the latter, but
  unconfirmed until prototyped.)
- Is a 4000m single zone (The Void) actually one zone from a pacing
  perspective, or should it be split into two named zones during
  implementation once it's playable and its length can be felt rather than
  just measured? The sub-band note above is a hedge against this risk, not a
  final answer.
- The Summit's "climber-loop" story beat is the strongest ending candidate
  but is a narrative commitment — worth confirming with whoever owns the
  game's fiction before writing the actual fragment text, since it reframes
  every prior zone's silhouettes in hindsight.
- None of the new hazards have been validated against the existing
  reachability gap (`KNOWN_BUGS.md`: platform x/y are independently
  randomized with no solver). Hazard zones will need the reachability
  guarantee roadmap item *more* than the current hazard-free climb does — a
  gravity pocket combined with an unlucky random gap could be unfair in a way
  a plain jump currently isn't.
