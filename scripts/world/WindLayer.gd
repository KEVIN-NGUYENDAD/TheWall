extends Node2D

const STREAK_COUNT: int = 6
const SPEED: float = 120.0
const COLOR: Color = Color(0.85, 0.87, 0.92, 0.1)
const VIEW_WIDTH: float = 540.0
const VIEW_HEIGHT: float = 960.0

var streaks: Array = []


func _ready() -> void:
	for i in range(STREAK_COUNT):
		streaks.append({
			"pos": Vector2(randf_range(0.0, VIEW_WIDTH), randf_range(0.0, VIEW_HEIGHT)),
			"radius": randf_range(5.0, 11.0),
			"speed_mult": randf_range(0.7, 1.4),
			"bob_t": randf() * TAU,
		})


func _process(delta: float) -> void:
	for s in streaks:
		s.pos.x += SPEED * s.speed_mult * delta
		s.bob_t += delta * 1.2
		if s.pos.x > VIEW_WIDTH + 40.0:
			s.pos.x = -40.0
			s.pos.y = randf_range(0.0, VIEW_HEIGHT)
	queue_redraw()


func _draw() -> void:
	for s in streaks:
		var bob: float = sin(s.bob_t) * 4.0
		var pos: Vector2 = s.pos + Vector2(0.0, bob)
		draw_circle(pos, s.radius, COLOR, true, -1.0, true)
		draw_circle(pos + Vector2(-s.radius * 1.3, 0.0), s.radius * 0.6, COLOR, true, -1.0, true)
