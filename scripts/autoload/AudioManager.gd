extends Node

const MIX_RATE: int = 22050
const VOICE_COUNT: int = 4

var _cache: Dictionary = {}
var _voices: Array = []
var _next_voice: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in range(VOICE_COUNT):
		var p := AudioStreamPlayer.new()
		add_child(p)
		_voices.append(p)

	_cache["jump"] = _make_tone(520.0, 0.12, 0.35)
	_cache["coin"] = _make_tone(1046.0, 0.08, 0.3)
	_cache["checkpoint"] = _make_chime([523.0, 659.0, 880.0], 0.11, 0.32)
	_cache["death"] = _make_tone(160.0, 0.35, 0.35)
	_cache["click"] = _make_tone(740.0, 0.05, 0.25)
	_cache["unlock"] = _make_chime([523.0, 659.0, 784.0], 0.1, 0.3)
	_cache["dash"] = _make_sweep(500.0, 1400.0, 0.14, 0.32)
	_cache["near_miss"] = _make_chime([784.0, 587.0], 0.09, 0.32)
	_cache["landing"] = _make_tone(140.0, 0.09, 0.3)
	_cache["memory"] = _make_chime([392.0, 493.88, 587.0, 783.99], 0.3, 0.26)
	_cache["white_bird"] = _make_chime([880.0, 1046.5, 1318.5], 0.06, 0.28)
	_cache["chirp"] = _make_chime([1568.0, 1760.0], 0.05, 0.2)
	_cache["hit"] = _make_tone(90.0, 0.2, 0.4)
	_cache["area_discovery"] = _make_sweep(300.0, 950.0, 0.5, 0.3)


func play(sfx_name: String) -> void:
	if not _cache.has(sfx_name):
		return
	var voice: AudioStreamPlayer = _voices[_next_voice]
	_next_voice = (_next_voice + 1) % VOICE_COUNT
	voice.stream = _cache[sfx_name]
	voice.play()


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


func _make_sweep(freq_start: float, freq_end: float, duration: float, volume: float) -> AudioStreamWAV:
	var sample_count: int = int(MIX_RATE * duration)
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	var phase: float = 0.0
	for i in range(sample_count):
		var t: float = float(i) / MIX_RATE
		var freq: float = lerp(freq_start, freq_end, t / duration)
		phase += freq / MIX_RATE
		var envelope: float = 1.0 - (t / duration)
		var sample: float = sin(TAU * phase) * volume * envelope
		data.encode_s16(i * 2, int(clamp(sample, -1.0, 1.0) * 32767.0))
	return _build_stream(data)


func _build_stream(data: PackedByteArray) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.data = data
	return stream
