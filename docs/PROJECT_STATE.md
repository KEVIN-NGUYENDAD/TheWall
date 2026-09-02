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
3. Seasons — done (Spring/Summer/Autumn/Winter/Storm, height-banded, with banner on transition, verified all 5 bands)
4. Weather Gameplay — done (Winter ice / Storm wet friction reduction, Ice Grip/Weather Blessing buffs can override it)
5. Final Beta Polish — done (season-based music crossfade, Shop with 5 coin rewards, Easy/Medium/Hard difficulty, gold coins, bigger Common Bird, eagle warning sound, Trap Platform fixed, mobile controls shrunk 50%, Statistics contrast improved)
6. Final Beta Fix & Balance — done (Auto Resume with a real mid-run snapshot, ~50% overall difficulty reduction with Hard retuned to stay challenging, Season HUD + Season Guide, music volume cut to ~40%, missing-SFX debug warnings, mobile controls shrunk a further 20%, birds/butterflies halved for less clutter)
7. Validate Beta Build — done (headless + rendered validation across all three passes; see CHANGELOG_ALPHA_v1.md and commit history for detail)

Next up:
- Playtest on real Web/iPhone/iPad/Android hardware (everything so far is automated/headless-validated only)
- Real SFX asset files still missing (music is real; jump/dash/checkpoint/etc. hooks are wired but silent — now log a debug warning instead of failing silently)
- web_release/ build artifacts changed on disk outside this pass's edits (not authored by this pass) — re-export before shipping if they're stale

Git Tags:
- v0.1-prealpha
- v1.0-alpha

Local Backup:
- Desktop/TheWall_Alpha_v1.0.zip
- Backups/TheWall_Alpha_v1_Backup.zip (this session, excludes .git/.godot/.import/.netlify)
