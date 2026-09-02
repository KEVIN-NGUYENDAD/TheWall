extends Node2D

const COLORS: Array = [
	Color(1.0, 0.5, 0.7), Color(1.0, 0.85, 0.3), Color(0.95, 0.95, 0.95), Color(0.7, 0.55, 1.0),
]


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	var color: Color = COLORS[randi() % COLORS.size()]
	for i in range(5):
		var angle: float = i * TAU / 5.0
		draw_circle(Vector2(cos(angle), sin(angle)) * 6.0, 5.0, color, true, -1.0, true)
	draw_circle(Vector2.ZERO, 3.8, Color(1.0, 0.85, 0.2), true, -1.0, true)
