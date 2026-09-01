extends Node

const MIX_RATE: int = 22050

var _cache: Dictionary = {}
var _sfx_player: AudioStreamPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_sfx_player = AudioStreamPlayer.new()
	add_child(_sfx_player)

	_cache["jump"] = _make_tone(520.0, 0.12, 0.35)
	_cache["coin"] = _make_tone(1046.0, 0.08, 0.3)
	_cache["checkpoint"] = _make_chime([660.0, 880.0], 0.12, 0.3)
	_cache["death"] = _make_tone(160.0, 0.35, 0.35)
	_cache["click"] = _make_tone(740.0, 0.05, 0.25)
	_cache["unlock"] = _make_chime([523.0, 659.0, 784.0], 0.1, 0.3)


func play(sfx_name: String) -> void:
	if not _cache.has(sfx_name):
		return
	_sfx_player.stream = _cache[sfx_name]
	_sfx_player.play()


func _make_tone(freq: float, duration: float, volume: float) -> AudioStreamWAV:
	var sample_count: int = int(MIX_RATE * duration)
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	for i in range(sample_count):
		var t: float = float(i) / MIX_RATE
		var envelope: float = 1.0 - (float(i) / float(sample_count))
		var sample: float = sin(TAU * freq * t) * volume * envelope
		data.encode_s16(i * 2, int(clamp(sample, -1.0, 1.0) * 32767.0))
	return _build_stream(data)


func _make_chime(freqs: Array, note_duration: float, volume: float) -> AudioStreamWAV:
	var samples_per_note: int = int(MIX_RATE * note_duration)
	var sample_count: int = samples_per_note * freqs.size()
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	for i in range(sample_count):
		var note_index: int = mini(i / samples_per_note, freqs.size() - 1)
		var local_i: int = i % samples_per_note
		var t: float = float(local_i) / MIX_RATE
		var envelope: float = 1.0 - (float(local_i) / float(samples_per_note))
		var sample: float = sin(TAU * float(freqs[note_index]) * t) * volume * envelope
		data.encode_s16(i * 2, int(clamp(sample, -1.0, 1.0) * 32767.0))
	return _build_stream(data)


func _build_stream(data: PackedByteArray) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.data = data
	return stream
