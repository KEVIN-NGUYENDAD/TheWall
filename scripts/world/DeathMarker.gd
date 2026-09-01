extends Node2D

const SIZE: float = 16.0
const MARK_COLOR: Color = Color(0.75, 0.15, 0.18, 0.9)
const GLOW_COLOR: Color = Color(0.45, 0.08, 0.1, 0.4)
const OUTER_GLOW_COLOR: Color = Color(0.35, 0.06, 0.08, 0.18)
const FADE_IN_TIME: float = 1.2
const MAX_SIZE_MULT: float = 1.6

@onready var height_label: Label = $HeightLabel

var _pulse_t: float = randf() * TAU
var _size_mult: float = 1.0


func set_info(height: int, count: int) -> void:
	if count > 1:
		height_label.text = "%dm ×%d" % [height, count]
	else:
		height_label.text = "%dm" % height
	_size_mult = min(1.0 + (count - 1) * 0.12, MAX_SIZE_MULT)
	queue_redraw()


func _ready() -> void:
	modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, FADE_IN_TIME)
	queue_redraw()


func _process(delta: float) -> void:
	_pulse_t += delta * 0.5
	queue_redraw()


func _draw() -> void:
	var pulse: float = 0.5 + 0.5 * sin(_pulse_t * TAU)
	var size: float = SIZE * _size_mult
	draw_circle(Vector2.ZERO, size * 3.2, OUTER_GLOW_COLOR, true, -1.0, true)
	draw_circle(Vector2.ZERO, size * 1.9 * lerp(0.9, 1.1, pulse), GLOW_COLOR, true, -1.0, true)
	draw_line(Vector2(-size, -size), Vector2(size, size), MARK_COLOR, 4.5, true)
	draw_line(Vector2(-size, size), Vector2(size, -size), MARK_COLOR, 4.5, true)
