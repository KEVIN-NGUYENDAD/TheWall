# THE WALL — Obsession: A First-Principles Redesign

**Design only. Nothing here is implemented. No code, scene, or save-data
change accompanies this document.** This is a challenge to the current design
— including `GAME_DESIGN_V5.md`, which this document partially supersedes
(see "What happens to V5" at the end). If you only read one section, read
"The one idea" and the ten answers.

---

## The honest diagnosis

The current build (`MASTER_HANDOFF.md`, `ARCHITECTURE.md`) is mechanically
competent and emotionally flat. Here's why each stated problem is happening,
in plain terms:

- **Repetitive gameplay**: the verb never changes. Charge, release, land.
  Every platform is the same decision at a different height. `GAME_DESIGN_V5`
  tried to fix this by adding a new hazard per zone — that's *more content*,
  not *more meaning*. Seven hazards you react to is still reacting.
- **Coins feel meaningless**: because they are. They bank instantly (zero
  risk to collect), spend on cosmetics (zero gameplay effect), and have no
  relationship to height, danger, or story. A currency with no stakes is a
  chore, not a system.
- **Falling isn't scary**: death is a menu, not a moment. The instant the
  player crosses `kill_y`, the game pauses and shows a panel with numbers on
  it. There is no time between "I made a mistake" and "here is a screen" for
  dread to exist. Fear needs a gap it can live in.
- **No reason to keep climbing**: height is the only goal, and height is an
  abstraction. Nothing in the world responds to the player's specific
  history. Nothing is unexplained. A number going up is not, by itself,
  compelling past the first few minutes.
- **No emotional attachment or mystery**: because nothing in the game
  remembers the player, and nothing in the game withholds information on
  purpose. nothing you did last run is visible this run except a number in the
  corner.
- **UI too dark, controls too small, visuals blurry on mobile**: these are
  production issues, not covered in depth here (this is a systems-design
  document), but they matter for the same underlying reason as everything
  else — a game about dread and mystery needs an interface that gets out of
  the way, not one that looks like a half-finished dashboard. See "Interface
  as atmosphere" near the end for the design-level principle; the pixel-level
  fix is implementation work for later.

The deeper problem: **the game has systems, not stakes.** Coins, skins,
achievements, and a statistics screen are all *systems* — they require the
player to learn rules and track numbers. None of them are *stakes* — none of
them make the player feel something is genuinely at risk, or genuinely
unknown. Fix that, and repetitive moment-to-moment jumping stops mattering,
because the player isn't playing for the jump. They're playing for what the
jump might cost, or might reveal.

---

## The one idea

**The wall remembers you, and something is waiting above you that doesn't.**

Two sentences, two systems, and almost everything asked for falls out of
them:

1. Every time you fall, it leaves a permanent mark on the wall, at the exact
   height you died, visible in every future run. You don't climb a
   procedurally generated wall. You climb a record of your own failures —
   thickest just below your best height, because that's where you've died
   the most, right before the moment you almost didn't.
2. Something is visible, distant, and unresolved at the top of the screen
   from the very first climb. It does not explain itself. It gets larger
   only after enormous, rare thresholds. Nobody — not even this document —
   commits to what it is.

Everything else in this redesign either serves these two facts or gets cut.

---

## The ten questions

### 1. Why should players care about climbing?

Not because height is a number that goes up. Because two things pull from
above and one thing pushes from below:

- **Pull**: the unresolved shape at the top. Curiosity is a stronger and
  cheaper motivator than any reward system — it's also the one thing a
  currency or skin can never substitute for.
- **Pull**: beating your own record, made visceral by seeing exactly how many
  times you've died trying, right below where you're about to climb.
- **Push**: the wall you're standing on already has your own marks on it.
  Climbing past them, especially past a dense cluster near your best, is an
  act of confronting your own history, not just executing a jump.

### 2. Why should players fear falling?

Because it costs something real and something permanent, not just time:

