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

Next up:
- Playtest on real Web/iPhone/iPad/Android hardware (everything so far is automated/headless-validated only)
- eagle.mp3 still missing (bird_chirp.mp3 is real and confirmed working); jump/dash/checkpoint/etc. SFX hooks are still wired but silent — log a debug warning instead of failing silently
- web_release/ build artifacts keep changing on disk outside these passes' edits (not authored by any of them) — re-export before shipping if stale
- Falling back below a level after a LEVEL UP, then climbing back past it, re-triggers the celebration/Rest Area — acceptable but worth knowing about
- Music has been cut five times in a row across earlier passes (-3dB -> -11dB -> -20.5dB -> -30dB -> -40dB) and was not touched this pass; if still reported "too loud," a real listen is likely more useful than another blind cut
- The difficulty tiers (Easy/Medium/Hard) were fully redefined this pass against a new Medium=1.0 baseline — worth a real-device playtest specifically on difficulty feel now that the relationship to older tiers no longer holds
- Game Over's "Play Again" resets the run to height 0m/checkpoint 0 but does not touch total_coins or best_height (those persist, matching how a death normally works) — worth confirming that reads as intended, not as a bug

Git Tags:
- v0.1-prealpha
- v1.0-alpha

Local Backup:
- Desktop/TheWall_Alpha_v1.0.zip
- Backups/TheWall_Alpha_v1_Backup.zip (this session, excludes .git/.godot/.import/.netlify)
