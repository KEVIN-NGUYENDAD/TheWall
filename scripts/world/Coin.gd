extends Area2D

signal collected

const RADIUS: float = 12.0
const GEM_COLOR: Color = Color(1.0, 0.82, 0.15, 1.0)
const GEM_DARK: Color = Color(0.75, 0.55, 0.05, 1.0)
const FACET_COLOR: Color = Color(1.0, 0.95, 0.75, 0.9)
const GLOW_COLOR: Color = Color(1.0, 0.85, 0.3, 0.55)
const SPARKLE_COLOR: Color = Color(1.0, 1.0, 0.9, 1.0)

var is_collected: bool = false
var _t: float = randf() * TAU


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_t += delta
	rotation += 2.2 * delta
	queue_redraw()


func _on_body_entered(body: Node) -> void:
	if is_collected or not body.is_in_group("player"):
		return
	is_collected = true
	collected.emit()
	queue_free()


func _draw() -> void:
	var pulse: float = 0.6 + 0.4 * sin(_t * 4.0)
	draw_circle(Vector2.ZERO, RADIUS * 2.0 * pulse, Color(GLOW_COLOR.r, GLOW_COLOR.g, GLOW_COLOR.b, GLOW_COLOR.a * pulse), true, -1.0, true)

	# faceted gem silhouette: pointed top, wide middle, pointed bottom
	var top: Vector2 = Vector2(0, -RADIUS * 1.3)
	var upper_left: Vector2 = Vector2(-RADIUS, -RADIUS * 0.25)
	var upper_right: Vector2 = Vector2(RADIUS, -RADIUS * 0.25)
	var bottom: Vector2 = Vector2(0, RADIUS * 1.1)

	draw_colored_polygon(PackedVector2Array([top, upper_right, bottom, upper_left]), GEM_COLOR)

	# inner facet shading for a cut-gem look
	draw_colored_polygon(PackedVector2Array([top, upper_left, Vector2.ZERO]), GEM_DARK)
	draw_colored_polygon(PackedVector2Array([bottom, Vector2.ZERO, upper_left]), Color(GEM_DARK.r, GEM_DARK.g, GEM_DARK.b, 0.7))

	# bright facet highlight lines
	draw_line(top, Vector2.ZERO, FACET_COLOR, 1.2, true)
	draw_line(upper_right, Vector2.ZERO, FACET_COLOR, 1.2, true)
	draw_line(bottom, Vector2.ZERO, FACET_COLOR, 1.0, true)

	# twinkling sparkles
	for i in range(4):
		var sparkle_phase: float = fmod(_t * 0.6 + i * 0.9, TAU)
		if sparkle_phase < 1.2:
			var s_alpha: float = 1.0 - (sparkle_phase / 1.2)
			var s_angle: float = i * 2.4
			var s_pos: Vector2 = Vector2(cos(s_angle), sin(s_angle)) * RADIUS * 1.7
			_draw_sparkle(s_pos, 4.0 * s_alpha, Color(SPARKLE_COLOR.r, SPARKLE_COLOR.g, SPARKLE_COLOR.b, s_alpha))


func _draw_sparkle(pos: Vector2, size: float, color: Color) -> void:
	draw_line(pos + Vector2(-size, 0), pos + Vector2(size, 0), color, 1.5, true)
	draw_line(pos + Vector2(0, -size), pos + Vector2(0, size), color, 1.5, true)