- **Real**: checkpoints are rare (see Q8) — most falls send you back a
  meaningful distance, not a token one.
- **Permanent**: it adds one more mark to your own wall, forever. Fear here
  isn't "I'll lose two minutes." It's "I'll leave one more scar exactly where
  I keep failing, and I'll see it every single climb from now on."
- **Felt, not just stated**: the fall itself is a forced, unskippable moment
  — the player watches themselves fall past their own progress and past their
  own past deaths before the death screen ever appears (see Q9). Currently
  the game cuts straight to a UI panel; the panel is the least scary part of
  dying and it's the only part the player currently experiences.

### 3. What creates addiction and "one more try" behavior?

Four things, in order of power:

1. **Visible near-misses.** If the player can *see* they died three meters
   from their record, "one more try" is no longer a vague feeling — it's a
   specific, small, achievable-feeling gap. This must be surfaced explicitly,
   not left for the player to infer from two numbers.
2. **A live risk decision, not a fixed rule.** The current checkpoint system
   (auto-save every 100m) has no decision in it — you either touched the line
   or you didn't. Replace it with something the player *chooses*: bank
   safety now, or push higher first and gamble the distance since your last
   anchor (see Q8). Every checkpoint becomes a live "do I stop or do I push"
   moment, which is the actual engine of addictive risk games, not the
   fall itself.
3. **Zero-friction retry.** The gap between "I died" and "I'm climbing again"
   must be as close to one tap as possible. The emotional beat of falling
   (Q9) should be heavy; the mechanical cost of trying again should be
   nearly free. These are not in tension — Getting Over It and Jump King both
   make failure hurt *and* make retrying instant.
4. **A mystery with no ending in sight.** Loot boxes and gacha games exploit
   variable rewards; this game doesn't need to and shouldn't. It can use the
   much older, much less predatory version of the same instinct: not knowing
   what's at the top is enough, as long as the game never cheapens it with an
   explanation too early.

### 4. What should be removed from the current design?

- **Coins**, entirely. They have no relationship to risk, height, or story,
  and a currency with no stakes actively undercuts the tone this game needs.
- **The skins shop.** Cosmetic purchases are a generic mobile-game pattern
  this brief explicitly asks to avoid, and they compete for attention with
  the one thing that should matter (the climb itself, and your marks on it).
- **The 8-item achievement checklist.** Achievements-as-checklist is a
  generic RPG/mobile pattern. What replaces it (Q10) is not a checklist — it
  is the wall itself.
- **The statistics screen**, as currently designed (a dashboard of eight
  numbers). Numbers-as-dashboard fights the mystery tone directly.
- **`GAME_DESIGN_V5`'s per-zone hazard/mechanic/story-fragment content plan**
  — seven hand-authored hazards, seven mechanics, scattered lore tablets. This
  is feature bloat relative to what this game actually needs. See "What
  happens to V5" below for what's worth keeping from it.
- **Checkpoints every 100m.** Frequent, automatic, and free of any decision —
  see Q8.

### 5. What should be simplified?

- **The HUD**: height and "distance from your best" are the only numbers that
  need to be visible during a climb. Coin counters, achievement toasts, and a
  charge-bar-with-three-color-thresholds are all clutter relative to that.
- **Story delivery**: no journals, no named strangers, no lore tablets. If
  the game ever says anything at all, it says almost nothing, rarely, and
  never explains itself. One ambiguous line beats one paragraph of
  worldbuilding, every time, for this genre.
- **The zone concept from V5**: keep the *feeling* (the world should look and
  sound different at 3000m than at 50m) but deliver it as a cheap, continuous
  visual/audio drift — palette, fog density, ambient tone — rather than seven
  discrete zones each requiring bespoke hazards and mechanics.
- **Death → retry loop**: currently pause → panel → button → respawn. Should
  be: fall (forced, felt) → brief stillness → one tap → climbing again. Fewer
  screens, more feeling.

