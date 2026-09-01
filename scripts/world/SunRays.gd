extends Node2D

const RAY_COUNT: int = 8
const RADIUS: float = 380.0
const ROTATE_SPEED: float = 0.03
const SUN_COLOR: Color = Color(1.0, 0.95, 0.7, 0.9)
const RAY_COLOR: Color = Color(1.0, 0.95, 0.75, 0.16)

var _t: float = 0.0


func _ready() -> void:
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	material = mat


func _process(delta: float) -> void:
	_t += delta
	rotation = _t * ROTATE_SPEED
	queue_redraw()


func _draw() -> void:
	for i in range(RAY_COUNT):
		var angle: float = i * TAU / RAY_COUNT
		var half_width: float = 0.16
		var p1: Vector2 = Vector2.ZERO
		var p2: Vector2 = Vector2(cos(angle - half_width), sin(angle - half_width)) * RADIUS
		var p3: Vector2 = Vector2(cos(angle + half_width), sin(angle + half_width)) * RADIUS
		draw_colored_polygon(PackedVector2Array([p1, p2, p3]), RAY_COLOR)

	draw_circle(Vector2.ZERO, 46.0, Color(SUN_COLOR.r, SUN_COLOR.g, SUN_COLOR.b, 0.3), true, -1.0, true)
	draw_circle(Vector2.ZERO, 28.0, SUN_COLOR, true, -1.0, true)
