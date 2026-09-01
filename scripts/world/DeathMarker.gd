extends Node2D

const SIZE: float = 16.0
const MARK_COLOR: Color = Color(0.75, 0.15, 0.18, 0.9)
const GLOW_COLOR: Color = Color(0.45, 0.08, 0.1, 0.4)
const OUTER_GLOW_COLOR: Color = Color(0.35, 0.06, 0.08, 0.18)
const FADE_IN_TIME: float = 1.2

@onready var height_label: Label = $HeightLabel

var _pulse_t: float = randf() * TAU


func set_height(height: int) -> void:
	height_label.text = "%dm" % height


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
	draw_circle(Vector2.ZERO, SIZE * 3.2, OUTER_GLOW_COLOR, true, -1.0, true)
	draw_circle(Vector2.ZERO, SIZE * 1.9 * lerp(0.9, 1.1, pulse), GLOW_COLOR, true, -1.0, true)
	draw_line(Vector2(-SIZE, -SIZE), Vector2(SIZE, SIZE), MARK_COLOR, 4.5, true)
	draw_line(Vector2(-SIZE, SIZE), Vector2(SIZE, -SIZE), MARK_COLOR, 4.5, true)
