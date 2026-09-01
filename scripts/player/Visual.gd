extends Node2D

var radius: float = 24.0
var body_color: Color = Color(0.2, 0.6, 0.95)
var charge_ratio: float = 0.0
var is_charging: bool = false


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, body_color, true, -1.0, true)
	if is_charging:
		draw_arc(Vector2.ZERO, radius + 6.0, 0.0, TAU * charge_ratio, 32, Color(1.0, 0.3, 0.3), 4.0, true)
