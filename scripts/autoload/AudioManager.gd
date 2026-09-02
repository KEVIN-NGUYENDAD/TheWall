extends Node

# Plays one-shot SFX from real audio files (mostly under res://audio/sfx/,
# except bird_chirp.mp3 and eagle.mp3 which live directly under res://audio/).
# No procedural synthesis — if a file for a given name doesn't exist yet,
# play() silently does nothing. See audio/README.md for the expected manifest.

const VOICE_COUNT: int = 4
const PITCH_VARIANCE: float = 0.08

# Extra gain and a slightly wider pitch wobble for the moments that should
# feel the most fun/rewarding — makes them punch through and feel bouncy
# rather than flat, once real assets are dropped in.
const SFX_VOLUME_DB: Dictionary = {
	"jump": 4.0,
	"dash": 4.0,
	"checkpoint": 6.0,
	"memory": 5.0,
	"near_miss": 5.0,
	# Eagle is the "you got hit" collision sound — pushed up significantly
	# from 3.0 so a hit is unmistakable, distinct from the gentle chirp.
	"eagle": 9.0,
	"level_up": 6.0,
}
# Bird chirp (ambient reward-bird pickup) cut another 50% (~-6dB) on top of
# its existing -6dB — it should sit well behind the hype-boosted sounds
# above and the much louder eagle hit.
const BIRD_CHIRP_VOLUME_DB: float = -12.0
const HYPE_PITCH_VARIANCE: float = 0.14

# Bird chirp fires on every reward-bird pickup, which can happen in quick
# succession (e.g. a nest spawning two at once) — cooldown stops it from
# overlapping into a spammy flutter of the same sound.
const SFX_COOLDOWN_SEC: Dictionary = {
	"white_bird": 0.35,
	"chirp": 0.35,
}

const SFX_PATHS: Dictionary = {
	"jump": "res://audio/sfx/jump.ogg",
	"dash": "res://audio/sfx/dash.ogg",
	"coin": "res://audio/sfx/coin.ogg",
	"checkpoint": "res://audio/sfx/checkpoint.ogg",
	"death": "res://audio/sfx/death.ogg",
	"landing": "res://audio/sfx/landing.ogg",
	"memory": "res://audio/sfx/memory.ogg",
	"near_miss": "res://audio/sfx/nearmiss.ogg",
	"white_bird": "res://audio/bird_chirp.mp3",
	"chirp": "res://audio/bird_chirp.mp3",
	"area_discovery": "res://audio/sfx/area_discovery.ogg",
	"click": "res://audio/sfx/click.ogg",
	"unlock": "res://audio/sfx/unlock.ogg",
	"eagle": "res://audio/eagle.mp3",
	"level_up": "res://audio/sfx/level_up.ogg",
}

var _cache: Dictionary = {}
var _voices: Array = []
var _next_voice: int = 0
var _last_played_ms: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in range(VOICE_COUNT):
		var p := AudioStreamPlayer.new()
		add_child(p)
		_voices.append(p)

	for sfx_name in SFX_PATHS:
		var path: String = SFX_PATHS[sfx_name]
		if ResourceLoader.exists(path):
			_cache[sfx_name] = load(path)
		else:
			# Fails gracefully either way (play() just no-ops), but bird/eagle
			# calls are frequent enough during a run that a one-time debug
			# warning is worth having rather than silently wondering why
			# there's no sound.
			print_debug("AudioManager: missing audio asset for '%s' (%s) — will play silently until added." % [sfx_name, path])


func play(sfx_name: String) -> void:
	if not _cache.has(sfx_name):
		return

	var cooldown: float = SFX_COOLDOWN_SEC.get(sfx_name, 0.0)
	if cooldown > 0.0:
		var now_ms: int = Time.get_ticks_msec()
		var last_ms: int = _last_played_ms.get(sfx_name, -1000000)
		if now_ms - last_ms < int(cooldown * 1000.0):
			return
		_last_played_ms[sfx_name] = now_ms

	var voice: AudioStreamPlayer = _voices[_next_voice]
	_next_voice = (_next_voice + 1) % VOICE_COUNT
	voice.stream = _cache[sfx_name]
	if sfx_name == "white_bird" or sfx_name == "chirp":
		voice.volume_db = BIRD_CHIRP_VOLUME_DB
	else:
		voice.volume_db = SFX_VOLUME_DB.get(sfx_name, 0.0)
	var variance: float = HYPE_PITCH_VARIANCE if SFX_VOLUME_DB.has(sfx_name) else PITCH_VARIANCE
	voice.pitch_scale = 1.0 + randf_range(-variance, variance)
	voice.play()
