extends Node2D

const FALL_SPEED: float = 340.0
const SWAY_AMOUNT: float = 6.0
const LIFETIME: float = 4.0
const COLOR: Color = Color(0.6, 0.7, 0.85, 0.55)

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
	_t += delta * 3.0
	position.y += FALL_SPEED * delta
	position.x = _start_x + sin(_t) * SWAY_AMOUNT
	queue_redraw()


func _draw() -> void:
	draw_line(Vector2(0, -10), Vector2(-2, 10), COLOR, 1.5, true)
