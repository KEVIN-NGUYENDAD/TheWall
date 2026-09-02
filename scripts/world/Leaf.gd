extends Node2D

const FALL_SPEED: float = 55.0
const SWAY_SPEED: float = 1.2
const SWAY_AMOUNT: float = 35.0
const LIFETIME: float = 9.0
const COLORS: Array = [
	Color(0.9, 0.55, 0.15, 0.9), Color(0.85, 0.3, 0.15, 0.9), Color(0.95, 0.75, 0.2, 0.9),
]

var _t: float = randf() * TAU
var _age: float = 0.0
var _start_x: float
var _color: Color


func _ready() -> void:
	_start_x = position.x
	_color = COLORS[randi() % COLORS.size()]


func _process(delta: float) -> void:
	_age += delta
	if _age > LIFETIME:
		queue_free()
		return
	_t += delta * SWAY_SPEED
	position.y += FALL_SPEED * delta
	position.x = _start_x + sin(_t) * SWAY_AMOUNT
	rotation = sin(_t * 1.3) * 0.9
	queue_redraw()


func _draw() -> void:
	var leaf: PackedVector2Array = PackedVector2Array([
		Vector2(0, -6), Vector2(4, -2), Vector2(3, 4), Vector2(0, 6), Vector2(-3, 4), Vector2(-4, -2),
	])
	draw_colored_polygon(leaf, _color)
