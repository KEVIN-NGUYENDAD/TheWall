extends Node2D

const SPEED: float = 80.0
const BOB_AMOUNT: float = 10.0
const LIFETIME: float = 14.0
const COLOR: Color = Color(0.12, 0.12, 0.15, 0.85)

var direction: float = 1.0

var _t: float = randf() * TAU
var _age: float = 0.0
var _start_y: float


func _ready() -> void:
	_start_y = position.y


func _process(delta: float) -> void:
	_age += delta
	if _age > LIFETIME:
		queue_free()
		return
	_t += delta * 7.0
	position.x += SPEED * direction * delta
	position.y = _start_y + sin(_t) * BOB_AMOUNT
	queue_redraw()


func _draw() -> void:
	var wing: float = sin(_t) * 11.0
	draw_line(Vector2(-13, 0), Vector2(0, -wing), COLOR, 3.5, true)
	draw_line(Vector2(13, 0), Vector2(0, -wing), COLOR, 3.5, true)
	draw_circle(Vector2.ZERO, 3.0, COLOR, true, -1.0, true)