### 6. What should be added?

Exactly four things. Each is one system, and each earns its place by serving
at least two of the ten questions:

1. **Death markers** ("the wall remembers you") — a permanent, visible mark
   at every height the player has ever died, persisted forever, drawn every
   run.
2. **A distant, unresolved shape** at the top of the visible world from the
   very first climb — the mystery engine. It does not need a defined nature
   yet; it needs to exist, be visible, and never explain itself early.
3. **Bankable anchors** replacing automatic checkpoints — rare, found objects
   that let the player choose *when* to lock in a respawn point, turning
   every checkpoint into a live risk decision instead of a passive trigger.
4. **A forced fall sequence** — when the player dies, the camera does not cut
   to a menu. It follows the fall, past the player's own progress and past
   their own death markers, for a beat, in near-silence, before anything else
   happens.

That's the entire addition list. No new currency, no new screen that isn't
strictly necessary, no skill tree.

### 7. How can mystery drive progression?

By being the *only* thing in the game that isn't fully explained by systems
the player already understands. Height, jumping, falling, banking an anchor —
all of that should be immediately legible. The shape at the top should be the
one exception: visible from minute one, unreachable for a very long time, and
never described in any UI text, tooltip, or story beat. Mystery drives
progression by being the single loose thread the player cannot resolve by
getting better at the moment-to-moment game — only by climbing further than
they ever have. That is what makes it progression-shaped instead of just
atmosphere.

### 8. How can every meter matter?

