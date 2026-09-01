extends Node2D

const FALL_SPEED: float = 40.0
const SWAY_SPEED: float = 1.5
const SWAY_AMOUNT: float = 25.0
const LIFETIME: float = 8.0
const COLOR: Color = Color(0.92, 0.9, 0.85, 0.55)

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
	# Soft, organic feather blade built from overlapping circles instead of hard geometric lines.
	draw_circle(Vector2(0.0, -7.0), 3.0, COLOR, true, -1.0, true)
	draw_circle(Vector2(0.0, -3.0), 3.8, COLOR, true, -1.0, true)
	draw_circle(Vector2(0.0, 1.0), 3.8, COLOR, true, -1.0, true)
	draw_circle(Vector2(0.0, 5.0), 2.8, COLOR, true, -1.0, true)
	draw_circle(Vector2(0.0, 8.0), 1.6, COLOR, true, -1.0, true)
	var quill: Color = Color(COLOR.r, COLOR.g, COLOR.b, COLOR.a * 0.7)
	draw_line(Vector2(0.0, -8.0), Vector2(0.0, 9.0), quill, 1.0, true)
