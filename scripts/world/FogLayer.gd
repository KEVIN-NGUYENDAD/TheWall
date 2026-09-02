extends ParallaxLayer

const BASE_COLOR: Color = Color(0.92, 0.95, 1.0)
const WISP_COUNT: int = 7

var intensity: float = 0.0
var _wisps: Array = []


func _ready() -> void:
	for i in range(WISP_COUNT):
		_wisps.append({
			"pos": Vector2(randf_range(20.0, 520.0), randf_range(0.0, 960.0)),
			"radius": randf_range(70.0, 150.0),
		})
	queue_redraw()


func set_intensity(value: float) -> void:
	var clamped: float = clamp(value, 0.0, 1.0)
	if is_equal_approx(clamped, intensity):
		return
	intensity = clamped
	queue_redraw()


func _draw() -> void:
	if intensity <= 0.0:
		return
	for w in _wisps:
		var alpha: float = 0.18 * intensity
		draw_circle(w.pos, w.radius, Color(BASE_COLOR.r, BASE_COLOR.g, BASE_COLOR.b, alpha), true, -1.0, true)
