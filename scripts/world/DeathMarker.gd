extends Node2D

const SIZE: float = 14.0
const MARK_COLOR: Color = Color(0.55, 0.1, 0.12, 0.85)
const GLOW_COLOR: Color = Color(0.3, 0.05, 0.08, 0.35)

@onready var height_label: Label = $HeightLabel


func set_height(height: int) -> void:
	height_label.text = "%dm" % height


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	draw_circle(Vector2.ZERO, SIZE * 1.8, GLOW_COLOR, true, -1.0, true)
	draw_line(Vector2(-SIZE, -SIZE), Vector2(SIZE, SIZE), MARK_COLOR, 4.0, true)
	draw_line(Vector2(-SIZE, SIZE), Vector2(SIZE, -SIZE), MARK_COLOR, 4.0, true)
