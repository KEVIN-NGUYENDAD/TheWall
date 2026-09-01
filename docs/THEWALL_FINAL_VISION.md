# THE WALL — Final Vision

**Design only. No code. No implementation. No roadmap. No refactor.** This
document is the synthesis of everything before it — `GAME_DESIGN_V5.md`
(too much content, right instincts), `GAME_DESIGN_OBSESSION.md` (the correct
diagnosis: systems, not stakes), and the game as it exists today
(`ARCHITECTURE.md`, `MASTER_HANDOFF.md`). This is what all three should have
been arguing toward.

## Forget the platformer

Stop thinking about this as a climbing platformer with a jump button. It
isn't one. A platformer is a series of obstacles between you and an exit.
This game has no exit. It has a wall, and the wall has a memory, and the
memory is yours.

**The Wall remembers every failure.**

You are not climbing for score. Score is a number that resets its meaning
every time it goes up. You are climbing for **answers** — to what is above
you, and to why you keep dying in the same three places. Both questions are
real. Neither is answered quickly. That gap is the entire game.

---

## The ten questions

### 1. What is the single strongest reason to keep climbing?

**You have unfinished business with a version of yourself that already died
here.** Every death marker on the wall below your best height is a specific,
personal defeat, visible every time you pass it. The strongest motivator in
this design isn't curiosity about the top (though that matters too) — it's
the compounding, accumulating need to get past the spot that keeps beating
you. Climbing higher is secondary to climbing *through yourself*.

### 2. What should replace coins?

**Memory Fragments** — but only if they never behave like a currency. Coins
failed because they were free to collect, safe to hold, and spent on nothing
that mattered. Fragments must be the opposite on all three counts:

- **Costly to collect**: a fragment sits at or near a death marker, glowing
  faintly, reachable only by a small deliberate risk off the safe line —
  the reward is standing right next to the exact spot that killed you before.
- **Costly to hold**: fragments are lost on death, folded back into the new
  death marker they helped create — meaning they can be *reclaimed* later,
  but only by returning to that exact spot again, on a future run, when
  you're good enough to survive being there.
- **Spent on survival, not cosmetics**: a fragment is worth your life once.
  Nothing else. There is no shop. There is no second use for one.

A coin asks "do you want to look different." A fragment asks "do you want to
live." Those are not the same category of object, and the game should never
let them feel like they are.

### 3. What should players lose when they fall?

Three things, every time, no exceptions:

- **Distance** — everything climbed since your last anchor (see Q8),
  which under a rare-anchor system can be substantial.
- **Unspent fragments** — whatever you were carrying and didn't use, folded
  into the mark you just created. You don't just lose height. You lose the
  tools you were saving for later, and you watch them become part of the
  reason this spot will haunt you next time.
- **Nothing that can be bought back.** No revive currency, no "watch an ad to
  continue," no insurance system of any kind. The loss has to be real or none
  of the rest of this works.

### 4. What should players discover?

Two layers, and only two:

- **Their own shape.** A dense cluster of death markers just below their
  best height isn't a statistic — it's a silhouette of exactly where they
  keep failing, visible on the wall, recognized by looking, not by reading a
  screen. This is the primary discovery, and it happens on every single run.
- **The wall's shape.** Something distant and unresolved sits above the
  visible world from the first climb onward. It does not explain itself. At
  thresholds so rare most players will never personally reach them, it
  changes — almost imperceptibly. Nothing in the game ever states what it is.
  If it's ever explained in a tooltip, an achievement name, or a loading
  screen, it has already failed.

There is no third layer. No lore tablets, no named NPCs, no journal entries.
Environmental storytelling here means exactly one thing: **the world shows
you what happened. It never tells you.**

### 5. How should the wall react to player failures?

It accumulates you. Every death is a permanent mark, at the exact height it
happened, visible in every future run, forever. Marks near your current best
height cluster the densest, because that's where you fail most — which means
the hardest part of any run is visually the most scarred part of the wall,
without the game needing to say "this is hard" anywhere. At extreme
densities, the wall should feel different to be near — not through a stat
change, but through ambient pressure: the space around a heavy cluster of
your own deaths should feel like the most haunted place in the game, because
it is.

### 6. How do we make players obsessed?

Obsession needs four ingredients, and this design has to supply all four or
it will feel like "just another climber":

1. **A visible near-miss**, every time you die close to your best — not
   implied by two numbers, but shown, unmissable, immediate.
2. **A live risk decision**, not a passive rule — rare anchors mean every
   checkpoint is a choice ("bank now, or push further"), not an automatic
   trigger. Choice is what makes a loss feel earned instead of unlucky.
3. **A resource you can't stop thinking about spending** — a held Memory
   Fragment is a live question the entire time you're carrying it: use it now
   on a jump you're not sure about, or trust yourself and save it for worse.
   That question should be live in the player's head on every single jump
   once they have one banked.
4. **A question with no scheduled answer** — the shape above. Obsession
   requires the absence of a promised resolution. A mystery with a known
   ending date is a countdown. A mystery with no ending date is a hook.

### 7. What systems should be removed?

- **Coins**, entirely.
- **The skins shop** and all cosmetic purchases.
- **The achievement checklist** (8 discrete unlocks) — a checklist is a to-do
  list. This game should never feel like a to-do list.
