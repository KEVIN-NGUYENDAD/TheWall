extends Node2D

const SPEED: float = 55.0
const LIFETIME: float = 10.0
const COLORS: Array = [
	Color(1.0, 0.6, 0.75), Color(1.0, 0.85, 0.3), Color(0.6, 0.75, 1.0), Color(0.75, 1.0, 0.6),
]

var direction: float = 1.0

var _t: float = randf() * TAU
var _age: float = 0.0
var _start_pos: Vector2
var _color: Color


func _ready() -> void:
	_start_pos = position
	_color = COLORS[randi() % COLORS.size()]


func _process(delta: float) -> void:
	_age += delta
	if _age > LIFETIME:
		queue_free()
		return
	_t += delta * 5.0
	position.x = _start_pos.x + cos(_t * 0.6) * 30.0 + _t * SPEED * 0.05 * direction
	position.y = _start_pos.y + sin(_t) * 18.0 - _age * 6.0
	queue_redraw()


func _draw() -> void:
	var flap: float = abs(sin(_t))
	var wing: PackedVector2Array = PackedVector2Array([
		Vector2(0, 0), Vector2(-9 * flap - 2, -7), Vector2(-7 * flap - 2, 2),
	])
	draw_colored_polygon(wing, _color)
	var wing_mirrored: PackedVector2Array = PackedVector2Array()
	for p in wing:
		wing_mirrored.append(Vector2(-p.x, p.y))
	draw_colored_polygon(wing_mirrored, _color)
	draw_line(Vector2(0, -3), Vector2(0, 3), Color(0.2, 0.15, 0.1, 0.9), 1.0, true)
