extends Node

const MIX_RATE: int = 22050
const FADE_RATE_DB: float = 24.0
const SILENT_DB: float = -80.0

const ZONE_BASE_DB: Array = [-9.0, -7.0, -10.0]
const ZONE_PEAK_DB: Array = [-3.0, -1.0, -4.0]

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


# A short percussive "click" repeating at click_rate (quantized to the loop duration).
func _click(t: float, click_rate: float, click_freq: float, decay: float, depth: float) -> float:
	var phase: float = fmod(t * click_rate, 1.0)
	var env: float = exp(-phase * decay)
	return sin(TAU * click_freq * t) * env * depth


# THE RUINS — brighter, adventurous, energetic. Bright major chord with a bouncy pulse.
func _make_ruins_track() -> AudioStreamWAV:
	var duration: float = 4.0
	var freqs: Array = [261.63, 329.63, 392.00, 523.25]
	var q_freqs: Array = []
	for f in freqs:
		q_freqs.append(_quantize_freq(f, duration))
	var pulse_rate: float = _quantize_freq(2.5, duration)
	var click_rate: float = _quantize_freq(2.5, duration)
	var click_freq: float = _quantize_freq(1046.5, duration)

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
		var pulse: float = 1.0 + 0.3 * exp(-pulse_phase * 8.0)
		var click: float = _click(t, click_rate, click_freq, 30.0, 0.12)
		var v: float = sample * 0.24 * pulse + click
		data.encode_s16(i * 2, int(clamp(v, -1.0, 1.0) * 32767.0))

	return _build_stream(data, sample_count)


# THE SKY — uplifting, exciting, stronger rhythm. Bright open chord with a driving double pulse.
func _make_sky_track() -> AudioStreamWAV:
	var duration: float = 3.0
	var freqs: Array = [293.66, 369.99, 440.00, 587.33]
	var q_freqs: Array = []
	for f in freqs:
		q_freqs.append(_quantize_freq(f, duration))
	var pulse_rate: float = _quantize_freq(4.0, duration)
	var click_rate: float = _quantize_freq(4.0, duration)
	var click_freq: float = _quantize_freq(1568.0, duration)
	var accent_rate: float = _quantize_freq(2.0, duration)
	var accent_freq: float = _quantize_freq(880.0, duration)

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
		var pulse: float = 1.0 + 0.4 * exp(-pulse_phase * 9.0)
		var click: float = _click(t, click_rate, click_freq, 35.0, 0.14)
		var accent: float = _click(t, accent_rate, accent_freq, 15.0, 0.1)
		var v: float = sample * 0.24 * pulse + click + accent
		data.encode_s16(i * 2, int(clamp(v, -1.0, 1.0) * 32767.0))

	return _build_stream(data, sample_count)


# THE VOID — mysterious, epic, tension. Low dissonant interval with a driving, syncopated pulse.
func _make_void_track() -> AudioStreamWAV:
	var duration: float = 8.0
	var freqs: Array = [98.00, 103.83, 146.83, 195.99]
	var q_freqs: Array = []
	for f in freqs:
		q_freqs.append(_quantize_freq(f, duration))
	var pulse_rate: float = _quantize_freq(1.5, duration)
	var sting_rate: float = _quantize_freq(0.375, duration)
	var sting_freq: float = _quantize_freq(220.0, duration)
	var wobble_hz: float = _quantize_freq(0.2, duration)

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
		var pulse: float = 1.0 + 0.35 * exp(-pulse_phase * 6.0)
		var sting: float = _click(t, sting_rate, sting_freq, 8.0, 0.16)
		var tremor: float = 1.0 + 0.15 * sin(TAU * wobble_hz * t)
		var v: float = (sample * 0.22 * pulse * tremor) + sting
		data.encode_s16(i * 2, int(clamp(v, -1.0, 1.0) * 32767.0))

	return _build_stream(data, sample_count)
