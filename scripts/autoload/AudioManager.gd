extends Node

# Plays one-shot SFX from real audio files under res://audio/sfx/.
# No procedural synthesis — if a file for a given name doesn't exist yet,
# play() silently does nothing. See audio/README.md for the expected manifest.

const VOICE_COUNT: int = 4

const SFX_PATHS: Dictionary = {
	"jump": "res://audio/sfx/jump.ogg",
	"dash": "res://audio/sfx/dash.ogg",
	"coin": "res://audio/sfx/coin.ogg",
	"checkpoint": "res://audio/sfx/checkpoint.ogg",
	"death": "res://audio/sfx/death.ogg",
	"landing": "res://audio/sfx/landing.ogg",
	"memory": "res://audio/sfx/memory.ogg",
	"near_miss": "res://audio/sfx/nearmiss.ogg",
	"white_bird": "res://audio/sfx/bird.ogg",
	"chirp": "res://audio/sfx/bird.ogg",
	"hit": "res://audio/sfx/hit.ogg",
	"area_discovery": "res://audio/sfx/area_discovery.ogg",
	"click": "res://audio/sfx/click.ogg",
	"unlock": "res://audio/sfx/unlock.ogg",
}

var _cache: Dictionary = {}
var _voices: Array = []
var _next_voice: int = 0


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


func play(sfx_name: String) -> void:
	if not _cache.has(sfx_name):
		return
	var voice: AudioStreamPlayer = _voices[_next_voice]
	_next_voice = (_next_voice + 1) % VOICE_COUNT
	voice.stream = _cache[sfx_name]
	voice.play()
