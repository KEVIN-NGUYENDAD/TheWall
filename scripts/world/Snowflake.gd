extends Node2D

const FALL_SPEED: float = 30.0
const SWAY_SPEED: float = 0.9
const SWAY_AMOUNT: float = 18.0
const LIFETIME: float = 11.0
const COLOR: Color = Color(1.0, 1.0, 1.0, 0.85)

# >1.0 = a nearer, bigger, faster, brighter flake; <1.0 = a farther, smaller,
# slower, dimmer one. Main.gd spawns one of each per tick for a layered look.
var depth_mult: float = 1.0

var _t: float = randf() * TAU
var _age: float = 0.0
var _start_x: float
var _size: float = randf_range(2.0, 4.0)


func _ready() -> void:
	_start_x = position.x
	_size *= depth_mult
	modulate.a = clamp(0.45 + 0.45 * depth_mult, 0.35, 1.0)


func _process(delta: float) -> void:
	_age += delta
	if _age > LIFETIME:
		queue_free()
		return
	_t += delta * SWAY_SPEED
	position.y += FALL_SPEED * depth_mult * delta
	position.x = _start_x + sin(_t) * SWAY_AMOUNT
	queue_redraw()


func _draw() -> void:
	draw_circle(Vector2.ZERO, _size, COLOR, true, -1.0, true)
