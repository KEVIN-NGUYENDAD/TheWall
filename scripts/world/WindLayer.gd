extends Node2D

const STREAK_COUNT: int = 6
const SPEED: float = 140.0
const COLOR: Color = Color(0.85, 0.87, 0.92, 0.12)
const VIEW_WIDTH: float = 540.0
const VIEW_HEIGHT: float = 960.0

var streaks: Array = []


func _ready() -> void:
	for i in range(STREAK_COUNT):
		streaks.append({
			"pos": Vector2(randf_range(0.0, VIEW_WIDTH), randf_range(0.0, VIEW_HEIGHT)),
			"len": randf_range(30.0, 70.0),
			"speed_mult": randf_range(0.7, 1.4),
		})


func _process(delta: float) -> void:
	for s in streaks:
		s.pos.x += SPEED * s.speed_mult * delta
		if s.pos.x > VIEW_WIDTH + 60.0:
			s.pos.x = -60.0
			s.pos.y = randf_range(0.0, VIEW_HEIGHT)
	queue_redraw()


func _draw() -> void:
	for s in streaks:
		draw_line(s.pos, s.pos + Vector2(s.len, 0.0), COLOR, 1.5, true)
