extends Node2D

const RADIUS: float = 34.0
const BASE_COLOR: Color = Color(0.55, 0.5, 0.7, 0.4)
const PULSE_SPEED: float = 0.6

var _t: float = 0.0


func _process(delta: float) -> void:
	_t += delta * PULSE_SPEED
	queue_redraw()


func _draw() -> void:
	var pulse: float = 0.5 + 0.5 * sin(_t * TAU)
	var glow_alpha: float = lerp(0.15, 0.3, pulse)
	draw_circle(Vector2.ZERO, RADIUS * 1.6, Color(BASE_COLOR.r, BASE_COLOR.g, BASE_COLOR.b, glow_alpha), true, -1.0, true)
	draw_circle(Vector2.ZERO, RADIUS * 0.5, BASE_COLOR, true, -1.0, true)
	draw_arc(Vector2.ZERO, RADIUS, 0.0, TAU, 48, Color(BASE_COLOR.r + 0.15, BASE_COLOR.g + 0.15, BASE_COLOR.b + 0.15, 0.5), 2.0, true)
