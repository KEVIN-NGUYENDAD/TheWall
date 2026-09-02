extends Node2D

var color: Color = Color(1.0, 1.0, 1.0, 0.0)


func set_tint(c: Color) -> void:
	color = c
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(-400.0, -700.0, 800.0, 1400.0), color, true)