- **The multi-stat statistics dashboard.**
- **Automatic checkpoints every 100m** — replaced by rare, chosen anchors.
- **Any zone-specific hazard/mechanic/lore-fragment content built as
  standalone features** (the `GAME_DESIGN_V5` approach) — if a mechanic can't
  be explained as a variation on Memory Fragments, Death Markers, Rare
  Anchors, or the wall's mystery, it doesn't belong in this game, no matter
  how good it sounds in isolation.

### 8. What systems should stay?

Exactly four, and nothing else:

1. **Charge-jump** — hold to charge, release to jump. Unchanged. This is the
   one input the entire game runs on, and it must stay the *only* input.
2. **Height / best height** — the one score that matters, reframed always as
   distance from your record, not a rising abstract number.
3. **Rare, chosen anchors** — checkpoints as a decision, not a trigger.
4. **Death Markers + Memory Fragments** — one system with two faces: what the
   wall keeps (marks, permanent, visible, yours) and what it sometimes gives
   back (fragments, rare, costly, spendable once).

### 9. What is the minimum feature set required for addiction?

The same four systems in Q8, and nothing added to them. Addiction here comes
from depth of *relationship* between four systems, not breadth of feature
count:

- Climb (charge-jump) generates height.
- Height generates risk (distance from your last anchor).
- Risk, badly resolved, generates a Death Marker.
- A Death Marker generates a Memory Fragment, recoverable later at cost.
- A Memory Fragment, spent well, prevents the next Death Marker.
- Repeat, forever, with the shape above always slightly closer and never
  explained.

Five sentences. That's the whole addiction loop. If a proposed feature can't
be inserted into that loop without adding a sixth sentence, it's bloat.

### 10. What makes THE WALL different from Doodle Jump, Only Up, and Getting Over It?

- **Doodle Jump** is weightless — nothing you do persists, nothing is ever at
  stake beyond the current jump, and failure means nothing because the whole
  loop resets in under a second with zero memory of what happened. THE WALL
  is the opposite of weightless: every failure is permanent, visible, and
  eventually valuable.
- **Only Up!** is a single long, brutal climb with real tension but no
  memory — every attempt starts from the same blank state as the last one,
  and the world never acknowledges how many times you've tried. THE WALL
  turns repeated failure into the actual content of the game: the wall
  looks different after your fiftieth death than it did after your first,
  and it looks different specifically *because it was you*.
- **Getting Over It** achieves emotional weight by having a narrator
  explicitly tell you what your suffering means, in real time, as it
  happens. THE WALL refuses to explain anything. There is no narrator. The
  meaning has to be assembled by the player from what they see accumulating
  on the wall, which makes it *their* meaning, not an authored one being
  handed to them.

No other climbing game turns your own failure history into the level design,
into your resource economy, and into your only reliable form of
environmental storytelling, simultaneously, using nothing but a mark and a
fragment. That is the entire differentiation, and it should stay a single
sentence: **other climbing games make you forget your deaths. This one is
built entirely out of them.**

---

## The four systems, briefly

**Death Markers** — a permanent visual mark at every height you have ever
died, drawn in every future run, never removed. This is memory made visible.
It is also, at a glance, the only difficulty curve the player needs: dense
marks mean "this is where people like you struggle," without a single line
of UI saying so.

**Rare Anchors** — checkpoints, but as a decision. Anchors are uncommon,
found rather than guaranteed, and the player chooses when to consume one to
lock in a respawn point versus pushing further first on the same one. Every
anchor sighted is a live negotiation between greed and safety, which is the
entire emotional engine of "progress loss" — a fall five meters after
choosing not to bank should feel like a decision the player made, not a rule
the game enforced.

**Memory Fragments** — the only "ability" system in the game, and it is not
an ability system in the traditional sense: there is no dash button, no
grab button, no slow-fall button, and no change to the one-finger control
scheme. A fragment is spent automatically, by the wall, at the exact moment
it would otherwise let you die — extending a jump that's just short (what a
traditional game would call a dash), catching you at an edge you clipped
(what a traditional game would call a wall grab), or softening a fall you've
already committed to so the loss is smaller and controlled instead of total
(what a traditional game would call a slow fall). The player never chooses
which of these happens. They only choose whether they're carrying a fragment
at all, by deciding — earlier, near a death marker — whether it was worth the
risk to go get one. This is the "radical" part: the abilities exist, but the
player never presses a button for them. The wall spends its memory of you to
save you, and the only skill is knowing whether you can afford, right now,
not to have one in reserve.

**The Shape Above** — visible from the first climb, unresolved for a very
long time, never explained in any UI text, ever. Its entire job is to be the
one thing in the game the player cannot solve by getting better at jumping —
only by climbing further than they, personally, ever have.

---

## The closing test

If a player, an hour after putting the game down, is thinking about a
specific spot on the wall where they keep dying — not the game in general,
that spot — the design is working. If they are wondering, even a little,
what that shape at the top actually is, the design is working. If neither of
those things is true, nothing else in this document matters, no matter how
well it's built.

**"I was so close." "One more try." "What's at the top."**

Everything above exists to produce those three sentences, unprompted, in the
player's own head. Nothing above exists for any other reason.
