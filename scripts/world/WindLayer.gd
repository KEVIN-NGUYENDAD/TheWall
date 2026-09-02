extends Node2D

const STREAK_COUNT: int = 4
const SPEED: float = 100.0
const COLOR: Color = Color(0.88, 0.9, 0.96, 0.1)
const VIEW_WIDTH: float = 540.0
const VIEW_HEIGHT: float = 960.0

# Boosted during Storm (Main.gd) for an obviously windier feel — scales
# both drift speed and visibility.
var intensity_mult: float = 1.0

var streaks: Array = []


func _ready() -> void:
	for i in range(STREAK_COUNT):
		streaks.append({
			"pos": Vector2(randf_range(0.0, VIEW_WIDTH), randf_range(0.0, VIEW_HEIGHT)),
			"radius": randf_range(14.0, 24.0),
			"speed_mult": randf_range(0.7, 1.3),
			"bob_t": randf() * TAU,
		})


func _process(delta: float) -> void:
	for s in streaks:
		s.pos.x += SPEED * s.speed_mult * intensity_mult * delta
		s.bob_t += delta * 0.8
		if s.pos.x > VIEW_WIDTH + 80.0:
			s.pos.x = -80.0
			s.pos.y = randf_range(0.0, VIEW_HEIGHT)
	queue_redraw()


func _draw() -> void:
	var alpha_mult: float = clamp(intensity_mult, 1.0, 3.0)
	for s in streaks:
		var bob: float = sin(s.bob_t) * 5.0
		var pos: Vector2 = s.pos + Vector2(0.0, bob)
		var r: float = s.radius
		# Soft trailing mist wisp: a chain of overlapping circles shrinking and fading behind the lead edge.
		draw_circle(pos, r, Color(COLOR.r, COLOR.g, COLOR.b, COLOR.a * alpha_mult), true, -1.0, true)
		draw_circle(pos - Vector2(r * 1.1, 0.0), r * 0.75, Color(COLOR.r, COLOR.g, COLOR.b, COLOR.a * 0.7 * alpha_mult), true, -1.0, true)
		draw_circle(pos - Vector2(r * 2.0, 0.0), r * 0.45, Color(COLOR.r, COLOR.g, COLOR.b, COLOR.a * 0.4 * alpha_mult), true, -1.0, true)
