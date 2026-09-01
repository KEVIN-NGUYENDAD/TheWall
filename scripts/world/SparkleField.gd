extends Node2D

const SPARKLE_COUNT: int = 14
const SPAN: Vector2 = Vector2(560.0, 960.0)
const COLOR: Color = Color(1.0, 1.0, 0.85, 1.0)

var _sparkles: Array = []


func _ready() -> void:
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	material = mat
	for i in range(SPARKLE_COUNT):
		_sparkles.append({
			"pos": Vector2(randf_range(0.0, SPAN.x), randf_range(0.0, SPAN.y)),
			"phase": randf() * TAU,
			"speed": randf_range(1.2, 2.4),
			"size": randf_range(1.5, 3.2),
		})


func _process(delta: float) -> void:
	for s in _sparkles:
		s.phase += delta * s.speed
	queue_redraw()


func _draw() -> void:
	for s in _sparkles:
		var twinkle: float = 0.5 + 0.5 * sin(s.phase)
		if twinkle < 0.35:
			continue
		var alpha: float = (twinkle - 0.35) / 0.65
		var c: Color = Color(COLOR.r, COLOR.g, COLOR.b, alpha * 0.85)
		_draw_star(s.pos, s.size * (0.6 + 0.4 * twinkle), c)


func _draw_star(pos: Vector2, size: float, color: Color) -> void:
	draw_line(pos + Vector2(-size, 0), pos + Vector2(size, 0), color, 1.2, true)
	draw_line(pos + Vector2(0, -size), pos + Vector2(0, size), color, 1.2, true)
	draw_circle(pos, size * 0.4, color, true, -1.0, true)