Make checkpoints rare and *chosen*, not frequent and automatic. Under the
bankable-anchor model (Q6.3): every meter climbed since your last banked
anchor is provisionally at risk, and the player knows it, and the player
decides whether to keep pushing or cash in. A meter climbed right after
banking is nearly free. A meter climbed with no anchor banked in a long time
is genuinely frightening. This is the entire difference between a system
where progress is a fact (current design: touch the line, you're safe) and a
system where progress is a feeling (redesign: how much am I currently willing
to lose?).

### 9. How can every fall hurt emotionally?

Three layers, stacked:

1. **Loss**: falling from deep past your last banked anchor costs real,
   visible distance — not a token setback.
2. **Witness**: the forced fall sequence (Q6.4) makes the player watch the
   loss happen in real time, past their own history (their death markers),
   instead of cutting straight to a results screen. Loss that is *seen* hurts
   more than loss that is only *reported*.
3. **Permanence**: the fall leaves one more mark on the wall, forever. The
   player isn't just losing progress this run — they're adding to a visible,
   accumulating record of every time they've failed at roughly this height.
   That record doesn't reset. It's the closest thing this design has to a
   permanent consequence in a game that otherwise (correctly, per the
   original vision) never truly ends the session.

### 10. How can players feel they are discovering something important?

Not through collectible lore (that's inventory, not discovery). Through two
things that are *shown*, never explained:

- **Their own pattern**, visualized. A dense cluster of death markers near
  their best height is not a stat — it's a shape the player recognizes as
  "this is where I keep dying," discovered by looking at the wall, not by
  reading a screen.
- **The shape at the top**, changing — extremely rarely, at thresholds far
  beyond anything achievable early — resolving very slightly more with each
  enormous milestone. Because this happens so rarely and is never
  accompanied by explanatory text, any change the player notices will feel
  like something they personally uncovered, not something the game handed
  them.

---

## The redesigned core loop

```
Climb (charge, release, land — unchanged)
   → find a rare anchor → decide: bank now, or push further first?
   → fall
       → forced fall sequence: watch the drop, past your own death markers, near-silence
       → one new permanent mark added to the wall at this height
       → brief stillness
       → one tap: climbing again, from your last banked anchor
   → repeat, always aware of:
       - how far above your last anchor you are (risk)
       - how close your best height is (near-miss pull)
       - the shape at the top (mystery pull)
```

No shop screen. No achievement toast. No coin counter. The loop above is the
entire game, and every element in it serves risk, loss, near-miss, discovery,
or mystery directly — nothing is there to be a "feature."

## Systems inventory — before and after

| Kept (unchanged) | Kept (redesigned) | Removed |
|---|---|---|
| Charge-jump core mechanic | Checkpoints → rare, player-chosen anchors | Coins |
| Height / best-height tracking | Death screen → forced fall sequence + minimal panel | Skins shop |
| Save/load (schema shrinks) | Statistics → best height + total falls, nothing else | 8-item achievement checklist |
| | Zone visual progression → continuous drift, not 7 discrete builds | Story-fragment collectibles |
| | | Multi-stat dashboard |

Net system count for a player to learn: **climb, bank, fall, remember.**
Four verbs. That's the whole game.

## Interface as atmosphere (principle, not implementation)

The stated production problems — UI too dark, touch targets too small, blur
on high-density mobile/iPad screens — aren't separable from this redesign,
even though fixing them is implementation work for later. The governing
principle for whenever that work happens: **the interface should feel like
part of the wall, not a dashboard bolted onto it.** Concretely, that means
favoring fewer, larger, more confident UI elements (serves touch-target size
for free), a palette that supports dread and mystery rather than fighting it
(favor near-black and single accent colors over flat dark-gray "app" tones),
and never asking the player to look away from the climb to understand their
situation — the whole premise of one-finger climbing is that the player's eyes
stay on the wall. Numbers belong at the edges, small, quiet, and few.

## What happens to `GAME_DESIGN_V5.md`

Not thrown out — narrowed. Keep:
- The idea that the world should feel different at 3000m than at 50m
  (palette/fog/tone drift — cheap, worth doing).
- The core insight behind "The Dead Climbers" — evidence of past failure
  embedded in the world. This document keeps that idea and sharpens it: it's
  not a zone full of *other* climbers' remains, it's the *player's own*
  death markers, everywhere, always. One system instead of a zone-specific
  content plan, and a stronger emotional hook because it's personal, not
  lore.
- The instinct that something ancient/unknowable is above the player (the
  Void/Summit mystery beats) — kept, but delivered as one ambiguous shape
  from minute one rather than revealed gradually across five zones of
  hand-authored hazards.

Cut or defer indefinitely:
- Seven distinct hazard types, one per zone.
- Seven distinct new mechanics (wind gusts, gravity pockets, phase timing,
  the drain, trial gates, eruption launches).
- The story-fragment collectible system and all lore text.
- The zone-gate/waystation checkpoint-tier system — superseded by rare,
  player-chosen anchors, which is a stronger and simpler answer to the same
  problem ("make checkpoints feel earned").

If zone-specific hazards ever come back, they should be evaluated one at a
time, each against this document's five pillars, after the four core systems
above are built and proven — not before.

## Open risks

- **Bankable anchors need real tuning** to avoid feeling punishing rather
  than tense — how rare is rare, and does the player always know one is
  coming soon enough to plan around it? This needs prototyping, not just
  design, before it ships.
- **Death markers accumulate forever** — at very high total death counts
  (hundreds of falls), does the wall become visually cluttered instead of
  meaningful? Likely needs a cap, a fade, or a "only your most recent N near a
  given height" rule — a real design question, not answered here.
- **The unresolved shape at the top must never be explained too early**,
  including by accident (a debug label, a stray tooltip, an over-eager
  achievement). This is a discipline problem for implementation as much as a
  design one.
- **Removing coins/skins/achievements has save-schema implications** for
  existing save files — not a blocker for design, but flag it now so a future
  implementation pass plans a migration instead of discovering the problem
  midway through.

## The test for everything above

Before adding anything to this design in the future, ask: does it make the
player think *"I was so close"* or *"what's at the top?"* on its own, without
a UI element explaining why it should? If the answer requires a tooltip, a
toast, or a shop screen to land, it isn't ready — or it isn't right for this
game.
