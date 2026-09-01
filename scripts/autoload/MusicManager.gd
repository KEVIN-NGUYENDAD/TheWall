extends Node

const MIX_RATE: int = 22050
const FADE_RATE_DB: float = 24.0
const SILENT_DB: float = -80.0

const ZONE_BASE_DB: Array = [-10.0, -8.0, -12.0]
const ZONE_PEAK_DB: Array = [-4.0, -2.0, -6.0]

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

	players[0].stream = _make_ruins_track()
	players[1].stream = _make_sky_track()
	players[2].stream = _make_void_track()


func start() -> void:
	active = true
	current_zone = 0
	intensity = 0.0
	for p in players:
		p.volume_db = SILENT_DB
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


func _quantize_freq(freq: float, duration: float) -> float:
	var k: float = round(freq * duration)
	return max(k, 1.0) / duration


func _build_stream(data: PackedByteArray, sample_count: int) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.data = data
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = sample_count
	return stream


# THE RUINS — calm, hopeful, exploration. Slow major-triad pad with gentle breathing.
func _make_ruins_track() -> AudioStreamWAV:
	var duration: float = 6.0
	var freqs: Array = [130.81, 164.81, 196.00, 261.63]
	var q_freqs: Array = []
	for f in freqs:
		q_freqs.append(_quantize_freq(f, duration))
	var wobble_hz: float = _quantize_freq(0.12, duration)

	var sample_count: int = int(MIX_RATE * duration)
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	for i in range(sample_count):
		var t: float = float(i) / MIX_RATE
		var sample: float = 0.0
		for f in q_freqs:
			sample += sin(TAU * f * t)
		sample /= q_freqs.size()
		var envelope: float = 1.0 + 0.1 * sin(TAU * wobble_hz * t)
		var v: float = sample * 0.22 * envelope
		data.encode_s16(i * 2, int(clamp(v, -1.0, 1.0) * 32767.0))

	return _build_stream(data, sample_count)


# THE SKY — energetic, uplifting, rhythmic. Brighter chord with a percussive pulse.
func _make_sky_track() -> AudioStreamWAV:
	var duration: float = 4.0
	var freqs: Array = [146.83, 185.00, 220.00, 293.66]
	var q_freqs: Array = []
	for f in freqs:
		q_freqs.append(_quantize_freq(f, duration))
	var pulse_rate: float = _quantize_freq(2.0, duration)

	var sample_count: int = int(MIX_RATE * duration)
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	for i in range(sample_count):
		var t: float = float(i) / MIX_RATE
		var sample: float = 0.0
		for f in q_freqs:
			sample += sin(TAU * f * t)
		sample /= q_freqs.size()
		var pulse_phase: float = fmod(t * pulse_rate, 1.0)
		var pulse: float = 1.0 + 0.35 * exp(-pulse_phase * 10.0)
		var v: float = sample * 0.24 * pulse
		data.encode_s16(i * 2, int(clamp(v, -1.0, 1.0) * 32767.0))

	return _build_stream(data, sample_count)


# THE VOID — darker, mysterious, tense. Dissonant interval with irregular double-wobble.
func _make_void_track() -> AudioStreamWAV:
	var duration: float = 10.0
	var freqs: Array = [110.00, 116.54, 164.81]
	var q_freqs: Array = []
	for f in freqs:
		q_freqs.append(_quantize_freq(f, duration))
	var wobble1: float = _quantize_freq(0.08, duration)
	var wobble2: float = _quantize_freq(0.13, duration)

	var sample_count: int = int(MIX_RATE * duration)
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	for i in range(sample_count):
		var t: float = float(i) / MIX_RATE
		var sample: float = 0.0
		for f in q_freqs:
			sample += sin(TAU * f * t)
		sample /= q_freqs.size()
		var envelope: float = 1.0 + 0.2 * sin(TAU * wobble1 * t) * sin(TAU * wobble2 * t)
		var v: float = sample * 0.2 * envelope
		data.encode_s16(i * 2, int(clamp(v, -1.0, 1.0) * 32767.0))

	return _build_stream(data, sample_count)
