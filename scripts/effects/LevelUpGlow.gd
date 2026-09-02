extends Node2D

const COLOR: Color = Color(1.0, 0.85, 0.2, 1.0)
const DURATION: float = 1.0

var _t: float = 0.0


func _process(delta: float) -> void:
	_t += delta
	if _t >= DURATION:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var fade: float = 1.0 - (_t / DURATION)
	var pulse: float = 0.85 + 0.15 * sin(_t * 14.0)
	draw_circle(Vector2.ZERO, 70.0 * pulse * fade + 20.0, Color(COLOR.r, COLOR.g, COLOR.b, 0.12 * fade), true, -1.0, true)
	draw_circle(Vector2.ZERO, 42.0 * pulse * fade + 12.0, Color(COLOR.r, COLOR.g, COLOR.b, 0.22 * fade), true, -1.0, true)
