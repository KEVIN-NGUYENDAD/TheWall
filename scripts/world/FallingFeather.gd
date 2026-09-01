extends Node2D

const FALL_SPEED: float = 40.0
const SWAY_SPEED: float = 1.5
const SWAY_AMOUNT: float = 25.0
const LIFETIME: float = 8.0
const COLOR: Color = Color(0.9, 0.88, 0.85, 0.5)

var _t: float = randf() * TAU
var _age: float = 0.0
var _start_x: float


func _ready() -> void:
	_start_x = position.x


func _process(delta: float) -> void:
	_age += delta
	if _age > LIFETIME:
		queue_free()
		return
	_t += delta * SWAY_SPEED
	position.y += FALL_SPEED * delta
	position.x = _start_x + sin(_t) * SWAY_AMOUNT
	rotation = sin(_t) * 0.4
	queue_redraw()


func _draw() -> void:
	draw_line(Vector2(0, -8), Vector2(0, 8), COLOR, 2.0, true)
	draw_line(Vector2(0, -8), Vector2(4, 0), COLOR, 1.5, true)
	draw_line(Vector2(0, -8), Vector2(-4, 0), COLOR, 1.5, true)
