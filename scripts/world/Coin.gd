extends Area2D

signal collected

const RADIUS: float = 11.0
const GLOW_COLOR: Color = Color(1.0, 0.95, 0.4, 0.35)
const SPARKLE_COLOR: Color = Color(1.0, 1.0, 0.9, 1.0)

var is_collected: bool = false
var _t: float = randf() * TAU


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_t += delta
	rotation += 3.0 * delta
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

	draw_circle(Vector2.ZERO, RADIUS, Color(1.0, 0.85, 0.25), true, -1.0, true)
	draw_circle(Vector2.ZERO, RADIUS * 0.6, Color(1.0, 0.7, 0.15), true, -1.0, true)
	draw_circle(Vector2(-RADIUS * 0.3, -RADIUS * 0.3), RADIUS * 0.2, Color(1.0, 1.0, 0.85, 0.9), true, -1.0, true)

	for i in range(3):
		var sparkle_phase: float = fmod(_t * 0.6 + i * 0.9, TAU)
		if sparkle_phase < 1.2:
			var s_alpha: float = 1.0 - (sparkle_phase / 1.2)
			var s_angle: float = i * 2.4
			var s_dist: float = RADIUS * 1.6
			var s_pos: Vector2 = Vector2(cos(s_angle), sin(s_angle)) * s_dist
			_draw_sparkle(s_pos, 4.0 * s_alpha, Color(SPARKLE_COLOR.r, SPARKLE_COLOR.g, SPARKLE_COLOR.b, s_alpha))


func _draw_sparkle(pos: Vector2, size: float, color: Color) -> void:
	draw_line(pos + Vector2(-size, 0), pos + Vector2(size, 0), color, 1.5, true)
	draw_line(pos + Vector2(0, -size), pos + Vector2(0, size), color, 1.5, true)
