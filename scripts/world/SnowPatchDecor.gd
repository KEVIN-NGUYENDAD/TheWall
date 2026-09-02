extends Node2D

const SNOW_COLOR: Color = Color(0.98, 0.99, 1.0, 0.95)
const SHADOW_COLOR: Color = Color(0.75, 0.85, 0.95, 0.6)


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	draw_circle(Vector2(-14, 2), 9.0, SHADOW_COLOR, true, -1.0, true)
	draw_circle(Vector2(10, 3), 8.0, SHADOW_COLOR, true, -1.0, true)
	draw_circle(Vector2(-10, -2), 10.0, SNOW_COLOR, true, -1.0, true)
	draw_circle(Vector2(6, -1), 9.0, SNOW_COLOR, true, -1.0, true)
	draw_circle(Vector2(-2, -6), 8.0, SNOW_COLOR, true, -1.0, true)
