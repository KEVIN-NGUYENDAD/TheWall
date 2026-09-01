extends Node2D

const RADIUS: float = 46.0
const BASE_COLOR: Color = Color(0.6, 0.55, 0.85, 0.6)
const PULSE_SPEED: float = 0.5
const ROTATE_SPEED: float = 0.15

var _t: float = 0.0


func _process(delta: float) -> void:
	_t += delta
	rotation += ROTATE_SPEED * delta
	queue_redraw()


func _draw() -> void:
	var pulse: float = 0.5 + 0.5 * sin(_t * TAU * PULSE_SPEED)
	var glow_alpha: float = lerp(0.2, 0.4, pulse)
	var core_alpha: float = lerp(0.5, 0.75, pulse)

	draw_circle(Vector2.ZERO, RADIUS * 2.0, Color(BASE_COLOR.r, BASE_COLOR.g, BASE_COLOR.b, glow_alpha * 0.5), true, -1.0, true)
	draw_circle(Vector2.ZERO, RADIUS * 1.3, Color(BASE_COLOR.r, BASE_COLOR.g, BASE_COLOR.b, glow_alpha), true, -1.0, true)
	draw_circle(Vector2.ZERO, RADIUS * 0.55, Color(BASE_COLOR.r, BASE_COLOR.g, BASE_COLOR.b, core_alpha), true, -1.0, true)

	for i in range(3):
		var offset_angle: float = i * (TAU / 3.0)
		draw_arc(Vector2.ZERO, RADIUS + 10.0, offset_angle, offset_angle + 1.2, 20, Color(0.85, 0.82, 0.98, 0.6 * pulse), 2.5, true)
