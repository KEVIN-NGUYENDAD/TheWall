extends Node

# Adaptive zone music: 3 looping tracks (one per zone) always playing in
# parallel, crossfaded by volume based on the current zone and how far the
# player has progressed through it. Loads real audio files from
# res://audio/music/ — no procedural synthesis. If a zone's track file
# doesn't exist yet, that zone simply stays silent until one is added.
# See audio/README.md for the expected manifest.

const FADE_RATE_DB: float = 24.0
const SILENT_DB: float = -80.0

const ZONE_BASE_DB: Array = [-5.0, -3.0, -6.0]
const ZONE_PEAK_DB: Array = [0.0, 2.0, -0.5]

const ZONE_TRACK_PATHS: Array = [
	"res://audio/music/ruins_theme.ogg",
	"res://audio/music/sky_theme.ogg",
	"res://audio/music/void_theme.ogg",
]

var players: Array = []
var current_zone: int = 0
var intensity: float = 0.0
var active: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in range(3):
		var p := AudioStreamPlayer.new()
		p.volume_db = SILENT_DB
		add_child(p)
		players.append(p)

		var path: String = ZONE_TRACK_PATHS[i]
		if ResourceLoader.exists(path):
			var stream: AudioStream = load(path)
			_configure_loop(stream)
			p.stream = stream


func _configure_loop(stream: AudioStream) -> void:
	if stream is AudioStreamOggVorbis or stream is AudioStreamMP3:
		stream.loop = true
	elif stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD


func start() -> void:
	active = true
	current_zone = 0
	intensity = 0.0
	for p in players:
		p.volume_db = SILENT_DB
		if p.stream != null:
			p.play()


func stop_all() -> void:
	active = false
	for p in players:
		p.stop()


func set_zone(zone: int) -> void:
	current_zone = zone


func set_intensity(progress: float) -> void:
	intensity = clamp(progress, 0.0, 1.0)


func _process(delta: float) -> void:
	if not active:
		return
	var step: float = FADE_RATE_DB * delta
	for i in range(players.size()):
		var target: float = SILENT_DB
		if i == current_zone:
			target = lerp(float(ZONE_BASE_DB[i]), float(ZONE_PEAK_DB[i]), intensity)
		players[i].volume_db = move_toward(players[i].volume_db, target, step)
