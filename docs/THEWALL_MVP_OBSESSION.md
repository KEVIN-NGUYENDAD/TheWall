# THE WALL — MVP Obsession Plan (Game Director Pass)

**No new design ideas in this document.** Everything below is cut, merged, or
scoped from `THEWALL_FINAL_VISION.md` and `GAME_DESIGN_OBSESSION.md` against
one constraint that those two documents didn't have to respect: a solo
developer, and a month. This is the plan that actually ships. Where the
vision docs and reality disagree, reality wins here.

---

## 1–2. The 10 highest-impact features, ranked

Ranked on four axes — **Fun** (does it feel good moment to moment), **Addiction**
(does it drive "one more try"), **Effort** (solo-dev cost — lower is better),
**Mobile** (does it work on a thumb and a small bright screen). Ordered below
by build priority, which weighs Effort and Mobile most heavily — cheap,
high-impact, mobile-safe wins go first regardless of how "visionary" they are.

| # | Feature | Fun | Addiction | Effort | Mobile | Verdict |
|---|---|---|---|---|---|---|
| 1 | **Near-Miss Feedback** ("you were 3m from your best," shown unmissably on death) | Low | **High** | **Very Low** | High | Build first. Cheapest addiction lever in the whole plan. |
| 2 | **Forced Fall Sequence** (camera rides the fall, sound cuts, beat of stillness, *then* the death screen) | Med | **High** | **Low** | High | Cheapest fear-of-falling lever. Reuses the existing death trigger, just changes its timing/camera behavior. |
| 3 | **Instant Retry Loop** (death → one tap → climbing, no menu maze) | Med | **High** | Low | **Very High** | Removes the #1 silent killer of "one more try": friction. |
| 4 | **Remove Coins / Skins / Achievements / Stats** | — | Med (by subtraction) | Low | High | Deleting is cheaper than building, and every one of these currently competes for attention with the systems that actually work. |
| 5 | **Touch Control Redesign** (bigger, repositioned, higher-contrast) | Med | Med | Low–Med | **Very High** | Directly answers the "controls feel too small" complaint. Not exciting. Non-negotiable. |
| 6 | **Rare Anchors** (checkpoints, drastically less frequent, otherwise same touch-to-bank interaction) | **High** | **High** | Med | High | The single biggest gameplay-feel change for the least new code — it's a frequency and framing change to a system that already exists. |
| 7 | **Visual Legibility Pass** (fix iPad blur, raise contrast, fewer/bolder UI elements) | Med | Med | Med | **Very High** | Directly answers "blurry on iPad" and "scene too dark." A game people can't read clearly can't become an obsession. |
| 8 | **Death Markers** (permanent mark at every height you've died, drawn every run forever) | Med | **High** | Med | High | The signature idea of the whole redesign. Technically bounded — see "Memory System" below. |
| 9 | **The Shape Above** (one ambient, unexplained silhouette visible from run one) | Low | Med–High | **Very Low** | High | Almost free to build, and it's the entire "what's at the top" hook. No reason to cut it. |
| 10 | **Memory Fragments — simplified** (a rare pickup that prevents your *next* death outright, no dash/grab/slow-fall distinction yet) | Med–High | Med–High | **High** | High | The riskiest item on the list technically. Ship a blunt version now; the elegant "contextual save" version from `THEWALL_FINAL_VISION.md` is a Phase 3 refinement, not an MVP requirement. |

### What got cut from this list, and why

- **Full contextual Memory Fragments** (auto-dash vs. auto-grab vs. auto-slow-fall,
  chosen by the wall based on *how* you're about to die) — this is the best
  idea in `THEWALL_FINAL_VISION.md` and the wrong scope for a first build. It
  needs failure-prediction logic in the movement code that doesn't exist yet
  and can't be estimated reliably before the simplified version is even
  playtested. **Deferred, not deleted** — see Phase 3.
- **Seven zones with unique hazards, mechanics, and lore fragments**
  (`GAME_DESIGN_V5.md`) — this was already flagged as feature bloat by
  `GAME_DESIGN_OBSESSION.md` and stays cut. A solo developer cannot hand-build
  seven bespoke content sets before validating that the *core four systems*
  even produce "one more try" on their own.
- **Story-fragment text collectibles** — cut permanently, not deferred.
  Environmental storytelling in this game is visual only (marks on a wall),
  never text. Adding a text system back in later would undo the exact thing
  that makes Death Markers feel personal instead of like lore.
- **Endless / streamed generation** — real, valuable, and not required to
  prove the obsession loop. The current ~1000m ceiling is more than enough
  runway to test whether players want to keep climbing at all. Build it once
  the core loop is validated, not before.
- **Reachability guarantees for platform generation** — not glamorous enough
  to be a top-10 feature, but it is a hard requirement hiding inside "Fail
  State" below: every death has to be the player's fault, or "emotionally
  painful to fail" curdles into "unfair and I'm quitting." Treated as a
  Phase 1 quality bar, not a standalone feature.
- **Skins, coins-as-a-system, achievements-as-a-checklist** — see #4 above.
  These aren't just low-value, they actively dilute the four systems that
  matter by giving the player something meaningless to pay attention to
  instead.

---

## 3–4. What's actually required for "one more try"

Everything above the cut line, and nothing else. If you removed every item
below, the "one more try" feeling would break. If you added anything not
listed here, you'd be rebuilding the mistake this document exists to prevent.

**Required**: charge-jump (already built, do not touch), height/best-height
tracking (already built), Rare Anchors, Forced Fall Sequence, Near-Miss
Feedback, Instant Retry Loop, Death Markers, Memory Fragments (simplified),
The Shape Above, Touch Control Redesign, Visual Legibility Pass.

That's it. Eleven things, four of which already exist and just need
protecting, seven of which are new or redesigned.

---

## 5. System definitions

### Core Loop
Charge-jump up the wall → approach a rare anchor and decide, implicitly, by
your route, whether it's worth a small detour to bank it → keep climbing →
eventually mistime a jump → if a Memory Fragment is held, it's spent
automatically and you survive → if not, you fall → Forced Fall Sequence plays
→ a Death Marker is placed at that height, permanently → Instant Retry from
your last banked anchor. Repeat, always aware of your distance from your last
anchor (risk) and your distance from your best height (near-miss pull).

### Fail State
Falling below the bottom of the visible screen is the only failure
condition — unchanged from the current build. The one new requirement: every
fall must be attributable to a player mistake, never to an unreachable gap
the generator produced. This means platform-gap reachability (already a
known gap in `KNOWN_BUGS.md`) is promoted from "nice to have" to a Phase 1
quality bar — it's not a feature, it's the thing that makes every other
feature on this list mean something. A game can't make falling emotionally
painful if falling is sometimes just unfair.

### Progress Loss
On death: return to the last banked anchor. Everything climbed since that
anchor is lost. Any unspent Memory Fragment is lost too, folded conceptually
into the Death Marker just created (mechanically: simply consumed — the
"folds into the marker and can be reclaimed later" idea from
`THEWALL_FINAL_VISION.md` is real but is a Phase 3 refinement once Death
Markers and Fragments both already exist and are proven fun on their own).
**Best height is never lost.** It is the one permanent, positive record in
the game, and it's what Near-Miss Feedback measures every death against.

### Checkpoints (Rare Anchors)
Same player interaction as today (touch it, you're banked) — the entire
redesign is **frequency and framing**, not new input. Cut the current
"every 100m, guaranteed" cadence down hard (start around one anchor per
250–400m and tune from actual playtesting, not from a number in this
document). The scarcity alone creates the "was that worth skipping" tension;
no separate "bank now?" prompt is needed for an MVP, which keeps the
one-finger control scheme completely untouched.

### Discovery System
Two things only, both entirely visual, never text: **The Shape Above** —
one ambient silhouette visible from the player's first climb, static and
unexplained for the vast majority of the game, changing almost
imperceptibly only at extreme, rarely-reached height thresholds — and
**the player's own Death Marker pattern**, which becomes a recognizable
shape on the wall (dense right below their best height) purely by playing
normally. No dialogue, no lore tablets, no journal UI. If it can't be
discovered by looking at the wall, it doesn't belong in this system.

### Memory System
Two parts sharing one save-data concept — "every height this player has
ever died at":
- **Death Markers**: every recorded death height gets a permanent visual
  mark, drawn on a fixed background layer independent of the (regenerated)
  platform layout, in every future run, forever.
- **Memory Fragments (MVP version)**: a rare pickup placed near existing
  Death Markers. Carrying one means your next death is automatically
  cancelled — you're saved outright, the fragment is consumed, no visual
  distinction yet between *how* you were saved. The "the wall chooses
  dash/grab/slow-fall based on how you were about to die" version from
  `THEWALL_FINAL_VISION.md` is real and worth building, but only after this
  blunt version is shipped and confirmed fun — see Phase 3.

### Mobile Controls
One input still governs the entire game: hold to charge, release to jump.
Touch buttons (left/right/jump) get meaningfully larger, moved clear of
natural thumb-rest zones, and given enough contrast to be found without
looking away from the wall — the entire premise of one-finger climbing
breaks if the player has to glance down to find a button. Explicitly test
at tablet (iPad) aspect ratio, not just phone — the current blur/size
complaints were reported specifically on iPad and must be fixed there, not
just assumed fixed because it works on a phone-sized viewport.

### Visual Upgrade Plan
Two separate problems, both real, neither requiring new art assets (the
project stays primitive-shapes-only by design):
1. **Blur on iPad**: almost certainly a resolution/stretch-mode mismatch on
   high-density tablet displays rather than an art problem — this is an
   investigation-and-fix task, bounded in scope, done before any visual
   redesign work so the redesign isn't being judged through a blurry lens.
2. **Too dark / low contrast**: governed by the "interface as atmosphere"
   principle from `GAME_DESIGN_OBSESSION.md` — the *world* is allowed to stay
   moody and dark (that serves the tone), but anything the player must read
   at a glance (height, charge state, touch buttons, a Death Marker itself)
   needs deliberately higher contrast against it. Fewer UI elements, bigger,
   more confident, never competing dark-gray-on-dark-gray.

---

## 6. 30-day roadmap

### Phase 1 — Must Build (Days 1–10)
The floor. If only this phase ships, the game is already better than what
exists today, and "one more try" should already be detectable in playtests.
- Remove Coins / Skins / Achievements / Stats dashboard
- Rare Anchors (frequency + framing change to the existing checkpoint system)
- Forced Fall Sequence
- Near-Miss Feedback
- Instant Retry Loop
- Touch Control Redesign
- Visual Legibility Pass (blur investigation/fix + contrast pass)
- Reachability quality bar on platform generation (fairness, not a feature —
  do this before or alongside Rare Anchors, since rarer checkpoints make an
  unfair gap hurt more, not less)

### Phase 2 — Should Build (Days 11–20)
The signature idea. This is what makes the game *THE WALL* instead of just a
cleaner climber.
- Death Markers (persistent, permanent, drawn every run)
- The Shape Above
- Memory Fragments — simplified version (single auto-save, no contextual
  dash/grab/slow-fall distinction yet)
- A full internal playtest pass specifically hunting for: does a player who
  reaches their old death markers *feel* something? If not, this phase isn't
  done yet, no matter how much of it is technically built.

### Phase 3 — Nice to Have (Days 21–30+)
Only touch this phase once Phase 1 and 2 are playable, stable, and have
produced at least one real "I need to try that again" reaction from someone
who isn't the developer.
- Full contextual Memory Fragments (auto-dash / auto-grab / auto-slow-fall,
  chosen by how the player was about to die)
- Fragment reclaim-at-old-death-site (unspent fragments fold into the marker
  and can be recovered later by surviving that spot again)
- Visual mood drift by height (cheap palette/fog shift, no new mechanics)
- Platform reachability solver hardening (beyond the Phase 1 fairness bar)
- Endless / streamed generation past the current ~1000m ceiling

---

## 7. The three questions that matter

**What will make players stay for 30 minutes?**
The immediate, in-session loop: a felt Forced Fall Sequence, an unmissable
Near-Miss callout, and a retry that costs one tap. None of the longer-arc
systems (markers accumulating, the mystery above) have had time to matter
yet in a single sitting — the first 30 minutes has to be carried entirely by
how good the moment-to-moment "fall, feel it, try again" cadence is.

**What will make players come back tomorrow?**
The wall looks different than when they left it. Their own Death Markers are
still there, visible, unavoidable, specifically theirs. Their best height is
still a number they want to beat, now reframed by how close their last
attempt actually got. Nothing else in this plan produces next-day return on
its own — this is the whole reason Death Markers outrank everything except
the cheapest Phase 1 wins.

**What will make players tell a friend?**
"The wall remembers where I died" is a complete, shareable pitch in one
sentence — most mobile climbers can't say anything that specific about
themselves. Paired with a screenshot-able near-miss moment ("2 meters from my
best"), this is a game whose hook survives being repeated by someone who
never opens the design docs. That's the actual bar for "tell a friend," and
it's met by two of the cheapest features on this list, not by the most
technically ambitious one.
