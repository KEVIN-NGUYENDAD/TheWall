extends Node

# One music track per SEASON (Spring/Summer/Autumn/Winter/Storm). The track
# only changes when the season actually changes — never mid-season — and
# crossfades smoothly over CROSSFADE_TIME seconds via two ping-ponged
# players. A separate single-track menu player is independent of this.
# Loads real audio files from res://audio/music/ — no procedural synthesis.
# See audio/README.md for the current track mapping.

const CROSSFADE_TIME: float = 4.0
# Balance pass: overall music volume reduced to ~40% of its previous level
# (-3dB -> -11dB is roughly a 40% linear-loudness reduction).
const SEASON_VOLUME_DB: float = -11.0
const SILENT_DB: float = -80.0

# Only 3 real tracks exist; adjacent seasons share one so the whole climb
# still moves through a clear 3-act arc (bright -> energetic -> epic).
const SEASON_TRACK_PATHS: Array = [
	"res://audio/music/the_mountain-happy-happy-music-496549.mp3", # Spring
	"res://audio/music/the_mountain-happy-happy-music-496549.mp3", # Summer
	"res://audio/music/jorisvermeer-happy-adventure-quest-572050.mp3", # Autumn
	"res://audio/music/the_mountain-fantasy-quest-184140.mp3", # Winter
	"res://audio/music/the_mountain-fantasy-quest-184140.mp3", # Storm
]
const MENU_TRACK_PATH: String = "res://audio/music/velariomusic-happy-vibes-591803.mp3"
const MENU_VOLUME_DB: float = -11.0

var _season_streams: Array = []
var _player_a: AudioStreamPlayer
var _player_b: AudioStreamPlayer
var _a_is_active: bool = true
var current_season: int = -1
var active: bool = false
var _menu_player: AudioStreamPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	_player_a = AudioStreamPlayer.new()
	_player_a.volume_db = SILENT_DB
	add_child(_player_a)
	_player_b = AudioStreamPlayer.new()
	_player_b.volume_db = SILENT_DB
	add_child(_player_b)

	for path in SEASON_TRACK_PATHS:
		var stream: AudioStream = null
		if ResourceLoader.exists(path):
			stream = load(path)
			_configure_loop(stream)
		_season_streams.append(stream)

	_menu_player = AudioStreamPlayer.new()
	_menu_player.volume_db = MENU_VOLUME_DB
	add_child(_menu_player)
	if ResourceLoader.exists(MENU_TRACK_PATH):
		var menu_stream: AudioStream = load(MENU_TRACK_PATH)
		_configure_loop(menu_stream)
		_menu_player.stream = menu_stream


func _configure_loop(stream: AudioStream) -> void:
	if stream is AudioStreamOggVorbis or stream is AudioStreamMP3:
		stream.loop = true
	elif stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD


func start() -> void:
	stop_menu()
	active = true
	current_season = -1


func stop_all() -> void:
	active = false
	_player_a.stop()
	_player_b.stop()
	current_season = -1


func play_menu() -> void:
	if _menu_player.stream != null and not _menu_player.playing:
		_menu_player.play()


func stop_menu() -> void:
	_menu_player.stop()


# Only actually changes track when `season_idx` differs from the current
# season, and only restarts playback when the new season's track is a
# different resource — adjacent seasons sharing a track continue seamlessly
# with no restart/crossfade glitch.
func play_season(season_idx: int) -> void:
	if not active or season_idx == current_season:
		return
	current_season = season_idx

	var stream: AudioStream = null
	if season_idx >= 0 and season_idx < _season_streams.size():
		stream = _season_streams[season_idx]

	var outgoing: AudioStreamPlayer = _player_a if _a_is_active else _player_b
	if stream != null and stream == outgoing.stream and outgoing.playing:
		return

	var incoming: AudioStreamPlayer = _player_b if _a_is_active else _player_a
	_a_is_active = not _a_is_active

	var fade_out_tween: Tween = create_tween()
	fade_out_tween.tween_property(outgoing, "volume_db", SILENT_DB, CROSSFADE_TIME)
	fade_out_tween.tween_callback(outgoing.stop)

	if stream == null:
		return

	incoming.stream = stream
	incoming.volume_db = SILENT_DB
	incoming.play()
	var fade_in_tween: Tween = create_tween()
	fade_in_tween.tween_property(incoming, "volume_db", SEASON_VOLUME_DB, CROSSFADE_TIME)
