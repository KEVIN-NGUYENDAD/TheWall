extends Node2D

const COLOR: Color = Color(1.0, 0.85, 0.2, 1.0)
const DURATION: float = 0.6
const START_RADIUS: float = 24.0
const END_RADIUS: float = 130.0

var _t: float = 0.0


func _process(delta: float) -> void:
	_t += delta
	if _t >= DURATION:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var ratio: float = _t / DURATION
	var radius: float = lerp(START_RADIUS, END_RADIUS, ratio)
	var alpha: float = 1.0 - ratio
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 40, Color(COLOR.r, COLOR.g, COLOR.b, alpha), 5.0, true)
