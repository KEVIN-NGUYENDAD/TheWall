# THE WALL - PROJECT STATE

Version:
- Alpha v1.0 Released
- Beta v1.1 In Development

Current Branch:
- beta-progression

Protected Releases:
- v0.1-prealpha
- v1.0-alpha

Current Priority:
1. Save System — done (player name, checkpoint height, level, season, coins, play time, difficulty, inventory; auto-migrates old saves)
2. Continue System — done (Continue loads the saved checkpoint; fixed to agree with Save Position and in-run respawn)
3. Seasons — done (Spring/Summer/Winter/Autumn/Storm — reordered so snow shows up at 250m instead of 600m — height-banded, with banner on transition, verified all 5 bands)
4. Weather Gameplay — done (Winter ice / Storm wet friction reduction, Ice Grip/Weather Blessing buffs can override it)
5. Final Beta Polish — done (season-based music crossfade, Shop with 5 coin rewards, Easy/Medium/Hard difficulty, gold coins, bigger Common Bird, eagle warning sound, Trap Platform fixed, mobile controls shrunk 50%, Statistics contrast improved)
6. Final Beta Fix & Balance — done (Auto Resume with a real mid-run snapshot, ~50% overall difficulty reduction with Hard retuned to stay challenging, Season HUD + Season Guide, music volume cut to ~40%, missing-SFX debug warnings, mobile controls shrunk a further 20%, birds/butterflies halved for less clutter)
7. Final Beta Gameplay & Immersion Fix — done (fixed low-contrast player/bird colors that blended into the sky, darkened Eagle to look threatening, brightened coins/trap platforms, music cut to ~1/3 again with SFX untouched, bird_chirp.ogg hook, LEVEL UP + Rest Area at 100/300/600/900m, difficulty shifted down another full tier)
8. Final Beta Hotfix — done (fixed real bug: bird/eagle audio paths pointed at the wrong location/extension, so they could never load — bird_chirp.mp3 is now a real, working sound at the correct path; music cut another 1/3 to -30dB; SFX volumes confirmed untouched; further contrast pass on coin/player/eagle; Season HUD readability improved with a background chip; Easy difficulty cut another 50%)
9. Final Beta Polish (season reorder) — done (Seasons reordered to Spring/Summer/Winter/Autumn/Storm with new 100/250/450/700m bands; hazard curve reshaped so difficulty follows a "pretty weather isn't always easy" philosophy — Summer is harder than Winter's scenic-but-medium plateau, verified via sampling; Easy cut another 50%; birds/butterflies halved again; music cut another 1/3 to -40dB; further contrast pass on coin/player/bird/eagle/trap; Season Guide content updated to match)
10. Validate Beta Build — done (headless + rendered validation across all six passes; see CHANGELOG_ALPHA_v1.md and commit history for detail)
11. Balance Rework Pass — done (3-life system with a dedicated Game Over screen — Continue refills lives and resumes at checkpoint, Play Again refills lives and restarts from 0m; Seasons reordered again to Winter/Storm/Spring/Summer/Autumn at 0/100/250/450/700m so players see snow AND storm weather immediately; difficulty philosophy reset — beauty no longer implies easy or hard, hazard curve now climbs Winter<Storm<Spring<Summer<Autumn; Easy/Medium/Hard fully retuned against Medium as the balanced 1.0 baseline — this explicitly replaces the older "Medium=old Easy, Hard=old Medium" relationship from prior passes — Easy is -70% traps/eagles/hazards with wider platforms and shorter gaps, Hard is noticeably more traps/eagles with narrower platforms and farther gaps; New Game now shows an Easy/Medium/Hard picker before entering the game; HUD now shows lives (hearts) and current level alongside height/best/coins/season)
12. True 2.5D Visual Pass — done (gameplay untouched; sky color ownership moved from the old height-third Zone system to the Season system — each season now has its own sky color plus a full-screen tint wash, tweened on transition, tuned until each of the 5 seasons was unmistakable in a screenshot with the HUD ignored; Zone still tints mountains/hills/near-clouds for depth variety; added a 4th+5th parallax layer — far slow clouds and a height-driven fog layer whose opacity climbs with altitude and gets an extra flat boost during Winter; all 5 platform variants got a top highlight, bottom shadow, and an extruded "side" strip for fake block depth; Player got a foot shadow and an upper-left rim-light in addition to its existing outline; Coin got a two-layer glow, bigger/clearer sparkles, and a gentler spin; Winter snow now spawns in two depth layers — a far/small/slow/dim flake and a near/big/fast/bright one together — at 5x its old density; Storm rain density increased and lightning flashes brightened; fixed a real bug found in the process — flower decor was still spawning during Winter and snow-appropriate decor was nowhere, a leftover from the season reorders in passes 9 and 11 — flowers now spawn at Spring, a new SnowPatchDecor spawns at Winter)
13. Progression Overhaul — done (new Player Level system, fully independent from the Season/Zone systems above: +1 level every 100m climbed, uncapped, recomputed live from current height so it dips if the player falls and grows back on re-climb; each level adds a flat 3% to jump force via a new Player.level_jump_mult multiplier, jump_force = base*(1+(level-1)*0.03); a run-scoped peak tracker fires the celebration once per new high point, not on every re-cross of an already-reached level — verified: falling back and re-climbing to a previously-reached level does not re-trigger it, reaching a genuinely new peak does; leveling up shows a centered "⭐ LEVEL UP! ⭐ / Level X / Jump +3%" popup that fades over ~1s, plays a level_up SFX, spawns a gold glow + expanding ring around the player, gives a small camera shake, and grants 1s of the existing spawn-protection invulnerability; renamed the pre-existing Season-transition banner from "LEVEL UP!" to "NEW SEASON!" since it's a different, older mechanic (season/Rest-Area, still tied to the 100/250/450/700m season bands) that would otherwise collide with the new one in the player's head; HUD's Height+Lv line replaced with separate Height / Level / progress-bar-with-percent rows; Easy mode rebalanced further — vertical gap cut another 30% (0.6 -> 0.42), horizontal reach between consecutive platforms now constrained to half the baseline range (Medium/Hard's placement is untouched — same fully-free full-width randomization as before), platform count raised 50% so the tighter gaps don't run the column out early, and Fake-platform chance cut to ~20% of baseline so a beginner is never stuck behind a hazard they can't yet read; fixed the iPad/iPhone Safari virtual-keyboard bug on the name-entry screen — grab_focus() during _ready() isn't a real user gesture so iOS silently ignores it, so the first tap anywhere on the name screen now re-triggers grab_focus() from inside that gesture, which iOS does honor; bird ambient (chirp) cut another ~6dB (now -12dB total) and eagle hit ("collision") volume boosted 3.0dB -> 9.0dB for unmistakable hit feedback)

Next up:
- Playtest on real Web/iPhone/iPad/Android hardware (everything so far is automated/headless-validated only) — the iOS keyboard fix specifically can only be truly confirmed on real iPhone/iPad Safari, not from this dev environment
- level_up.ogg does not exist yet (same treatment as the other still-missing SFX — fails gracefully with a debug warning); eagle.mp3 is real and working
- web_release/ build artifacts keep changing on disk outside these passes' edits (not authored by any of them) — re-export before shipping if stale
- Falling back below a level after a season LEVEL UP, then climbing back past it, re-triggers the season celebration/Rest Area — acceptable but worth knowing about (the NEW per-100m Player Level popup does not have this problem — it only fires on a genuinely new peak)
- Music has been cut five times in a row across earlier passes (-3dB -> -11dB -> -20.5dB -> -30dB -> -40dB) and was not touched this pass; if still reported "too loud," a real listen is likely more useful than another blind cut
- The difficulty tiers (Easy/Medium/Hard) were fully redefined in the Balance Rework pass against a Medium=1.0 baseline, and Easy was tightened further this pass — worth a real-device playtest specifically on difficulty feel
- Game Over's "Play Again" resets the run to height 0m/checkpoint 0 but does not touch total_coins or best_height (those persist, matching how a death normally works) — worth confirming that reads as intended, not as a bug
- Player Level and Season are now two separate, deliberately independent progression concepts shown in different HUD spots (Level = height/100, uncapped, jump-force growth; Season = 5 fixed weather bands) — worth confirming in a real playtest that this reads as two distinct systems rather than a confusing duplicate

Git Tags:
- v0.1-prealpha
- v1.0-alpha

Local Backup:
- Desktop/TheWall_Alpha_v1.0.zip
- Backups/TheWall_Alpha_v1_Backup.zip (this session, excludes .git/.godot/.import/.netlify)
